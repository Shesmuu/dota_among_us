QuestOxygen = class( {}, nil, GlobalQuest )

function QuestOxygen:constructor( ... )
	GlobalQuest.constructor( self, ... )

	self.questCompletes = {}
	self.questPlayerMinigames = {}
end

function QuestOxygen:Trigger( unit, activator )
	if self.questCompletes[unit.questUnitIndex] then
		return
	end

	GlobalQuest.Trigger( self, unit, activator )

	self.questPlayerMinigames[activator.id] = unit.questUnitIndex
end

function QuestOxygen:MinigameResult( data )
	if data.completed == 1 then
		local unitIndex = self.questPlayerMinigames[data.PlayerID]

		if unitIndex and not self.questCompletes[unitIndex] then
			self.questCompletes[unitIndex] = true

			if self.effects[unitIndex] then
				ParticleManager:DestroyParticle( self.effects[unitIndex], false )
			end

			self.stepNow = self.stepNow + 1

			if self.stepNow > self.stepCount then
				self:Destroy( true )
			else
				for id, index in pairs( self.questPlayerMinigames ) do
					if unitIndex == index then
						GameMode.players[id]:SetMinigame()
					end
				end

				Quests:NetTable()
			end
		end
	elseif data.failure == 1 then
		GameMode.players[data.PlayerID]:SetMinigame()
	end
end

SabotageOxygen = class( {}, nil, BaseSabotage )

function SabotageOxygen:OnStart()
	QuestOxygen( "oxygen", AU_MINIGAME_OXYGEN, self, 2 )
end