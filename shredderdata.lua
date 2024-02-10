function shredder:LoadData()

	ShredderCharacterProgress = ShredderCharacterProgress or {}

	shredder.CurrentRealm = GetRealmName();

	shredder.MainQuest = {
		["id"] = 6504,
		["name"] = "The Lost Pages",
		["minimumlevel"] = 23,
		["chapters"] = {
			{
				["id"] = 16642,
				["name"] = "Chapter I",
				["pages"] = {				
					16645, -- Page 1
					16646, -- Page 2
					16647, -- Page 3
					16648 -- Page 4
				}
			},
			{
				["id"] = 16643,
				["name"] = "Chapter II",
				["pages"] = {				
					16649, -- Page 5
					16650, -- Page 6
					16651, -- Page 7
					16652 -- Page 8
				}
			},
			{
				["id"] = 16644,
				["name"] = "Chapter III",
				["pages"] = {				
					16653, -- Page 9
					16654, -- Page 10
					16655, -- Page 11
					16656 -- Page 12
				}
			}
		}
	}

	ShredderCharacterProgress = {	
		[shredder.CurrentRealm] = {}	
		-- 	["server"] = {
		-- 		["name"] = {
		-- 			["pages"] = {}
		-- 			["quests"] = {}
		--		}
		-- }
	}
end