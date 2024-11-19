shredder = {};


function shredder:OnLoad()
	SLASH_SHREDDER1 = "/shredder";
	SLASH_SHREDDERC1 = "/shredderc";
	SLASH_SHREDDERC2 = "/sc";
	SlashCmdList["SHREDDER"] = function(msg) shredder:HandleSlashCommand(msg, false) end
	SlashCmdList["SHREDDERC"] = function(msg) shredder:HandleSlashCommand(msg, true) end

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
		shredder:LoadQuestData();
		shredder:LoadPlayerData();
		shredder:LoadAccountData();
		shredder:PrimeItemCache();
		shredder:Announce();		
		shredder:UpdatePlayerProgress();
	elseif event == "PLAYER_LOGOUT" then
		shredderFrame:UnregisterEvent("PLAYER_LOGOUT");
		shredder:UpdatePlayerProgress();
	end
end


function shredder:LoadPlayerData()

	shredder.CurrentRealm = GetRealmName();
	shredder.PlayerName = UnitName("player");
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


-- Calls GetItemInfo on all related quest items to prime the local cache
function shredder:PrimeItemCache()
	if(shredder.QuestData ~= nil) then
		for index, chapter in pairs(shredder.QuestData.Chapters) do			
			local _, link = GetItemInfo(chapter.ItemID)	

			-- Get chapter pages
			for index, page in pairs(chapter.Pages) do				
				local _, link = GetItemInfo(page)		
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