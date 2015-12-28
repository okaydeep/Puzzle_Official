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
        local tmpColor = {"red", "green"}
        stageManager:GenerateGems(sceneGroup, GM.Color, false, gemDrag)        

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

        if stageManager:CheckConnected(touchedGemI, touchedGemJ) == true then
            print("haha")
        end

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
            end

            myCircle.x = event.x
            myCircle.y = event.y

        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false

            t.x, t.y = stageManager.stageToWorldPos(touchedGemI, touchedGemJ)
        end
    end

    -- Stop further propagation of touch event!
    return true
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
