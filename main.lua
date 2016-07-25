---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- require the composer library
local composer = require "composer"

-- load scene1
composer.gotoScene( "scene_puzzle_main" )
-- composer.gotoScene( "scene_test" )
-- composer.gotoScene( "scene_test_swapimage" )
-- composer.gotoScene( "scene_test_camera" )

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)

