---------------------------------------------------------------------------------
--
-- SceneTemplate.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )

local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then

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
    
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene