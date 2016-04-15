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
local googleApiKey = "AIzaSyAMXC_HDPyZdopIlEFDVkzIrRJY9ZKFd3c"
local googleRegistrationId = nil

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    -- local co = coroutine.create(function()
    --     local idx = 1
    --     while true do
    --         print(idx.."!!")
    --         idx = idx+1
    --         coroutine.yield()
    --     end
    -- end)

    -- for i=1, 10 do
    --     coroutine.resume(co)
    -- end
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase    

    if phase == "will" then
        -- bigTable = {}

        -- local mt = setmetatable({}, {
        --     __index = function()
        --         return "none!!"
        --     end,
        --     __add = function(a, b)                
        --         return { value = a.value + b.value }
        --     end
        -- })

        -- local table1 = setmetatable({value = 5}, {__index = mt})            
        -- local table2 = setmetatable({}, {__index = table1})

        -- --local table2 = getmetatable(table1).__add(table1, table1)

        -- print (table2['value'])
        -- print (table2["value"])
        -- print (table2[1])

        -- local t1 = {a=1, b=2, tt={ta=3, tb=4}, img}
        -- local t2 = {a=10, b=20, tt={ta=30, tb=40}, img}
        -- local copyT = gm.deepCopy(t1)

        -- print(copyT.tt.ta)

        -- copyT = gm.deepCopy(t2)

        -- print(copyT.tt.ta)

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
--timer.performWithDelay( 1000, showMemUsed, -1 )

local function copyTable()    
    local table = {a=1, b=2, t={c=3, d=4}}

    for i=1, 2000 do
        bigTable[i] = gm.deepCopy(table)
    end

    print("Copy Finish!")
end
--timer.performWithDelay( 3000, copyTable )

local function clearTable()
    -- local function clear (t)
    --     for k, v in pairs(t) do
    --         if (type(v) ~= "table") then
    --             t[k] = nil
    --         else
    --             clear(t[k])
    --         end
    --     end
    -- end

    -- clear(bigTable)

        

    collectgarbage()

    print("Clear Finish!")
end
--timer.performWithDelay( 5000, clearTable )

-- Called when a sent notification has succeeded or failed.
local function onSendNotification(event)
    local errorMessage = nil

    -- Determine if we have successfully sent the notification to Google's server.
    if event.isError then
        -- Failed to connect to the server.
        -- This typically happens due to lack of Internet access.
        errorMessage = "Failed to connect to the server."

    elseif event.status == 200 then
        -- A status code of 200 means that the notification was sent succcessfully.
        print("Notification was sent successfully.")

    elseif event.status == 400 then
        -- There was an error in the sent notification's JSON data.
        errorMessage = event.response

    elseif event.status == 401 then
        -- There was a user authentication error.
        errorMessage = "Failed to authenticate the sender's Google Play account."

    elseif (event.status >= 500) and (event.status <= 599) then
        -- The Google Cloud Messaging server failed to process the given notification.
        -- This indicates an internal error on the server side or the server is temporarily unavailable.
        -- In this case, we are supposed to silently fail and try again later.
        errorMessage = "Server failed to process the request. Please try again later."
    end

    -- Display an error message if there was a failure.
    if errorMessage then
        native.showAlert("Notification Error", errorMessage, { "OK" })
    end
end

-- Sends the given JSON message to the Google Cloud Messaging server to be pushed to Android devices.
local function sendNotification(jsonMessage)
    -- Do not continue if a Google API Key was not provided.
    if not googleApiKey then
        return
    end

    -- Print the JSON message to the log.
    print("--- Sending Notification ----")
    print(jsonMessage)

    -- Send the push notification to this app.
    local url = "https://android.googleapis.com/gcm/send"
    local parameters =
    {
        headers =
        {
            ["Authorization"] = "key=" .. googleApiKey,
            ["Content-Type"] = "application/json",
        },
        body = jsonMessage,
    }
    network.request(url, "POST", onSendNotification, parameters)
end

-- Sends a push notification when the screen has been tapped.
local function onTap(event)
    -- Do not continue if this app has not been registered for push notifications yet.
    if not googleRegistrationId then
        return
    end

    -- Set up a JSON message to send a push notification to this app.
    -- The "registration_ids" tells Google to whom this push notification should be delivered to.
    -- The "alert" field sets the message to be displayed when the notification has been received.
    -- The "sound" field is optional and will play a sound file in the app's ResourceDirectory.
    -- The "custom" field is optional and will be delivered by the notification event's "event.custom" property.
    local jsonMessage =
[[
{
    "registration_ids": ["]] .. tostring(googleRegistrationId) .. [["],
    "data":
    {
        "alert": "Hello World!",
        "sound": "notification.wav",
        "custom":
        {
            "boolean": true,
            "number": 123.456,
            "string": "Custom data test.",
            "array": [ true, false, 0, 1, "", "This is a test." ],
            "table": { "x": 1, "y": 2 }
        }
    }
}
]]
    sendNotification(jsonMessage)
end
Runtime:addEventListener("tap", onTap)

-- Prints all contents of a Lua table to the log.
local function printTable(table, stringPrefix)
    if not stringPrefix then
        stringPrefix = "### "
    end
    if type(table) == "table" then
        for key, value in pairs(table) do
            if type(value) == "table" then
                print(stringPrefix .. tostring(key))
                print(stringPrefix .. "{")
                printTable(value, stringPrefix .. "   ")
                print(stringPrefix .. "}")
            else
                print(stringPrefix .. tostring(key) .. ": " .. tostring(value))
            end
        end
    end
end

-- Called when a notification event has been received.
local function onNotification(event)
    if event.type == "remoteRegistration" then
        -- This device has just been registered for Google Cloud Messaging (GCM) push notifications.
        -- Store the Registration ID that was assigned to this application by Google.
        googleRegistrationId = event.token

        -- Display a message indicating that registration was successful.
        local message = "This app has successfully registered for Google push notifications."
        native.showAlert("Information", message, { "OK" })

        -- Print the registration event to the log.
        print("### --- Registration Event ---")
        printTable(event)

    else
        -- A push notification has just been received. Print it to the log.
        print("### --- Notification Event ---")
        printTable(event)
    end
end

-- Set up a notification listener.
Runtime:addEventListener("notification", onNotification)

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
