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

local GV
local stageManager

local gemStartX
local gemStartY

function scene:create( event )
    local sceneGroup = self.view
    GV = GlobalManager:New(GV)
    stageManager = StageManager:New(stageManager)

    gemStartX = 10
    gemStartY = 100
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase    

    if phase == "will" then
        for i=1, 6 do
            for j=1, 5 do
                local gem = Gem:New(gem)
                local randColor = math.random(1, 6)
                gem.color = GV.Color[randColor]
                gem.img = display.newImage( sceneGroup, GV.SpritePath..GV.GemName[randColor], gemStartX+i*GV.gemWidth, gemStartY+j*GV.gemHeight )
                gem.img.pos = {x=i, y=j}
                gem.img:addEventListener("touch", gemDrag)                

                stageManager:AddGemToStage(j, i, gem)
            end
        end

        print (stageManager.stage[1][3].color)
        
        
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

function gemDrag( event )
    local t = event.target
    local phase = event.phase    
    local touchedGemI
    local touchedGemJ

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

    elseif t.isFocus then
        if "moved" == phase then
            t.x = event.x - t.x0
            t.y = event.y - t.y0            
            local moveX = event.x-t.startX
            local moveY = event.y-t.startY            

            if moveX > 0 then
                -- 第四象限
                if moveY > 0 then
                    if stageManager:CheckTouch(t.x, t.y, t.pos.y, t.pos.x+1) == true then
                        touchedGemI = t.pos.y
                        touchedGemJ = t.pos.x+1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y+1, t.pos.x+1) == true then
                        touchedGemI = t.pos.y+1
                        touchedGemJ = t.pos.x+1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y+1, t.pos.x) == true then
                        touchedGemI = t.pos.y+1
                        touchedGemJ = t.pos.x
                    end
                -- 正右
                elseif moveY == 0 then
                    if stageManager:CheckTouch(t.x, t.y, t.pos.y, t.pos.x+1) == true then
                        touchedGemI = t.pos.y
                        touchedGemJ = t.pos.x+1
                    end
                -- 第一象限
                elseif moveY < 0 then
                    if stageManager:CheckTouch(t.x, t.y, t.pos.y, t.pos.x+1) == true then
                        touchedGemI = t.pos.y
                        touchedGemJ = t.pos.x+1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y-1, t.pos.x+1) == true then
                        touchedGemI = t.pos.y-1
                        touchedGemJ = t.pos.x+1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y-1, t.pos.x) == true then
                        touchedGemI = t.pos.y-1
                        touchedGemJ = t.pos.x
                    end
                end
            elseif moveX == 0 then
                -- 正下
                if moveY > 0 then
                    if stageManager:CheckTouch(t.x, t.y, t.pos.y+1, t.pos.x+1) == true then
                        touchedGemI = t.pos.y+1
                        touchedGemJ = t.pos.x+1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y+1, t.pos.x) == true then
                        touchedGemI = t.pos.y+1
                        touchedGemJ = t.pos.x
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y+1, t.pos.x-1) == true then
                        touchedGemI = t.pos.y+1
                        touchedGemJ = t.pos.x-1
                    end
                -- 正上
                elseif moveY < 0 then
                    if stageManager:CheckTouch(t.x, t.y, t.pos.y-1, t.pos.x+1) == true then
                        touchedGemI = t.pos.y-1
                        touchedGemJ = t.pos.x+1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y-1, t.pos.x) == true then
                        touchedGemI = t.pos.y-1
                        touchedGemJ = t.pos.x
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y-1, t.pos.x-1) == true then
                        touchedGemI = t.pos.y-1
                        touchedGemJ = t.pos.x-1
                    end
                end
            elseif moveX < 0 then
                -- 第三象限
                if moveY > 0 then
                    if stageManager:CheckTouch(t.x, t.y, t.pos.y, t.pos.x-1) == true then
                        touchedGemI = t.pos.y
                        touchedGemJ = t.pos.x-1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y+1, t.pos.x-1) == true then
                        touchedGemI = t.pos.y+1
                        touchedGemJ = t.pos.x-1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y+1, t.pos.x) == true then
                        touchedGemI = t.pos.y+1
                        touchedGemJ = t.pos.x
                    end
                -- 正左
                elseif moveY == 0 then
                    if stageManager:CheckTouch(t.x, t.y, t.pos.y, t.pos.x-1) == true then
                        touchedGemI = t.pos.y
                        touchedGemJ = t.pos.x-1
                    end
                -- 第二象限
                elseif moveY < 0 then
                    if stageManager:CheckTouch(t.x, t.y, t.pos.y, t.pos.x-1) == true then
                        touchedGemI = t.pos.y
                        touchedGemJ = t.pos.x-1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y-1, t.pos.x-1) == true then
                        touchedGemI = t.pos.y-1
                        touchedGemJ = t.pos.x-1
                    elseif stageManager:CheckTouch(t.x, t.y, t.pos.y-1, t.pos.x) == true then
                        touchedGemI = t.pos.y-1
                        touchedGemJ = t.pos.x
                    end
                end
            end

            if touchedGemI ~= nil and touchedGemJ ~= nil then
                print (touchedGemI, touchedGemJ)
            end

        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false

        end
    end

    -- Stop further propagation of touch event!
    return true
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
