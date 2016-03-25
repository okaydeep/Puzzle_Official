---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local fps
local animFrameAmount
local animPlayTime

local animGroup
local animSource

local btn01Group
local btn01_normal
local btn01_pressed

local function handleTouch( event )
    local t = event.target 
    local phase = event.phase

    if ( phase == "began" ) then
        if ( btn01Group.whichBtn == "normal" ) then
            btn01_normal.isVisible = false
            btn01_pressed.isVisible = true
            btn01Group.whichBtn = "pressed"
        elseif ( btn01Group.whichBtn == "pressed" ) then
            btn01_normal.isVisible = true
            btn01_pressed.isVisible = false
            btn01Group.whichBtn = "normal"
        end

        local parent = t.parent
        parent:insert( t )
        display.getCurrentStage():setFocus( t )
        t.isFocus = true
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y
    elseif ( t.isFocus ) then
        if ( "moved" == phase ) then
            -- Make object move
            t.x = event.x - t.x0
            t.y = event.y - t.y0
        elseif ( "ended" == phase or "cancelled" == phase ) then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
        end
    end
 
    return true
end

-- for image sheet
local function playSheetAnim()
    local idx = animGroup.currentImg
    animSource[idx].isVisible = false
    idx = idx + 1
    if idx > 5 then
        idx = 1
    end    
    animSource[idx].isVisible = true
    animGroup.currentImg = idx
end

-- for image sprite
local function playSpriteAnim()
    local idx = animSource.currentImg
    idx = idx + 1
    if idx > 5 then
        idx = 1
    end
    animSource:setFrame( idx )
    animSource.currentImg = idx
end

function scene:create( event )
    local sceneGroup = self.view

    fps = 30
    animFrameAmount = 5
    animPlayTime = 3000

    -- ==============================================
    -- image swap
    -- ==============================================
    -- btn01Group = display.newGroup()
    
    -- btn01_normal = display.newImageRect( btn01Group, "img/btn01_normal.png", 48, 48 )
    -- btn01_normal.x = display.contentCenterX
    -- btn01_normal.y = display.contentCenterY

    -- btn01_pressed = display.newImageRect( btn01Group, "img/btn01_pressed.png", 48, 48 )
    -- btn01_pressed.x = display.contentCenterX
    -- btn01_pressed.y = display.contentCenterY

    -- btn01_pressed.isVisible = false

    -- btn01Group.whichBtn = "normal"
    -- btn01Group:addEventListener( "touch", handleTouch )

    -- ==============================================
    -- image sheet
    -- ==============================================
    -- animGroup = display.newGroup()
    -- local options = {
    --     width = 280,
    --     height = 385,
    --     numFrames = animFrameAmount,
    --     sheetContentWidth = 1400,
    --     sheetContentHeight = 770
    -- }
    -- local animSheet = graphics.newImageSheet( "img/anim02.png", options )

    -- animSource = { }
    -- for i=1, animFrameAmount do
    --     animSource[i] = display.newImageRect( animSheet, i, 280, 385 )
    --     animSource[i].x = display.contentCenterX
    --     animSource[i].y = display.contentCenterY
    --     animGroup:insert( animSource[i] )
    --     animSource[i].isVisible = false
    -- end

    -- animGroup.currentImg = 1
    -- animSource[animGroup.currentImg].isVisible = true    

    -- ==============================================
    -- image sprite
    -- ==============================================
    local options = {
        width = 280,
        height = 385,
        numFrames = animFrameAmount,
        sheetContentWidth = 1400,
        sheetContentHeight = 770
    }
    local animSheet = graphics.newImageSheet( "img/anim02.png", options )

    local sequenceData = {
        name = "anims",
        start = 1,
        count = animFrameAmount
    }

    animSource = display.newSprite( animSheet, sequenceData )
    animSource:setSequence( "anims" )
    animSource.currentImg = 1
    animSource:setFrame( animSource.currentImg )
    animSource.x = display.contentCenterX
    animSource.y = display.contentCenterY    

    local playFunc = playSpriteAnim
    local playAnimDelayTime = 1000/fps
    timer.performWithDelay( playAnimDelayTime, playFunc, math.floor( fps*animPlayTime*0.001 ) )

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
    local sceneGroup = self.view
    
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene

