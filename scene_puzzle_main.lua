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

    directionArr = {                        
        { { 0 , -1 }, { 1, 1 }, { 1, 0 } }, -- 第一象限
        { { -1, 0 }, { -1, -1 }, { 0 , -1 } }, -- 第二象限
        { { 0, 1 }, { -1, 1 }, { -1, 0 } }, -- 第三象限
        { { 1, 0 }, { 1, 1 }, { 0, 1 } } -- 第四象限
    }

    myCircle = display.newCircle( 0, 0, GM.touchRadius*0.5 )
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
                gem.stagePos = {x=i, y=j}                
                gem.color = GM.Color[randColor]
                local posX, posY = stageManager.stageToWorldPos(gem.stagePos.y, gem.stagePos.x)
                gem.img = display.newImage( sceneGroup, GM.SpritePath..GM.GemName[randColor], posX, posY )
                gem.img:addEventListener("touch", gemDrag)                
                stageManager:AddGemToStage(j, i, gem)

                -- test
                local circle = display.newCircle( posX, posY, GM.touchRadius*0.5 )
            end
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

    elseif t.isFocus then
        if "moved" == phase then
            t.x = event.x - t.x0
            t.y = event.y - t.y0
            local gX, gY = stageManager.stageToWorldPos(touchedGemI, touchedGemJ)
            local moveX = event.x-gX
            local moveY = event.y-gY

            -- 水平移動
            if moveX >= GM.gemWidth*0.5 then
                --if touchedGemJ >= 6 then collidedGemJ = touchedGemJ return end

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

            -- if moveX ~= 0 or moveY ~= 0 then                
            --     -- 第四象限
            --     if moveX >= 0 and moveY >= 0 then
            --         for i=1, #directionArr[4] do
            --             local tmpDir = directionArr[4][i]

            --             if stageManager:CheckTouch(t.x, t.y, touchedGemI+tmpDir[2], touchedGemJ+tmpDir[1]) == true then
            --                 collidedGemI = touchedGemI+tmpDir[2]
            --                 collidedGemJ = touchedGemJ+tmpDir[1]
            --                 break
            --             end
            --         end

            --     -- 第一象限
            --     elseif moveX >= 0 and moveY <= 0 then
            --         for i=1, #directionArr[1] do
            --             local tmpDir = directionArr[1][i]

            --             if stageManager:CheckTouch(t.x, t.y, touchedGemI+tmpDir[2], touchedGemJ+tmpDir[1]) == true then
            --                 collidedGemI = touchedGemI+tmpDir[2]
            --                 collidedGemJ = touchedGemJ+tmpDir[1]
            --                 break
            --             end
            --         end

            --     -- 第三象限
            --     elseif moveX <= 0 and moveY >= 0 then                     
            --         for i=1, #directionArr[3] do
            --             local tmpDir = directionArr[3][i]

            --             if stageManager:CheckTouch(t.x, t.y, touchedGemI+tmpDir[2], touchedGemJ+tmpDir[1]) == true then
            --                 collidedGemI = touchedGemI+tmpDir[2]
            --                 collidedGemJ = touchedGemJ+tmpDir[1]
            --                 break
            --             end
            --         end

            --     -- 第二象限
            --     elseif moveX <= 0 and moveY <= 0 then
            --         for i=1, #directionArr[2] do
            --             local tmpDir = directionArr[2][i]

            --             if stageManager:CheckTouch(t.x, t.y, touchedGemI+tmpDir[2], touchedGemJ+tmpDir[1]) == true then
            --                 collidedGemI = touchedGemI+tmpDir[2]
            --                 collidedGemJ = touchedGemJ+tmpDir[1]
            --                 break
            --             end
            --         end
            --     end
            -- end

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

function updateMemUsage()
    local memUsed = (collectgarbage("count"))
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1048576

    systemMemUsed.text = "System Memory: " .. string.format("%.00f", memUsed) .. " KB"
    textureMemUsed.text = "Texture Memory: " .. string.format("%.03f", texUsed) .. " MB"
end

function showGemInfo( gemI, gemJ )
    print(gemI, gemJ, stageManager.stage[gemI][gemJ].color)
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
