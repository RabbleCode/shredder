function shredder:LoadQuestData()

	local Chapter1 = {}
	Chapter1.ItemID = 16642
	Chapter1.Name = "Chapter I"
	Chapter1.Pages = {				
		16645, -- Page 1
		16646, -- Page 2
		16647, -- Page 3
		16648 -- Page 4
	}

	local Chapter2 = {}				
	Chapter2.ItemID = 16643
	Chapter2.Name = "Chapter II"
	Chapter2.Pages = {				
			16649, -- Page 5
			16650, -- Page 6
			16651, -- Page 7
			16652 -- Page 8
	}

	local Chapter3 = {}
	Chapter3.ItemID = 16644
	Chapter3.Name = "Chapter III"
	Chapter3.Pages = {				
				16653, -- Page 9
				16654, -- Page 10
				16655, -- Page 11
				16656 -- Page 12
		}
		

	shredder.QuestData = {}
	shredder.QuestData.QuestID = 6504
	shredder.QuestData.Name = "The Lost Pages"
	shredder.QuestData.MinimumLevel = 23
	shredder.QuestData.Chapters = {	Chapter1, Chapter2, Chapter3}
		-- {
		-- 	["id"] = 16642,
		-- 	["name"] = "Chapter I",
		-- 	["pages"] = {				
		-- 		16645, -- Page 1
		-- 		16646, -- Page 2
		-- 		16647, -- Page 3
		-- 		16648 -- Page 4
		-- 	}
		-- },
		-- {
		-- 	["id"] = 16643,
		-- 	["name"] = "Chapter II",
		-- 	["pages"] = {				
		-- 		16649, -- Page 5
		-- 		16650, -- Page 6
		-- 		16651, -- Page 7
		-- 		16652 -- Page 8
		-- 	}
		-- },
		-- {
		-- 	["id"] = 16644,
		-- 	["name"] = "Chapter III",
		-- 	["pages"] = {				
		-- 		16653, -- Page 9
		-- 		16654, -- Page 10
		-- 		16655, -- Page 11
		-- 		16656 -- Page 12
		-- 	}
		-- }
	--}
end