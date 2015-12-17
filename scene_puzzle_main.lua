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

local touchedGemI
local touchedGemJ
local collidedGemI
local collidedGemJ

local myCircle

function scene:create( event )
    local sceneGroup = self.view
    math.randomseed( os.time() )
    GV = GlobalManager:New(GV)
    stageManager = StageManager:New(stageManager)    

    gemStartX = 10
    gemStartY = 100

    myCircle = display.newCircle( 0, 0, GV.touchRadius*0.5 )
    myCircle.isVisable = false
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase    

    if phase == "will" then
        for i=1, 6 do
            for j=1, 5 do
                local gem = Gem:New(gem)
                local randColor = math.random(1, 6)
                -- test
                local circle = display.newCircle( gemStartX+i*GV.gemWidth, gemStartY+j*GV.gemHeight, GV.touchRadius*0.5 )
                gem.stagePos = {x=i, y=j}                
                gem.color = GV.Color[randColor]
                local posX, posY = stageManager.stageToWorldPos(gem.stagePos.y, gem.stagePos.x)
                gem.img = display.newImage( sceneGroup, GV.SpritePath..GV.GemName[randColor], posX, posY )
                gem.img:addEventListener("touch", gemDrag)                

                stageManager:AddGemToStage(j, i, gem)
            end
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

        print (touchedGemI, touchedGemJ, stageManager:GetColor(touchedGemI, touchedGemJ))

    elseif t.isFocus then
        if "moved" == phase then
            t.x = event.x - t.x0
            t.y = event.y - t.y0
            local gX, gY = stageManager.stageToWorldPos(touchedGemI, touchedGemJ)
            local moveX = event.x-gX
            local moveY = event.y-gY

            if moveX ~= 0 or moveY ~= 0 then
                -- 第四象限
                if moveX >= 0 and moveY >= 0 then
                    if stageManager:CheckTouch(t.x, t.y, touchedGemI, touchedGemJ+1) == true then
                        collidedGemI = touchedGemI
                        collidedGemJ = touchedGemJ+1
                    elseif stageManager:CheckTouch(t.x, t.y, touchedGemI+1, touchedGemJ+1) == true then
                        collidedGemI = touchedGemI+1
                        collidedGemJ = touchedGemJ+1
                    elseif stageManager:CheckTouch(t.x, t.y, touchedGemI+1, touchedGemJ) == true then
                        collidedGemI = touchedGemI+1
                        collidedGemJ = touchedGemJ
                    end

                -- 第一象限
                elseif moveX >= 0 and moveY <= 0 then
                    if stageManager:CheckTouch(t.x, t.y, touchedGemI, touchedGemJ+1) == true then
                        collidedGemI = touchedGemI
                        collidedGemJ = touchedGemJ+1
                    elseif stageManager:CheckTouch(t.x, t.y, touchedGemI-1, touchedGemJ+1) == true then
                        collidedGemI = touchedGemI-1
                        collidedGemJ = touchedGemJ+1
                    elseif stageManager:CheckTouch(t.x, t.y, touchedGemI-1, touchedGemJ) == true then
                        collidedGemI = touchedGemI-1
                        collidedGemJ = touchedGemJ
                    end

                -- 第三象限
                elseif moveX <= 0 and moveY >= 0 then                     
                    if stageManager:CheckTouch(t.x, t.y, touchedGemI, touchedGemJ-1) == true then
                        collidedGemI = touchedGemI
                        collidedGemJ = touchedGemJ-1
                    elseif stageManager:CheckTouch(t.x, t.y, touchedGemI+1, touchedGemJ-1) == true then
                        collidedGemI = touchedGemI+1
                        collidedGemJ = touchedGemJ-1
                    elseif stageManager:CheckTouch(t.x, t.y, touchedGemI+1, touchedGemJ) == true then
                        collidedGemI = touchedGemI+1
                        collidedGemJ = touchedGemJ
                    end

                -- 第二象限
                elseif moveX <= 0 and moveY <= 0 then
                    if stageManager:CheckTouch(t.x, t.y, touchedGemI, touchedGemJ-1) == true then
                        collidedGemI = touchedGemI
                        collidedGemJ = touchedGemJ-1
                    elseif stageManager:CheckTouch(t.x, t.y, touchedGemI-1, touchedGemJ-1) == true then
                        collidedGemI = touchedGemI-1
                        collidedGemJ = touchedGemJ-1
                    elseif stageManager:CheckTouch(t.x, t.y, touchedGemI-1, touchedGemJ) == true then
                        collidedGemI = touchedGemI-1
                        collidedGemJ = touchedGemJ
                    end
                end
            end

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

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
