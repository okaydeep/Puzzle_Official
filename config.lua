application =
{

	content =
	{
		width = 768,
		height = 1024, 
		scale = "letterBox",
		fps = 30,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
		},
		--]]
	},

	-- notification =
	-- {
	-- 	google =
	-- 	{
	-- 		-- This Project Number (also known as a Sender ID) tells Corona to register this application
	-- 		-- for push notifications with the Google Cloud Messaging service on startup.
	-- 		-- This number can be obtained from the Google API Console at:  https://code.google.com/apis/console
	-- 		projectNumber = "294254660131",
	-- 	},
	-- },

	--[[
	-- Push notifications
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},
	--]]    
}
