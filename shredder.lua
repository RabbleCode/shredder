function shredder:HandleSlashCommand(cmd, compactMode)
	shredder.DebugMode = false	
 	if cmd ~= nil and cmd ~= "" then
		if (cmd == "debug") then					
			shredder.DebugMode = true
			shredder:UpdatePlayerProgress()
		else	
			local character, realm = shredder:GetCharacterAndRealm(cmd)
			if(realm ~= nil) then
				shredder:CheckSpecificCharacter(character, realm, compactMode);
			else
				shredder:CheckSpecificCharacter(character, shredder.CurrentRealm, compactMode);
			end		
		end
	else
		shredder:UpdatePlayerProgress();
		shredder:PrintCharacterProgress(shredder.PlayerName, shredder.CurrentRealm, compactMode)
	end
end


function shredder:GetCharacterAndRealm(arguments)
	local character, realm = arguments:match("^(%S*)%s*(.-)$")
	character = shredder:ConvertToTitleCase(character)
	if(realm ~= nil and realm ~= '') then
		realm = shredder:ConvertToTitleCase(realm)	
	else
		realm = nil
	end
	return character, realm
end

function shredder:GetClassColor(class)
	class = string.upper(class)
	local colorStr = RAID_CLASS_COLORS[class]["colorStr"] or YELLOW_FONT_COLOR_CODE
	return "|c"..colorStr
end

function shredder:GetClassColoredName(class, character, realm)
	return shredder:GetClassColor(class)..character.."|r"..YELLOW_FONT_COLOR_CODE.." - "..realm
end

function shredder:ConvertToTitleCase(text)
	return string.gsub(text, "(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end)
end


function shredder:CheckSpecificCharacter(character, realm, compactMode)
	local name = character.." - "..realm
	local progress = nil

	if ShredderCharacterProgress[realm] ~= nil and ShredderCharacterProgress[realm][character] ~= nil then
		progress = ShredderCharacterProgress[realm][character]
	end
		
	if progress ~= nil then
		shredder:PrintCharacterProgress(character, realm, compactMode)	
	else		
		shredder:PrintMessageWithShredderPrefix("Entry for "..character..RED_FONT_COLOR_CODE.." not found!")
	end
end


function shredder:SavePlayerProgress()

	if(ShredderCharacterProgress[shredder.CurrentRealm] ~= nil) then
		-- Delete character progress if it's nil
		if(shredder.PlayerProgress == nil) then
			ShredderCharacterProgress[shredder.CurrentRealm][shredder.PlayerName] = nil
		-- Delete character progress if there is no main quest or chapter progress
		-- elseif (shredder.PlayerProgress["completed"] == nil and shredder.PlayerProgress["ready"] == nil and shredder.PlayerProgress["chapters"] == nil) then
		-- 	ShredderCharacterProgress[shredder.CurrentRealm][shredder.PlayerName] = nil
		-- Save character progress
		else			
			ShredderCharacterProgress[shredder.CurrentRealm][shredder.PlayerName] = shredder.PlayerProgress
		end

		-- After updating character progress, check if there are any characters recorded on this realm
		local hasRealmProgress = false
		for _,_ in pairs(ShredderCharacterProgress[shredder.CurrentRealm]) do	
			hasRealmProgress = true;
			break;
		end

		-- If there are no recorded characters on this realm, delete the realm too
		if(hasRealmProgress == false) then
			ShredderCharacterProgress[shredder.CurrentRealm] = nil
		end
	end
end


function shredder:UpdatePlayerProgress()

	if(shredder.QuestData ~= nil and shredder.QuestData.Chapters ~= nil) then
		shredder:LoadPlayerData()
		shredder.PlayerProgress.Faction = shredder.PlayerFaction
		shredder.PlayerProgress.Level = shredder.PlayerLevel
		shredder.PlayerProgress.Class = shredder.PlayerClass

		local questID = shredder.QuestData.QuestID

		-- Quest is already completed and turned in
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			shredder.PlayerProgress.Completed = true
		-- Quest is complete and ready to be turned in
		elseif IsQuestComplete(questID) then
			shredder.PlayerProgress.Ready = true
		-- Quest is not yet complete, check each individual chapter
		else
			shredder:UpdateChapterProgress()
		end
		
		shredder:SavePlayerProgress();
	else
		shredder:PrintMessageWithShredderPrefix(RED_FONT_COLOR_CODE.."Quest information corrupted. Please reinstall the addon.")
	end
end


function shredder:UpdateChapterProgress()
	if(shredder.QuestData ~= nil and shredder.QuestData.Chapters ~= nil) then
		chapters = 0
		for _, chapter in pairs(shredder.QuestData.Chapters) do

			local hasChapter = GetItemCount(chapter.ItemID) > 0
			local hasPages = false
			local hasAllPages = true
			local pages = {}

			-- If chapter incomplete, retrieve progress on individual pages
			if not hasChapter then
				hasPages, hasAllPages, pages = shredder:FindCollectedPages(chapter)
			end

			local chapterProgress = {}

			-- Cache data only if there's something to cache
			if(hasChapter) then
				chapters = chapters + 1;
				chapterProgress.Completed = true
			elseif(hasAllPages) then
				chapters = chapters + 1;
				chapterProgress.Ready = true;
			elseif(hasPages) then
				chapters = chapters + 1;
				chapterProgress.Pages = pages			
			else
				chapterProgress = nil
			end


			-- If progress on this chapter
			if(chapterProgress ~= nil) then
				-- Make sure the base Chapters node isn't empty
				if(shredder.PlayerProgress.Chapters == nil) then
					shredder.PlayerProgress.Chapters = {}
				end
				-- And update the node for this chapter
				shredder.PlayerProgress.Chapters[chapter.ItemID] = chapterProgress
			-- If no progress on this chapter, remove the node for this chapter if it exists
			elseif(shredder.PlayerProgress.Chapters ~= nil) then
				shredder.PlayerProgress.Chapters[chapter.ItemID] = nil	
			end
		end

		-- If no progress on any chapters, remove the entire Chapters node
		if(chapters == 0) then
			shredder.PlayerProgress.Chapters = nil
		end
	else
		shredder:PrintMessageWithShredderPrefix(RED_FONT_COLOR_CODE.."Quest information corrupted. Please reinstall the addon.")
	end
end

function shredder:FindCollectedPages(chapter)
	local hasPages = false
	local hasAllPages = true
	local pages = {}
	for _, pageID in pairs(chapter.Pages) do			
		if GetItemCount(pageID) > 0 then
			hasPages = true;
			pages[pageID] = true					
		else
			hasAllPages = false
		end
	end

	return hasPages, hasAllPages, pages
end

function shredder:PrintCharacterProgress(character, realm, compactMode)

	local realmProgress = ShredderCharacterProgress[realm]
	local characterProgress 
	if(realmProgress ~= nil) then
		characterProgress = ShredderCharacterProgress[realm][character]
	end
	-- Progress flags
	local hasProgress = characterProgress ~= nil
	local isCompleted = hasProgress and characterProgress.Completed == true
	local isReady = hasProgress and characterProgress.Ready == true
	
	-- Character info
	local faction = characterProgress.Faction or "UNKNOWN"
	local level = characterProgress.Level or 0
	local class = characterProgress.Class or "UNKNOWN"

	local classColoredName = shredder:GetClassColoredName(class, character, realm)

	if(faction == "Alliance") then
		shredder:PrintMessageWithShredderPrefix("Quest is not available for "..BLUE_FONT_COLOR_CODE.."Alliance|r characters.")
	--elseif(level > 0 and level < shredder.QuestData.MinimumLevel ) then
		--shredder:PrintMessageWithShredderPrefix("Quest is not available until level "..RED_FONT_COLOR_CODE..shredder.QuestData.MinimumLevel)	
	elseif(isCompleted) then
		shredder:PrintMessageWithShredderPrefix("Quest "..GREEN_FONT_COLOR_CODE.."already completed|r for "..classColoredName);
	elseif(isReady) then
		shredder:PrintMessageWithShredderPrefix("Quest "..ORANGE_FONT_COLOR_CODE.."ready for turn in|r for "..classColoredName);
	else
		shredder:PrintMessageWithShredderPrefix("Quest "..RED_FONT_COLOR_CODE.."incomplete|r for "..classColoredName);
		if(compactMode) then
			shredder:PrintCompactChaptersProgress(characterProgress)
		else
			shredder:PrintChaptersProgress(characterProgress)
		end
	end
end

function shredder:PrintChaptersProgress(progress)
	for _, chapter in pairs(shredder.QuestData.Chapters) do

		local itemID = chapter.ItemID
		local name, link = GetItemInfo(itemID)
		local hasProgress = progress ~= nil and progress.Chapters ~= nil and progress.Chapters[itemID] ~= nil

		-- if character has recorded progress
		if(hasProgress) then
			local chapterProgress = progress.Chapters[itemID]
			-- if chapter is already completed
			if(chapterProgress.Completed == true) then
				shredder:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name..": "..GREEN_FONT_COLOR_CODE.."collected!")
			-- else if chapter is ready for turn in
			elseif(chapterProgress.Ready == true) then
				shredder:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name..": "..ORANGE_FONT_COLOR_CODE.."ready to make.") 
			-- else if chapter is incomplete
			else
				shredder:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name)
				shredder:PrintPagesProgress(chapter, chapterProgress)
			end
		else
			-- no recorded progress
			shredder:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name)
			shredder:PrintPagesProgress(chapter, nil)
		end
	end
end

function shredder:PrintPagesProgress(chapterData, chapterProgress)
	for _, pageID in pairs(chapterData.Pages) do
		local _, link = GetItemInfo(pageID)
		if(chapterProgress and chapterProgress.Pages and chapterProgress.Pages[pageID] == true) then
			shredder:PrintMessage("    "..link..": "..GREEN_FONT_COLOR_CODE.."collected")
		else
			shredder:PrintMessage("    "..link..": "..RED_FONT_COLOR_CODE.."missing")
		end
	end
end

function shredder:PrintCompactChaptersProgress(progress)

	for _, chapter in pairs(shredder.QuestData.Chapters) do

		local itemID = chapter.ItemID
		local name = chapter.Name
		local hasProgress = progress ~= nil and progress.Chapters ~= nil and progress.Chapters[itemID] ~= nil

		-- if character has recorded progress
		if(hasProgress) then
			local chapterProgress = progress.Chapters[itemID]
			-- if chapter is already completed
			if(chapterProgress.Completed == true) then
				shredder:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name..": "..GREEN_FONT_COLOR_CODE.."completed!")
			-- else if chapter is ready for turn in
			elseif(chapterProgress.Ready == true) then
				shredder:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name..": "..ORANGE_FONT_COLOR_CODE.."ready for turn in.") 
			-- else if chapter is incomplete
			else
				local pagesProgress = shredder:GetCompactPagesProgress(chapter, chapterProgress)
				shredder:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name..': '..pagesProgress)
			end
		else
			-- no recorded progress
				local pagesProgress = shredder:GetCompactPagesProgress(chapter, nil)
				ghost:PrintMessage("  "..YELLOW_FONT_COLOR_CODE..name..': '..pagesProgress)
		end
	end
end

function shredder:GetCompactPagesProgress(chapterData, chapterProgress)

	local progress = ''
	local count = 0
	
	for _, pageID in pairs(chapterData.Pages) do
		count = count + 1
		local name, link = GetItemInfo(pageID)
		local pageNumber = string.match(name,'%d[%d]?')
		if(count > 1) then
			progress = progress..', '
		end
		if(chapterProgress and chapterProgress.Pages and chapterProgress.Pages[pageID] == true) then
			progress = progress..GREEN_FONT_COLOR_CODE..pageNumber..'|r'
		else
			progress = progress..RED_FONT_COLOR_CODE..pageNumber..'|r'
		end
	end
	return progress
end



function shredder:PrintMessageWithShredderPrefix(message)

	shredder:PrintMessage(YELLOW_FONT_COLOR_CODE.."SHREDDER |r| "..message)
end

function shredder:PrintWrongFactionMessage()
	
end


function shredder:PrintHeader(characterName)
	shredder:PrintMessageWithShredderPrefix("progress for "..YELLOW_FONT_COLOR_CODE..characterName.."|r...");	
end


function shredder:PrintDebugMessage(message)
	if(shredder.DebugMode) then		
		shredder:PrintMessage(message)
	end
end


function shredder:PrintDebugData()
	for k1,v1 in pairs(ShredderCharacterProgress) do		
		shredder:PrintDebugMessage("[\""..k1.."\"]")
		for k2,v2 in pairs(v1) do
			shredder:PrintDebugMessage("  [\""..k2.."\"]")
			for k3,v3 in pairs(v2) do
				shredder:PrintDebugMessage("    [\""..k3.."\"]: "..tostring(v3))			
				if(type(v3) == "table") then
					for k4,v4 in pairs(v3) do
						shredder:PrintDebugMessage("      [\""..k4.."\"]: "..tostring(v4))
					end
				end
			end
		end
	end
end


function shredder:PrintMessage(message)

	DEFAULT_CHAT_FRAME:AddMessage(message)
end