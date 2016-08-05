---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

require( "GlobalManager" )
require( "StageManager" )
require( "SoundManager" )
require( "InfoManager" )
require( "Gem" )

local sceneName = ...

local composer = require( "composer" )
local widget = require( "widget" )
local motionHnd = require( "MotionHandler" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- 屬性, 狀態設定
local beginDrag
local preSystemTime
local dragTime

-- 遊戲物件
local GM
local stageManager
local soundManager
local infoManager

-- 觸控gem紀錄
local touchedGemI
local touchedGemJ
local collidedGemI
local collidedGemJ

-- 暫用圖片物件
local gemSample
local imgForParse

-- Line Group
local lineGroup

-- ProgressBar Group
local progressBarGroup

-- 按鈕,
local btns

-- 進度條
local progressView
local progressText
local PB_bottom
local PB_inner
local PB_maskRight
local PB_maskLeft
local PB_maskMiddle

-- 定位點
local locatePoint

-- 盤面儲存
local gemSave
-- 移動儲存
local moveSave

-- 文字訊息
local comboText
local dragTimeText

-- 盤面設定
local panelColor
local panelWidth
local panelHeight

-- For Debug
local loadingTotalAmount
local processIdx

-----------------------------------------------------------------------------------------------------------------------------
--
-- Custom functions
--
-----------------------------------------------------------------------------------------------------------------------------

-- 顯示進度條, visible:是否顯示
local function showProgressBar(visible)
    if visible then
        progressBarGroup:toFront()
    else
        progressBarGroup:toBack()
    end

    progressBarGroup.isVisible = visible
end

-- 更新進度條, prog:進度,範圍0.0~1.0
local function updateProgress(prog)
    if prog <= 0.5 then
        progressText:setFillColor( 1, 1, 1 )
    elseif prog > 0.5 then
        progressText:setFillColor( 0, 0, 0 )
    end

    progressText.text = string.format("%.1f%%", prog*100)

    -- progressView:setProgress(prog)
end

-- 定位點移動 (目前無用)
local function locatePointMove( event )
    local t = event.target
    local phase = event.phase

    if "began" == phase then
        display.getCurrentStage():setFocus( t )
        t.isFocus = true
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y

    elseif t.isFocus then
        if "moved" == phase then
            t.x = event.x - t.x0
            t.y = event.y - t.y0
            if lineGroup[1] ~= nil then
                lineGroup[1]:removeSelf()
            end

            if t.dir == GM.LocatePointDir[1] then
                locatePoint[2].y = t.y
                locatePoint[4].x = t.x
            elseif t.dir == GM.LocatePointDir[2] then
                locatePoint[1].y = t.y
                locatePoint[3].x = t.x
            elseif t.dir == GM.LocatePointDir[3] then
                locatePoint[4].y = t.y
                locatePoint[2].x = t.x
            elseif t.dir == GM.LocatePointDir[4] then
                locatePoint[3].y = t.y
                locatePoint[1].x = t.x
            end

            local line = display.newLine( lineGroup, locatePoint[1].x, locatePoint[1].y, locatePoint[2].x, locatePoint[2].y )
            line:append( locatePoint[3].x, locatePoint[3].y, locatePoint[4].x, locatePoint[4].y, locatePoint[1].x, locatePoint[1].y )
            line:setStrokeColor( 1, 0, 0, 1 )
            line.strokeWidth = 8

        elseif "ended" == phase or "cancelled" == phase then
            for i=1,#locatePoint do
                print("P" .. i .. ": " .. locatePoint[i].x .. ", " .. locatePoint[i].y)
            end
            
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
        end
    end
end

-- Gem的觸控事件
function gemDrag( event )
    local t = event.target
    local phase = event.phase
    local panelW, panelH = stageManager:GetPanelSize()
--[[
    if GM.canTouch == false then
        return
    end
]]--
    if "began" == phase then        
        display.getCurrentStage():setFocus( t )
        t.isFocus = true
        t.x = event.x
        t.y = event.y
        t:toFront()
        dragTime = 0
        
        -- Store initial position
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y
        t.startX = event.x
        t.startY = event.y
        touchedGemI, touchedGemJ = stageManager:worldToStagePos(event.x, event.y)

        showGemInfo(touchedGemI, touchedGemJ)        

        for i=1, panelH do
            gemSave[i] = { }

            for j=1, panelW do
                for idx, val in ipairs(GM.Color) do
                    if stageManager:GetColor(i, j) == val then
                        gemSave[i][j] = idx
                        break
                    end        
                end                
            end
        end
        moveSave = { }
        moveSave[#moveSave+1] = {touchedGemJ, touchedGemI}
    elseif t.isFocus then
        if "moved" == phase then
            t.x = event.x - t.x0
            t.y = event.y - t.y0
            local gX, gY = stageManager:stageToWorldPos(touchedGemI, touchedGemJ)
            local moveX = event.x-gX
            local moveY = event.y-gY

            -- 分九宮格, 從下方開始
            if moveY >= stageManager.gemHeight*(1-GM.touchAreaCoe) then
                -- 下方邊界判定
                if touchedGemI >= 5 then
                    collidedGemI = touchedGemI
                else
                    collidedGemI = touchedGemI+1
                end

                -- 直行判斷
                if moveX >= stageManager.gemWidth*(1-GM.touchAreaCoe) then
                    if touchedGemJ >= 6 then
                        collidedGemJ = touchedGemJ
                    else
                        collidedGemJ = touchedGemJ+1    
                    end
                elseif moveX <= stageManager.gemWidth*GM.touchAreaCoe and moveX >= stageManager.gemWidth*(-GM.touchAreaCoe) then
                    collidedGemJ = touchedGemJ
                elseif moveX <= stageManager.gemWidth*(-1+GM.touchAreaCoe) then
                    if touchedGemJ <= 1 then
                        collidedGemJ = touchedGemJ
                    else
                        collidedGemJ = touchedGemJ-1    
                    end
                end

            -- 中間
            elseif moveY <= stageManager.gemHeight*GM.touchAreaCoe and  moveY >= stageManager.gemHeight*(-GM.touchAreaCoe) then
                collidedGemI = touchedGemI

                -- 直行判斷
                if moveX >= stageManager.gemWidth*(1-GM.touchAreaCoe) then
                    if touchedGemJ >= 6 then
                        collidedGemJ = touchedGemJ
                    else
                        collidedGemJ = touchedGemJ+1    
                    end
                elseif moveX <= stageManager.gemWidth*GM.touchAreaCoe and moveX >= stageManager.gemWidth*(-GM.touchAreaCoe) then
                    -- 無珠子碰撞
                    collidedGemI = nil                    
                    collidedGemJ = nil
                elseif moveX <= stageManager.gemWidth*(-1+GM.touchAreaCoe) then
                    if touchedGemJ <= 1 then
                        collidedGemJ = touchedGemJ
                    else
                        collidedGemJ = touchedGemJ-1    
                    end
                end

            -- 上方
            elseif moveY <= stageManager.gemHeight*(-1+GM.touchAreaCoe) then
                -- 上方邊界判定
                if touchedGemI <= 1 then
                    collidedGemI = touchedGemI
                else
                    collidedGemI = touchedGemI-1
                end

                -- 直行判斷
                if moveX >= stageManager.gemWidth*(1-GM.touchAreaCoe) then
                    if touchedGemJ >= 6 then
                        collidedGemJ = touchedGemJ
                    else
                        collidedGemJ = touchedGemJ+1    
                    end
                elseif moveX <= stageManager.gemWidth*GM.touchAreaCoe and moveX >= stageManager.gemWidth*(-GM.touchAreaCoe) then
                    collidedGemJ = touchedGemJ
                elseif moveX <= stageManager.gemWidth*(-1+GM.touchAreaCoe) then
                    if touchedGemJ <= 1 then
                        collidedGemJ = touchedGemJ
                    else
                        collidedGemJ = touchedGemJ-1    
                    end
                end
            end                

            -- 如果有觸碰到其它gem
            if collidedGemI ~= nil and collidedGemJ ~= nil then
                stageManager:GemSwap(touchedGemI, touchedGemJ, collidedGemI, collidedGemJ)
                touchedGemJ = collidedGemJ
                touchedGemI = collidedGemI                
                collidedGemI = nil
                collidedGemJ = nil
                moveSave[#moveSave+1] = {touchedGemJ, touchedGemI}
                beginDrag = true                
                --print(#moveSave)
            end
        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
            --GM.canTouch = false
            t.x, t.y = stageManager:stageToWorldPos(touchedGemI, touchedGemJ)
            stageManager:AddCallback("updatecombo", updateComboText)
            stageManager:EliminateGem()
            beginDrag = false
        end
    end

    -- Stop further propagation of touch event!
    return true
end

-- 分析點擊位置的顏色 (目前無用)
function colorSampleTouch( event )
    local t = event.target
    local phase = event.phase

    if "began" == phase then
        display.getCurrentStage():setFocus( t )
        t.isFocus = true
        display.colorSample( event.x, event.y, GM.onColorSample )        
    elseif t.isFocus then
        if "moved" == phase then
        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
        end
    end
end

-- 讀取分析圖片
function loadImage()
    local panelW, panelH = stageManager:GetPanelSize()
    imgForParse.isVisible = true
    GM.loadFromImage = true
    loadingTotalAmount = panelW*panelH
    processIdx = 1    
    doLoadImage()
end

-- 讀取分析圖片完成處理
function loadImageFinished()
    showProgressBar(false)
    GM.loadFromImage = false
    stageManager:GenerateGem(scene.view, nil, GM.parsedColor, false, gemDrag)
    imgForParse.isVisible = false
    -- imgForParse:removeSelf()
end

function loadImageFinishedTmp()    
    -- print("==============================")
    for i=1, 5 do
        for j=1, 6 do
            GM.parsedColor[i][j] = GM.hToColorIdx(GM.ColorH[(i-1)*6+j])
        end
        -- print(GM.hToColorIdx(GM.ColorH[(i-1)*6+1]),
        --     GM.hToColorIdx(GM.ColorH[(i-1)*6+2]),
        --     GM.hToColorIdx(GM.ColorH[(i-1)*6+3]),
        --     GM.hToColorIdx(GM.ColorH[(i-1)*6+4]),
        --     GM.hToColorIdx(GM.ColorH[(i-1)*6+5]),
        --     GM.hToColorIdx(GM.ColorH[(i-1)*6+6]))
        -- print("==============================")
    end
    -- GM.ColorH = nil
    -- GM.ColorH = { }
    GM.ClearTable(GM.ColorH)

    loadImageFinished()
end

-- 讀取分析圖片(使用計時器延遲呼叫)
function doLoadImage()
    local panelW, panelH = stageManager:GetPanelSize()

    updateStatus()

    -- 讀取結束
    -- if processIdx > loadingTotalAmount then
    --     GM.loadFromImage = false        
    --     stageManager:GenerateGem(scene.view, nil, GM.parsedColor, false, gemDrag)
    --     gemSample.isVisible = false
    --     gemSample.x = display.contentCenterX
    --     gemSample.y = display.contentCenterY+300
    --     return
    -- end    
    
    timer.performWithDelay(1, function()
        local idx, vIdx, hIdx = 0, 0, 0
        idx = processIdx
        vIdx = math.floor((idx-1)/panelW)+1
        hIdx = (idx-1)%panelW+1
        processIdx = processIdx+1
        if processIdx <= loadingTotalAmount then
            GM.parseColorCallback[1] = doLoadImage
        else
            updateStatus()
            -- GM.parseColorCallback[1] = loadImageFinished
            GM.parseColorCallback[1] = loadImageFinishedTmp
        end
        GM:DoColorSample(vIdx, hIdx)
    end)

    -- Color sample 無法直接連續使用    
    -- timer.performWithDelay( 50, doLoadImage )
end

-- 更新狀態文字
function updateStatus()
    local loadingIdx = processIdx

    showProgressBar(true)
    local progress = loadingIdx/loadingTotalAmount
    if progress > 1 then progress = 1 end

    -- updateProgress(progress)
    setProgress(progress)

    if loadingIdx <= loadingTotalAmount then
        setStatus( string.format("Loading...%.1f%%", progress*100) )
    else
        setStatus( "Loading...Finished" )
    end
end

-- 設定狀態文字
function setStatus(content)
    infoManager:UpdateItemContent(3, content)
end

-- 回放功能
function playback()
    local panelW, panelH = stageManager:GetPanelSize()
    local sceneGroup = scene.view
    -- local gemIdx = 2
    local moveGemIdx = 1
    local moveDelay = GM.playbackMoveDuration
    local swapDelay = GM.playbackMoveDuration*0.4

    if #moveSave < 2 then
        return
    end

    for i,v in ipairs(moveSave) do
        --print(i,v)
    end

    for i=1, panelH do
        for j=1, panelW do
            local posX, posY = stageManager:stageToWorldPos(i, j)
            stageManager.stage[i][j].img:removeSelf()
            --print(GM.GemName[gemSave[i][j]])
            stageManager.stage[i][j].color = GM.Color[gemSave[i][j]]
            stageManager.stage[i][j].img = display.newImage( sceneGroup, GM.SpritePath..GM.GemName[gemSave[i][j]], posX, posY )
        end
    end

    function checkContinue()
        if moveGemIdx == 1 then            
            moveDelay = 0
        end

        if moveGemIdx+1 < #moveSave then
            moveGemIdx = moveGemIdx+1
            startPlayback()
        else
            stageManager:RemoveCallback("updatecombo")
            stageManager:EliminateGem()
        end
    end

    function gemSwap(event)        
        stageManager:GemSwap(moveSave[moveGemIdx][2], moveSave[moveGemIdx][1], moveSave[moveGemIdx+1][2], moveSave[moveGemIdx+1][1])        
    end

    function gemMove(event)
        local movePos = moveSave[moveGemIdx]
        local moveGem = stageManager.stage[movePos[2]][movePos[1]].img
        local postX, postY = stageManager:stageToWorldPos(moveSave[moveGemIdx+1][2], moveSave[moveGemIdx+1][1])
        if moveGemIdx == 1 then
            moveGem:toFront()
        end
        transition.to( moveGem, {time=GM.playbackMoveDuration, x=postX, y=postY, onComplete=checkContinue} )
    end

    function startPlayback()
        timer.performWithDelay( moveDelay, gemMove )
        timer.performWithDelay( moveDelay+swapDelay, gemSwap )
    end    

    startPlayback()

    -- local function checkContinue(event)
    --     gemIdx = gemIdx+1

    --     if gemIdx <= #moveSave then
    --         doPlayback()
    --     else
    --         stageManager:EliminateGem()
    --     end        
    -- end

    -- local function otherGemMove(event)
    --     local postPos = moveSave[gemIdx]
    --     local destGem = stageManager.stage[postPos[2]][postPos[1]].img
    --     local preX, preY = stageManager.stageToWorldPos(moveSave[gemIdx-1][2], moveSave[gemIdx-1][1])
    --     transition.to( destGem, {time=GM.playbackMoveDuration, x=preX, y=preY} )
    -- end

    -- local function firstGemMove(event)
    --     local firstPos = moveSave[1]
    --     local firstGem = stageManager.stage[firstPos[2]][firstPos[1]].img        
    --     local postX, postY = stageManager.stageToWorldPos(moveSave[gemIdx][2], moveSave[gemIdx][1])
    --     transition.to( firstGem, {time=GM.playbackMoveDuration, x=postX, y=postY, onComplete=checkContinue} )
    -- end

    -- function doPlayback()
    --     local moveDelay = 0
    --     local firstPos = moveSave[1]
    --     local firstGem = stageManager.stage[firstPos[2]][firstPos[1]].img

    --     if gemIdx <= 2 then
    --         moveDelay = GM.playbackMoveDuration
    --         firstGem:toFront()
    --     end

    --     timer.performWithDelay( moveDelay, firstGemMove )
    --     timer.performWithDelay( moveDelay+GM.playbackMoveDuration*0.4, otherGemMove )
    -- end

    -- doPlayback()
end

-- 更新拖曳時間
function updateDragTime()
    if beginDrag == true then
        local deltaTime = system.getTimer()-preSystemTime
        dragTime = dragTime + deltaTime
        infoManager:UpdateItemContent(4, string.format("%.2f", dragTime/1000))
    end

    preSystemTime = system.getTimer()
end
Runtime:addEventListener("enterFrame", updateDragTime)

-- 更新combo數
function updateComboText(combo)    
    infoManager:UpdateItemContent(5, combo)
end

-- 更新消耗記憶體
function updateMemUsage()
    local memUsed = (collectgarbage("count"))
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1048576

    -- systemMemUsed.text = "System Memory: " .. string.format("%.00f", memUsed) .. " KB"
    -- textureMemUsed.text = "Texture Memory: " .. string.format("%.03f", texUsed) .. " MB"

    infoManager:UpdateItemContent(1, string.format("%.00f", memUsed) .. " KB")
    infoManager:UpdateItemContent(2, string.format("%.03f", texUsed) .. " MB")
end

-- 顯示gem資訊 (水平, 垂直, 顏色)
function showGemInfo( gemI, gemJ )
    print(stageManager.stage[gemI][gemJ].stagePos.y, stageManager.stage[gemI][gemJ].stagePos.x, stageManager.stage[gemI][gemJ].color)
end

-- 選取照片callback
function selectPhotoCallback(event)
    local photo = event.target

    if photo then
        -- local wRatio = display.contentWidth/photo.width
        imgForParse = photo
        local ratio = GM.PAD_scaleRatio
        photo:scale(ratio, ratio)
        photo.x = display.contentCenterX
        photo.y = display.contentCenterY
        loadImage()
        -- timer.performWithDelay(1000*5, function() photo.isVisible=false end)
        
        -- setStatus("photo height: " .. photo.height .. ", display contentHeight: " .. display.contentHeight ..
        --     ",\nphoto width: " .. photo.width .. ", display contentWidth: " .. display.contentWidth)
    end
end

-- 選取照片
function selectPhoto()
    if media.hasSource( media.PhotoLibrary ) then
        if GM.parsedColor ~= nil and #(GM.parsedColor[1]) > 0 then
            local alert = native.showAlert( "Corona", "已有參考圖片, 重新讀取新的圖片嗎?", { "是", "否, 使用舊圖" }, onSelectPhotoCompleted )
        else            
            media.selectPhoto(
            {
                mediaSource = media.SavedPhotosAlbum,
                listener = selectPhotoCallback            
            })
        end
    else
       native.showAlert( "Corona", "This device does not have a photo library.", { "OK" } )
    end
end

-- 選取照片按鈕事件
function onSelectPhotoCompleted( event )
    if ( event.action == "clicked" ) then
        local i = event.index
        if ( i == 1 ) then
            media.selectPhoto(
            {
                mediaSource = media.SavedPhotosAlbum,
                listener = selectPhotoCallback            
            })
        elseif ( i == 2 ) then
            stageManager:GenerateGem(scene.view, nil, GM.parsedColor, false, gemDrag)
        end
    end
end

-- 按鈕事件, id: 1:重新產生, 2:播放回放, 3:選取照片
function buttonEvent(event)
    local target = event.target
    local phase = event.phase

    if phase == "began" then
        soundManager:PlaySound("test01")

        if target.id == 1 then

        elseif target.id == 2 then

        end
    elseif phase == "moved" then
        if target.id == 1 then

        elseif target.id == 2 then

        end
    elseif phase == "ended" then
        if target.id == 1 then
            updateComboText(0)
            infoManager:UpdateItemContent(4, "0.00")            
            stageManager:GenerateGem(scene.view, panelColor, nil, false, gemDrag)
        elseif target.id == 2 then
            playback()
        elseif target.id == 3 then
            -- loadImage()
            selectPhoto()
        end
    end
end

function setProgress(prog)
    local p = 1-prog
    progressBarGroup.isVisible = true
    -- updateProgress(prog)

    if p <= 0 then
        PB_maskRight.isVisible = false
        PB_maskLeft.isVisible = false
        PB_maskMiddle.isVisible = false
    elseif p > 0 and p <= 1 then
        PB_maskRight.isVisible = true
        PB_maskLeft.isVisible = true
        PB_maskMiddle.isVisible = true
        
        local newWidth = math.round(308*p)
        PB_maskMiddle.width = newWidth
        PB_maskLeft.x = 148-newWidth+1
    end
end

-----------------------------------------------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view
    math.randomseed( os.time() )
    GM = GlobalManager:New(GM)
    stageManager = StageManager:New(stageManager)
    soundManager = SoundManager:New(soundManager)
    infoManager = InfoManager:New(infoManager)

    lineGroup = display.newGroup()
    progressBarGroup = display.newGroup()    

    soundManager:LoadSound("test01")

    local myRectangle = display.newRect( display.contentCenterX, display.contentCenterY, 10, 10 )    
    motionHnd.Move(myRectangle, 100, 0, 1000, easing.outExpo)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase    

    if phase == "will" then
        -- 屬性設定初始
        beginDrag = false
        preSystemTime = 0        
        dragTime = 0

        -- 欲使用的gem引數
        panelColor = {1, 2, 3, 4, 5, 6}

        -- 初始盤面
        panelWidth = 6
        panelHeight = 5
        stageManager:SetPanelSize(panelWidth, panelHeight)
        stageManager:InitGem()

        -- 延遲500ms產生盤面 (匿名函式Anonymous Function)
        --timer.performWithDelay(500, function() stageManager:GenerateGem(sceneGroup, colorIdxArr, false, gemDrag) end )        

        -- Color Sample 用法
        --display.colorSample( display.contentCenterX, display.contentCenterY, _.onColorSample )

        -- local tb1 = { var1=1, var2=2 }

        -- local tb2 = copyTable(tb1)
        -- local tb3 = copyTable(tb1)
        -- tb3.var1 = 10
        -- tb2 = copyTable(tb3)

        -- print(tb2.var1, tb2.var2)

        -- 畫線
        -- local star = display.newLine( 200, 90, 227, 165 )
        -- star:append( 305,165, 243,216, 265,290, 200,245, 135,290, 157,215, 95,165, 173,165, 200,90 )
        -- star:setStrokeColor( 1, 0, 0, 1 )
        -- star.strokeWidth = 8
        -- star.x = star.x+200

        gemSave = { }
        moveSave = { }        

        -- 資料顯示初始
        infoManager:AddItem(1, "System Memory: ", "0 KB")
        infoManager:AddItem(2, "Texture Memory: ", "0.000 MB")
        infoManager:AddItem(3, "Current Status: ")
        infoManager:AddItem(4, "拖曳時間: ", "0.00")
        infoManager:AddItem(5, "Combo: ", "0")

        if (system.getInfo("environment") == "simulator") then
            Runtime:addEventListener( "enterFrame", updateMemUsage)
        end

        local options = 
        {
            text = "",
            x = 350,
            y = 0,
            width = 600,     --required for multi-line and alignment
            font = native.systemFontBold,   
            fontSize = 20,
            align = "left"  --new alignment parameter
        }

        infoManager:GenerateInfo(options)
        infoManager:ShowItem(1, false)
        infoManager:ShowItem(2, false)
        infoManager:ShowItem(3, false)

        -- 按鈕初始
        if btns == nil then
            btns = { }
        end        

        for i=1, #GM.ButtonName do
            GM.btnDefaultOption.id = i
            GM.btnDefaultOption.fontSize = 28
            GM.btnDefaultOption.onEvent = buttonEvent
            btns[i] = widget.newButton(
                GM.btnDefaultOption
            )

            btns[i].x = 180*i
            -- btns[i].y = display.contentHeight-28
            btns[i].y = display.contentHeight+100
            btns[i]:setLabel(GM.ButtonName[i])
        end

        -- 截圖的定位點
        -- local locatePointPos = { {200, 200}, {300, 200}, {300, 300}, {200, 300} }        

        -- for i=1, #GM.LocatePointDir do
        --     local lPoint = display.newCircle( locatePointPos[i][1], locatePointPos[i][2], 40*0.5 )
        --     lPoint.dir = GM.LocatePointDir[i]
        --     lPoint:addEventListener("touch", locatePointMove)
        --     locatePoint = locatePoint or { }
        --     locatePoint[i] = lPoint
        -- end

        -- Color Sample測試
        -- local scaleRatio = display.contentHeight/1920
        
        -- gemSample = display.newImageRect(GM.ImgRootPath .. "tmp3.png", 1080*scaleRatio, 1920*scaleRatio)        
        -- gemSample.x = display.contentCenterX
        -- gemSample.y = display.contentCenterY
        -- gemSample:addEventListener("touch", colorSampleTouch)

        -- local myRectangle = display.newRect( display.contentCenterX-576*0.5+3, display.contentCenterY-57, 3, 3 )
        -- local yOffset = (1080*scaleRatio)/6
        -- display.newRect( display.contentCenterX-576*0.5+3+yOffset, display.contentCenterY-57+yOffset, 3, 3 )
        -- imgForParse = gemSample

        -- 進度條初始
        -- options = {
        --     text = "",
        --     width = 600,     --required for multi-line and alignment
        --     font = native.systemFontBold,   
        --     fontSize = 14,
        --     align = "center"  --new alignment parameter
        -- }        
        -- progressText = display.newText( options )
        -- progressText.text = "0%"
        -- progressText:setFillColor( 1, 1, 1 )

        -- 進度條物件初始
        PB_bottom = display.newImageRect(GM.ImgRootPath .. "ui/PB_bottom_01.png", 318, 20)          -- PB底部
        PB_inner = display.newImageRect(GM.ImgRootPath .. "ui/PB_inner_01.png", 318, 20)            -- PB進度
        PB_maskRight = display.newImageRect(GM.ImgRootPath .. "ui/PB_maskRight_01.png", 5, 14)      -- PB遮罩右側
        PB_maskRight.anchorX = 0
        PB_maskRight.x = PB_maskRight.x+153
        PB_maskLeft = display.newImageRect(GM.ImgRootPath .. "ui/PB_maskLeft_01.png", 5, 14)        -- PB遮罩左側
        PB_maskLeft.anchorX = 0
        PB_maskLeft.x = PB_maskLeft.x+148
        PB_maskMiddle = display.newImageRect(GM.ImgRootPath .. "ui/PB_maskMiddle_01.png", 154, 14)  -- PB遮罩中間
        PB_maskMiddle.anchorX = 1
        PB_maskMiddle.x = PB_maskMiddle.x+154

        progressBarGroup:insert(PB_bottom)
        progressBarGroup:insert(PB_inner)
        progressBarGroup:insert(PB_maskRight)
        progressBarGroup:insert(PB_maskLeft)
        progressBarGroup:insert(PB_maskMiddle)
        -- progressBarGroup:insert(progressText)

        -- progressBarGroup:scale(1.4, 1.4)
        progressBarGroup.isVisible = false
        progressBarGroup.x = display.contentCenterX
        progressBarGroup.y = display.contentCenterY-100

        -- print(GM.rgbToHsv(255, 0, 0, 255))
        -- print(GM.rgbToHsv(0, 255, 0, 255))
        -- print(GM.rgbToHsv(0, 0, 255, 255))
    elseif phase == "did" then
        
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        
    elseif phase == "did" then
        
    end
end


function scene:destroy( event )
    local sceneGroup = self.view
    
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene