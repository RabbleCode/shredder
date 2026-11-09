function shredder:GetQuestTitle(questID)
    if(C_QuestLog.GetQuestInfo ~= nil) then -- Classic Era
        return C_QuestLog.GetQuestInfo(questID)
    elseif(C_QuestLog.GetTitleForQuestID ~= nil) then -- Forever
        return C_QuestLog.GetTitleForQuestID(questID)
    else
        return "";
    end
end

function shredder:IsQuestCompleted(questID)

	if(C_QuestLog.IsQuestFlaggedCompleted ~= nil) then
		return C_QuestLog.IsQuestFlaggedCompleted(questID)
	else
		return false;
    end
end

function shredder:IsQuestReadyForTurnIn(questID)
	if(IsQuestComplete ~= nil) then -- Classic Era
		return IsQuestComplete(questID)
	elseif(C_QuestLog.IsComplete ~= nil) then -- Forever
		return C_QuestLog.IsComplete(questID)
	else
		return false;
    end
end

function shredder:IsQuestActive(questID)

    if(GetQuestLogIndexByID ~= nil) then -- Classic Era
        return GetQuestLogIndexByID(questID) or 0 > 0
    elseif(C_QuestLog.GetLogIndexForQuestID ~= nil) then -- Forever
        return C_QuestLog.GetLogIndexForQuestID(questID) or 0 > 0
    else
        return false;
    end
end

function shredder:GetItemInfo(itemID)
    if(GetItemInfo ~= nil) then -- Classic Era
        return GetItemInfo(itemID)
    elseif(C_Item.GetItemInfo ~= nil) then -- Forever
        return C_Item.GetItemInfo(itemID)
    end
end

function shredder:GetItemCount(itemID)
    if(GetItemCount ~= nil) then -- Classic Era
        return GetItemCount(itemID)
    elseif(C_Item.GetItemCount ~= nil) then -- Forever
        return C_Item.GetItemCount(itemID)
    else
        return 0;
    end
end