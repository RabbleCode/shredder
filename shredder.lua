---------
function shredder:HandleSlashCommand(cmd)
---------
	local characterName = string.lower(cmd)
	if characterName ~= nil and characterName ~= "" then		
		--shredder:CheckSpecificCharacter(characterName);	
		shredder:PrintMessageWithShredderPrefix(ORANGE_FONT_COLOR_CODE.."This feature is not yet implemented.")
	else
		shredder:CheckCurrentCharacter();
	end
end

---------
function shredder:CheckSpecificCharacter(characterName)
---------
	if ShredderCharacterProgress ~= nil then
		if ShredderCharacterProgress[shredder.CurrentRealm] ~= nill then
			local progress = ShredderCharacterProgress[shredder.CurrentRealm][characterName]
			if progress ~= nil then
				shredder:PrintMessageWithShredderPrefix("Entry for "..characterName..GREEN_FONT_COLOR_CODE.." found!")
				return;				
			end
		end
	end		
	shredder:PrintMessageWithShredderPrefix("Entry for "..characterName..RED_FONT_COLOR_CODE.." not found!")
	return;
end

---------
function shredder:CheckCurrentCharacter()
---------
	local playerName = UnitName("player")	
	shredder:PrintHeader(playerName)
	local progress = ShredderCharacterProgress[shredder.CurrentRealm][playerName]	
	if progress == nil then
		progress = {}	
	end
	if shredder:IsMainQuestComplete(playerName) ~= true then				
		progress["IsMainQuestCompleted"] = false;
		for index, chapter in pairs(shredder.MainQuest["chapters"]) do		
			shredder:PrintChapterProgress(chapter)
		end	
	else		
		progress["IsMainQuestCompleted"] = true;
	end
	ShredderCharacterProgress[shredder.CurrentRealm][playerName] = progress
	--print(ShredderCharacterProgress[shredder.CurrentRealm][playerName])	
	return;
end

---------
function shredder:IsMainQuestComplete(characterName)
---------	
	local questID = shredder.MainQuest["id"]	
	if C_QuestLog.IsQuestFlaggedCompleted(questID) then
		shredder:PrintChainComplete(characterName);
		return true;
	elseif IsQuestComplete(questID) then
		shredder:PrintMessage(YELLOW_FONT_COLOR_CODE..shredder.MainQuest["name"]..": "..ORANGE_FONT_COLOR_CODE.." quest is complete and ready for turn in!")
	else
		return false;
	end
end

---------
function shredder:PrintHeader(characterName)
---------
	shredder:PrintMessageWithShredderPrefix("scanning for "..characterName.."...");
	shredder:PrintSeparatorLine();
end

---------
function shredder:PrintChainComplete(characterName)
---------
	shredder:PrintMessageWithShredderPrefix(GREEN_FONT_COLOR_CODE..characterName.." has already completed this quest chain.");
	shredder:PrintSeparatorLine();
end

---------
function shredder:PrintChapterProgress(chapter)
---------		
	if chapter ~= nil then 		
		local hasChapter = GetItemCount(chapter["id"]) > 0
		if hasChapter then
			shredder:PrintMessage(YELLOW_FONT_COLOR_CODE..chapter["name"]..": "..GREEN_FONT_COLOR_CODE.." complete.");			
		else
			local hasAllPages = true;
			local pageMessages = {}			
			for index, page in pairs(chapter["pages"]) do				
				local count = GetItemCount(page)
				if count < 1 then
					hasAllPages = false;
					local _, link = GetItemInfo(page)			
					if link == nil then
						print("Could not find link for item: "..page)
						_, link = GetItemInfo(page)	
					end
					if link ~= nil then
						table.insert(pageMessages,(YELLOW_FONT_COLOR_CODE.."    "..link));
					end
				end
			end			
			if hasAllPages then				
				shredder:PrintMessage(YELLOW_FONT_COLOR_CODE..chapter["name"]..": "..ORANGE_FONT_COLOR_CODE.." Ready for turn in! All pages acquired.");
			else
				shredder:PrintMessage(YELLOW_FONT_COLOR_CODE..chapter["name"]..": "..RED_FONT_COLOR_CODE.." incomplete. Still need:");
				shredder:PrintMessages(pageMessages)
			end
		end
	end	
end

---------
function shredder:PrintMessageWithShredderPrefix(message)
---------
	shredder:PrintMessage(YELLOW_FONT_COLOR_CODE.."SHREDDER |r"..message)
end
---------
function shredder:PrintMessage(message)
---------
	DEFAULT_CHAT_FRAME:AddMessage(message)
end

---------
function shredder:PrintMessages(messages)
---------
	if messages ~= nil then
		for index, message in pairs(messages) do
			shredder:PrintMessage(message)
		end
	end
end

---------
function shredder:PrintFooter(completed)
---------
	shredder:PrintSeparatorLine();
end

---------
function shredder:PrintSeparatorLine()
---------
	DEFAULT_CHAT_FRAME:AddMessage("---------------------------|r");
end