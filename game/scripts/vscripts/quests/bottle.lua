QuestBottle = class( {}, nil, Quest )

function QuestBottle:constructor( player, questName, units )
	Quest.constructor( self, player, questName, {}, nil, true )

	local targets = {
		"npc_au_quest_bottle_1",
		"npc_au_quest_bottle_2",
		"npc_au_quest_bottle_1",
		"npc_au_quest_bottle_3"
	}

	self.stepCount = 4
	self.stepNow = 1
	self.targets = {}

	for _, unit in pairs( units ) do
		local unitName = unit:GetUnitName()

		for i, targetName in pairs( targets ) do
			if unitName == targetName then
				self.targets[i] = unit
				targets[i] = nil
			end
		end
	end

	self:SetMinigameType()
end

function QuestBottle:MinigameCompleted()
	Quest.MinigameCompleted( self )

	self:SetMinigameType()
end

function QuestBottle:SetMinigameType()
	local types = {
		AU_MINIGAME_BOTTLE_1,
		AU_MINIGAME_BOTTLE_2,
		AU_MINIGAME_BOTTLE_3,
		AU_MINIGAME_BOTTLE_4
	}

	self.minigame.type = types[self.stepNow]
end