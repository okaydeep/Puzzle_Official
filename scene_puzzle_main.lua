---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

require( "GlobalManager" )
require( "Gem" )
require( "StageManager" )

local sceneName = ...

local composer = require( "composer" )
local widget = require( "widget" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local GM
local stageManager

local directionArr

local touchedGemI
local touchedGemJ
local collidedGemI
local collidedGemJ

local myCircle
local gemSample

-- Line Group
local lineGroup

-- 按鈕,
local btns

-- 定位點
local locatePoint

-- 盤面儲存
local gemSave
-- 移動儲存
local moveSave

-- For Debug
local systemMemUsed
local textureMemUsed

-----------------------------------------------------------------------------------------------------------------------------
--
-- Custom functions
--
-----------------------------------------------------------------------------------------------------------------------------

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
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false

        end
    end
end

local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released" )
    end
end

-- Gem的觸控事件
function gemDrag( event )
    local t = event.target
    local phase = event.phase
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
        
        -- Store initial position
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y
        t.startX = event.x
        t.startY = event.y
        touchedGemI, touchedGemJ = stageManager.worldToStagePos(event.x, event.y)

        showGemInfo(touchedGemI, touchedGemJ)        

        for i=1, 5 do
            gemSave[i] = { }

            for j=1, 6 do
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
            local gX, gY = stageManager.stageToWorldPos(touchedGemI, touchedGemJ)
            local moveX = event.x-gX
            local moveY = event.y-gY

            -- 水平移動
            if moveX >= GM.gemWidth*0.5 then
                if touchedGemJ >= 6 then collidedGemJ = touchedGemJ return end

                if moveY >= GM.gemHeight*GM.touchAreaCoe then
                    if touchedGemI < 5 then
                        collidedGemI = touchedGemI+1
                    else
                        collidedGemI = touchedGemI
                    end                    
                elseif moveY < GM.gemHeight*GM.touchAreaCoe and moveY > GM.gemHeight*(-GM.touchAreaCoe) then
                    collidedGemI = touchedGemI
                elseif moveY <= GM.gemHeight*(-GM.touchAreaCoe) then
                    if touchedGemI > 1 then
                        collidedGemI = touchedGemI-1
                    else
                        collidedGemI = touchedGemI
                    end                    
                end

                collidedGemJ = touchedGemJ+1

            elseif moveX <= GM.gemWidth*(-0.5) then
                if touchedGemJ <= 1 then collidedGemJ = touchedGemJ return end

                if moveY >= GM.gemHeight*GM.touchAreaCoe then
                    if touchedGemI < 5 then
                        collidedGemI = touchedGemI+1
                    else
                        collidedGemI = touchedGemI
                    end                    
                elseif moveY < GM.gemHeight*GM.touchAreaCoe and moveY > GM.gemHeight*(-GM.touchAreaCoe) then
                    collidedGemI = touchedGemI
                elseif moveY <= GM.gemHeight*(-GM.touchAreaCoe) then
                    if touchedGemI > 1 then
                        collidedGemI = touchedGemI-1
                    else
                        collidedGemI = touchedGemI
                    end                    
                end

                collidedGemJ = touchedGemJ-1

            end

            -- 垂直移動
            if moveY >= GM.gemHeight*0.5 then
                if touchedGemI >= 5 then collidedGemI = touchedGemI return end

                if moveX >= GM.gemWidth*GM.touchAreaCoe then
                    if touchedGemJ < 6 then
                        collidedGemJ = touchedGemJ+1
                    else
                        collidedGemJ = touchedGemJ
                    end                    
                elseif moveX < GM.gemWidth*GM.touchAreaCoe and moveX > GM.gemWidth*(-GM.touchAreaCoe) then
                    collidedGemJ = touchedGemJ
                elseif moveX <= GM.gemWidth*(-GM.touchAreaCoe) then
                    if touchedGemJ > 1 then
                        collidedGemJ = touchedGemJ-1
                    else
                        collidedGemJ = touchedGemJ
                    end                    
                end

                collidedGemI = touchedGemI+1

            elseif moveY <= GM.gemHeight*(-0.5) then
                if touchedGemI <= 1 then collidedGemI = touchedGemI return end
                
                if moveX >= GM.gemWidth*GM.touchAreaCoe then
                    if touchedGemJ < 5 then
                        collidedGemJ = touchedGemJ+1
                    else
                        collidedGemJ = touchedGemJ
                    end                    
                elseif moveX < GM.gemWidth*GM.touchAreaCoe and moveX > GM.gemWidth*(-GM.touchAreaCoe) then
                    collidedGemJ = touchedGemJ
                elseif moveX <= GM.gemWidth*(-GM.touchAreaCoe) then
                    if touchedGemJ > 1 then
                        collidedGemJ = touchedGemJ-1
                    else
                        collidedGemJ = touchedGemJ
                    end                    
                end

                collidedGemI = touchedGemI-1

            end

            -- 如果有觸碰到其它gem
            if collidedGemI ~= nil and collidedGemJ ~= nil then                
                stageManager:GemSwap(touchedGemI, touchedGemJ, collidedGemI, collidedGemJ)
                touchedGemJ = collidedGemJ
                touchedGemI = collidedGemI                
                collidedGemI = nil
                collidedGemJ = nil
                moveSave[#moveSave+1] = {touchedGemJ, touchedGemI}
                print(#moveSave)
            end

            myCircle.x = event.x
            myCircle.y = event.y
        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
            --GM.canTouch = false
            t.x, t.y = stageManager.stageToWorldPos(touchedGemI, touchedGemJ)            
            stageManager:EliminateGem()
        end
    end

    -- Stop further propagation of touch event!
    return true
end

-- 回放功能
function playback()
    local sceneGroup = scene.view
    -- local gemIdx = 2
    local moveGemIdx = 1
    local moveDelay = GM.playbackMoveDuration
    local swapDelay = GM.playbackMoveDuration*0.4

    if #moveSave < 2 then
        return
    end

    for i,v in ipairs(moveSave) do
        print(i,v)
    end

    for i=1, 5 do
        for j=1, 6 do            
            local posX, posY = stageManager.stageToWorldPos(i, j)
            stageManager.stage[i][j].img:removeSelf()
            print(GM.GemName[gemSave[i][j]])
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
            stageManager:EliminateGem()
        end
    end

    function gemSwap(event)        
        stageManager:GemSwap(moveSave[moveGemIdx][2], moveSave[moveGemIdx][1], moveSave[moveGemIdx+1][2], moveSave[moveGemIdx+1][1])        
    end

    function gemMove(event)
        local movePos = moveSave[moveGemIdx]
        local moveGem = stageManager.stage[movePos[2]][movePos[1]].img
        local postX, postY = stageManager.stageToWorldPos(moveSave[moveGemIdx+1][2], moveSave[moveGemIdx+1][1])
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

-- 更新消耗記憶體
function updateMemUsage()
    local memUsed = (collectgarbage("count"))
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1048576

    systemMemUsed.text = "System Memory: " .. string.format("%.00f", memUsed) .. " KB"
    textureMemUsed.text = "Texture Memory: " .. string.format("%.03f", texUsed) .. " MB"
end

-- 顯示gem資訊 (水平, 垂直, 顏色)
function showGemInfo( gemI, gemJ )
    print(stageManager.stage[gemI][gemJ].stagePos.y, stageManager.stage[gemI][gemJ].stagePos.x, stageManager.stage[gemI][gemJ].color)
end

-- Test
function selectPhotoCallback(event)
    local photo = event.target

    if photo then
        local photoW, photoH = photo.width, photo.height
        local photoImg = display.newImageRect(sceneGroup, photo, 200, 200)
    end
end

-- Test
function selectPhoto()
    if media.hasSource( media.PhotoLibrary ) then
        media.selectPhoto(
        {
            mediaSource = media.SavedPhotosAlbum,
            listener = selectPhotoCallback            
        })
    else
       native.showAlert( "Corona", "This device does not have a photo library.", { "OK" } )
    end
end

-- 按鈕事件, id: 1:重新產生, 2:播放回放,
function buttonEvent(event)
    local target = event.target
    local phase = event.phase

    if phase == "began" then
        if target.id == 1 then

        elseif target.id == 2 then

        end
    elseif phase == "moved" then
        if target.id == 1 then

        elseif target.id == 2 then

        end
    elseif phase == "ended" then
        if target.id == 1 then
            local colorIdxArr = {1, 2, 3, 4}
            stageManager:GenerateGem(scene.view, colorIdxArr, false, gemDrag)
        elseif target.id == 2 then
            playback()
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view
    math.randomseed( os.time() )
    GM = GlobalManager:New(GM)
    stageManager = StageManager:New(stageManager)

    lineGroup = display.newGroup()

    myCircle = display.newCircle( 0, 0, GM.touchRadius*0.5 )
    myCircle.isVisable = false
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase    

    if phase == "will" then
        -- 欲使用的gem引數
        local colorIdxArr = {1, 2, 3, 4}
        -- 初始盤面
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

        -- 初始化監看消耗記憶體的文字
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
        systemMemUsed = display.newText( options )
        systemMemUsed.text = "System Memory: 0 KB",
        systemMemUsed:setFillColor( 1, 1, 1 )

        textureMemUsed = display.newText( options )
        textureMemUsed.text = "Texture Memory: 0.000 MB"
        textureMemUsed.y = 25
        systemMemUsed:setFillColor( 1, 1, 1 )

        if (system.getInfo("environment") == "simulator") then
            Runtime:addEventListener( "enterFrame", updateMemUsage)
        end

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
            btns[i].y = display.contentHeight-100
            btns[i]:setLabel(GM.ButtonName[i])
        end

        -- 截圖的定位點
        local locatePointPos = { {200, 200}, {300, 200}, {300, 300}, {200, 300} }

        for i=1, #GM.LocatePointDir do
            local lPoint = display.newCircle( locatePointPos[i][1], locatePointPos[i][2], GM.touchRadius*0.5 )
            lPoint.dir = GM.LocatePointDir[i]
            lPoint:addEventListener("touch", locatePointMove)
            locatePoint = locatePoint or { }
            locatePoint[i] = lPoint
        end

        -- Color Sample example
        gemSample = display.newImageRect("img/gemSample.png", 600, 490)
        gemSample.x = display.contentCenterX
        gemSample.y = display.contentCenterY
        GM.DoColorSample(gemSample.x, gemSample.y)

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
