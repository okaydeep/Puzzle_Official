---------------------------------------------------------------------------------
--
-- SceneTemplate.lua
--
---------------------------------------------------------------------------------

require( "CameraManager" )

local sceneName = ...

local composer = require( "composer" )

local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local CM

local centerX
local centerY
local screenW
local screenH

local playerHSpd
local playerVSpd

local gameScene
local bg_ground
local bg_cloud
local gameScene_tree
local gameScene_grass
local char_player
local char_monster01
local char_monster02

function scene:create( event )
    local sceneGroup = self.view

    CM = CameraManager:New(CM)

    centerX = display.contentWidth/2
    centerY = display.contentHeight/2
    screenW = display.contentWidth
    screenH = display.contentHeight

    playerHSpd = 0
    playerVSpd = 0

    bg_ground = display.newRect(centerX, screenH, screenW*2, 50)
    bg_ground:setFillColor(0, 1, 0, 0.5)
    bg_cloud = display.newRect(centerX-100, 0, 100, 50)
    bg_cloud:setFillColor(1, 1, 1, 1)
    CM:AddToLayer(bg_ground, "game")
    CM:AddToLayer(bg_cloud, "game")

    gameScene_tree = display.newRect(centerX-100, screenH-100, 50, 150)
    gameScene_tree:setFillColor(0.3, 1, 0.3, 1)
    gameScene_grass = display.newRect(centerX+100, screenH-50, 50, 50)
    gameScene_grass:setFillColor(0.5, 1, 0.5, 1)
    CM:AddToLayer(gameScene_tree, "game")
    CM:AddToLayer(gameScene_grass, "game")

    char_player = display.newRect(100, screenH-50, 25, 50)
    char_player:setFillColor(0.2, 0.2, 0.8, 1)
    char_monster01 = display.newRect(screenW-100, screenH-75, 70, 100)
    char_monster01:setFillColor(0.9, 0.2, 0.2, 1)
    char_monster02 = display.newRect(screenW-200, screenH-75, 70, 100)
    char_monster02:setFillColor(0.9, 0.2, 0.2, 1)
    CM:AddToLayer(char_player, "game")
    CM:AddToLayer(char_monster01, "game")
    CM:AddToLayer(char_monster02, "game")
end

-- Called when a key event has been received
local function onKeyEvent( event )
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    print( message )
    local phase = event.phase
    local keyName = event.keyName

    if phase == "down" then
        if keyName == "right" then
            playerHSpd = 2
        elseif keyName == "left" then
            playerHSpd = -2
        end
    elseif phase == "up" then
        if keyName == "left" or keyName == "right" then
            playerHSpd = 0
        end
    end

    -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        local platformName = system.getInfo( "platformName" )
        if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
            return true
        end
    end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

local function updatePlayerPosition()
    if playerHSpd ~= 0 then
        char_player.x = char_player.x+playerHSpd
    end

    if playerVSpd ~= 0 then
        char_player.y = char_player.y+playerVSpd
    end
end

local function updateCamera()
    CM:GetLayer("game").x = CM:GetLayer("game").x-playerHSpd
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then

    elseif phase == "did" then
        Runtime:addEventListener( "key", onKeyEvent )
        Runtime:addEventListener( "enterFrame", updatePlayerPosition )
        Runtime:addEventListener( "enterFrame", updateCamera )
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