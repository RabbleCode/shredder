shredder = {};

function shredder:OnLoad()
	SLASH_SHREDDER1 = "/shredder";
	SLASH_SHREDDERC1 = "/shredderc";
	SLASH_SHREDDERC2 = "/sc";
	SLASH_SHREDDERV1 = "/shredderv"
	SLASH_SHREDDERV2 = "/sv"
	SlashCmdList["SHREDDER"] = function(msg) shredder:HandleSlashCommand(msg, true) end
	SlashCmdList["SHREDDERC"] = function(msg) shredder:HandleSlashCommand(msg, true) end
	SlashCmdList["SHREDDERV"] = function(msg) shredder:HandleSlashCommand(msg, false) end

	shredderFrame:RegisterEvent("PLAYER_LOGIN")
	shredderFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	shredderFrame:RegisterEvent("ADDON_LOADED")
end


function shredder:OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...
	if event == "ADDON_LOADED" and arg1 == "shredder" then
		shredderFrame:UnregisterEvent("ADDON_LOADED");
	elseif event == "PLAYER_LOGIN" then
		shredderFrame:UnregisterEvent("PLAYER_LOGIN");
		shredder:LoadGameVersionData();
		shredder:LoadQuestData();
		shredder:LoadPlayerData();
		shredder:LoadAccountData();
		if(shredder.IsForever) then
			shredder:CleanUpRealmDataAfterAPIChange();
		end
		shredder:PrimeItemCache();
		shredder:Announce();		
		shredder:UpdatePlayerProgress();
	elseif event == "PLAYER_LOGOUT" then
		shredderFrame:UnregisterEvent("PLAYER_LOGOUT");
		shredder:UpdatePlayerProgress();
	end
end

function shredder:LoadGameVersionData()

	shredder.IsForever = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
	shredder.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

function shredder:LoadPlayerData()

	shredder.CurrentRealm = GetRealmName();
	shredder.PlayerName, shredder.PlayerLastName = UnitName("player");
	if(shredder.IsForever) then -- Accounting for Forever's dual names and "realmlessness"
		shredder.HideRealmName = true
		shredder.PlayerName = shredder.PlayerName..' '..shredder.PlayerLastName
		shredder.CurrentRealm = 'Forever' -- API changes no longer return realm name on Forever, and names are unique across regions anyway
	end
	shredder.PlayerClass = UnitClass("player");
	shredder.PlayerFaction = UnitFactionGroup("player");
	shredder.PlayerLevel = UnitLevel("player");
	shredder.PlayerNameWithRealm = shredder.CurrentRealm.." - "..shredder.PlayerName
	shredder.PlayerProgress = {}
end


function shredder:LoadAccountData()
	if(ShredderCharacterProgress == nil) then 
		ShredderCharacterProgress = {} 
	end

	if(ShredderCharacterProgress[shredder.CurrentRealm] == nil) then
		ShredderCharacterProgress[shredder.CurrentRealm] = {}
	end
end

function shredder:CleanUpRealmDataAfterAPIChange()

	-- API Change with 1.60.1 Forever patch changed GetRealmName() to return empty string
	-- causing the addon to store character data in a different, empty key instead of by realm name
	-- The addon is now fixed to store character data for Forever in key "Forever", but we need to
	-- clean up the old data that was stored in "CAMWOW..." realm keys and then in the empty realm key

	-- Import then delete any data stored in that interim empty key first, as that's more recent then "CAMWOW" realm data
	if(ShredderCharacterProgress[""] ~= nil) then
		ShredderCharacterProgress[shredder.CurrentRealm] = ShredderCharacterProgress[""]
		ShredderCharacterProgress[""] = nil
	end

	-- Then import "CAMWOW" data if needed and delete "CAMWOW" data
	for realm, data in pairs(ShredderCharacterProgress) do
		if(string.find(realm,"CAMWOW",1, true) and realm ~= nil) then
			if(ShredderCharacterProgress[shredder.CurrentRealm] == nil) then
				ShredderCharacterProgress[shredder.CurrentRealm] = ShredderCharacterProgress[realm]
			end
			ShredderCharacterProgress[realm] = nil
		end
	end

end

-- Calls GetItemInfo on all related quest items to prime the local cache
function shredder:PrimeItemCache()
	if(shredder.QuestData ~= nil) then
		for index, chapter in pairs(shredder.QuestData.Chapters) do			
			local _, link = shredder:GetItemInfo(chapter.ItemID)	

			-- Get chapter pages
			for index, page in pairs(chapter.Pages) do				
				local _, link = shredder:GetItemInfo(page)		
			end	
		end
	end
end

---------
function shredder:Announce()
---------
	if(shredder.PlayerFaction ~= "Horde") then
		shredder:PrintMessageWithShredderPrefix("Quest is not available for "..BLUE_FONT_COLOR_CODE.."Alliance|r characters.")
	else
		shredder:PrintMessageWithShredderPrefix("activated.")
	end
end