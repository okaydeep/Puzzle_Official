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

-- 盤面儲存
local gemSave
-- 移動儲存
local moveSave

-- For Debug
local systemMemUsed
local textureMemUsed

function scene:create( event )
    local sceneGroup = self.view
    math.randomseed( os.time() )
    GM = GlobalManager:New(GM)
    stageManager = StageManager:New(stageManager)    

    myCircle = display.newCircle( 0, 0, GM.touchRadius*0.5 )
    myCircle.isVisable = false
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase    

    if phase == "will" then
        -- 產生盤面
        local colorIdxArr = {1, 2, 3, 4}
        stageManager:GenerateGem(sceneGroup, colorIdxArr, true, gemDrag)

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

---------------------------------------------------------------------------------
--
-- Custom functions
--
---------------------------------------------------------------------------------

-- 每顆gem的觸控事件
function gemDrag( event )
    local t = event.target
    local phase = event.phase

    if GM.canTouch == false then
        return
    end

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
            end

            myCircle.x = event.x
            myCircle.y = event.y

        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
            GM.canTouch = false
            t.x, t.y = stageManager.stageToWorldPos(touchedGemI, touchedGemJ)            
            --stageManager:EliminateGem()
            playback()
        end
    end

    -- Stop further propagation of touch event!
    return true
end

function playback()
    local sceneGroup = scene.view

    for i=1, 5 do
        for j=1, 6 do            
            local posX, posY = stageManager.stageToWorldPos(i, j)
            stageManager.stage[i][j].img:removeSelf()
            print(GM.GemName[gemSave[i][j]])
            stageManager.stage[i][j].img = display.newImage( sceneGroup, GM.SpritePath..GM.GemName[gemSave[i][j]], posX, posY )
        end
    end

    local function swap(event)
        local params = event.source.params
        stageManager:GemSwap(params.aStagePos[1], params.aStagePos[2], params.bStagePos[1], params.bStagePos[2])
    end

    local function playbackSwap(fromImg, toImg)        
        local aI, aJ = stageManager.worldToStagePos(fromImg.x, fromImg.y)
        local bI, bJ = stageManager.worldToStagePos(toImg.x, toImg.y)
        local evtHnd = timer.performWithDelay(GM.playbackMoveDuration*0.5, swap)
        evtHnd.params = {aStagePos = {aI, aJ}, bStagePos = {bI, bJ}}
    end

    local function playbackMove(event)
        local params = event.source.params        
        
        local evtHnd = transition.to( params.fromImg, {time=GM.playbackMoveDuration, x=params.toImg.x, y=params.toImg.y, 
            onStart=function() playbackSwap(params.fromImg, params.toImg) end} )        
    end

    for i=1, #moveSave do
        if i+1 > #moveSave then
            break
        end

        local prePos = moveSave[i]
        local target = stageManager.stage[prePos[2]][prePos[1]].img
        local postPos = moveSave[i+1]
        local dest = stageManager.stage[postPos[2]][postPos[1]].img
        local evtHnd = timer.performWithDelay( GM.playbackMoveDuration*i, playbackMove )
        evtHnd.params = { fromImg = target, toImg = dest }
    end
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

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
