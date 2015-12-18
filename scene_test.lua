---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )
require( "GlobalManager" ) 
gm = GlobalManager

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

local obj1
local bigTable

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view
    
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase    

    if phase == "will" then
        bigTable = {}

        local mt = setmetatable({}, {
            __index = function()
                return "none!!"
            end,
            __add = function(a, b)                
                return { value = a.value + b.value }
            end
        })

        local table1 = setmetatable({value = 5}, {__index = mt})            
        local table2 = setmetatable({}, {__index = table1})

        --local table2 = getmetatable(table1).__add(table1, table1)

        print (table2['value'])
        print (table2["value"])
        print (table2[1])

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

local function showMemUsed()
    print("System Memory: " .. string.format("%.00f", collectgarbage("count")) .. " KB")
end
timer.performWithDelay( 1000, showMemUsed, -1 )

local function copyTable()    
    local table = {a=1, b=2, t={c=3, d=4}}

    for i=1, 200 do
        bigTable[i] = gm.deepCopy(table)
    end

    print("Copy Finish!")
end
timer.performWithDelay( 3000, copyTable )

local function clearTable()
    local function clear (t)
        for k, v in pairs(t) do
            if (type(v) ~= "table") then
                t[k] = nil
            else
                clear(t[k])
            end
        end
    end

    clear(bigTable)

    print("Clear Finish!")
end
--timer.performWithDelay( 5000, clearTable )

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
