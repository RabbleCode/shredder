shredder = {};

---------
function shredder:OnLoad()
---------
	SLASH_SHREDDER1 = "/shredder";
	SlashCmdList["SHREDDER"] = function(msg) shredder:HandleSlashCommand(msg) end

	shredderFrame:RegisterEvent("PLAYER_LOGIN")
	shredderFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	shredderFrame:RegisterEvent("ADDON_LOADED")
end

---------
function shredder:OnEvent(self, event, ...)
---------
	local arg1, arg2, arg3, arg4 = ...
	if event == "ADDON_LOADED" and arg1 == "shredder" then
		shredderFrame:UnregisterEvent("ADDON_LOADED");
	elseif event == "PLAYER_LOGIN" then
		shredderFrame:UnregisterEvent("PLAYER_LOGIN");
		shredder:LoadData();
		shredder:PrimeItemCache();
		shredder:Announce();		
	elseif event == "PLAYER_ENTERING_WORLD" then
		shredderFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
end

-- Calls GetItemInfo on all related quest items to prime the local cache
---------
function shredder:PrimeItemCache()
---------
	-- Get main quest items
	for index, chapter in pairs(shredder.MainQuest["chapters"]) do			
		local _, link = GetItemInfo(chapter["id"])	

		-- Get chapter pages
		for index, page in pairs(chapter["pages"]) do				
			local _, link = GetItemInfo(page)		
		end	
	end
end

---------
function shredder:Announce()
---------
	if(shredder:FactionCheck()) then
		DEFAULT_CHAT_FRAME:AddMessage(YELLOW_FONT_COLOR_CODE.."SHREDDER |ractivated. ");
	end
end