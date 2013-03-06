application = {
	content = {
		width = 320,
		height = 480, 
		scale = "letterbox",
		
		imageSuffix =
        {
            ["@1-5"] = 1.5, -- for Droid, Nexus One, etc.
            ["@2x"] = 2,    -- for iPhone, iPod touch, iPad1, and iPad2
            ["@3x"] = 3,    -- for various mid-size Android tablets
            ["@4x"] = 4,    -- for iPad 3
        }
	},

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
    }
    --]]    
}
