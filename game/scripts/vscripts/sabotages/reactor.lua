QuestReactor = class( {}, nil, GlobalQuest )

function QuestReactor:constructor( ... )
	GlobalQuest.constructor( self, ... )

	self.minigame.failure = function( player )
		self:MinigameResult( {
			PlayerID = player.id,
			failure = 1,
			done = true
		} )
	end
	self.questCompletes = {}
	self.questPlayerMinigames = {}

	for i, unit in pairs( self.sabotage.units ) do
		self.questCompletes[i] = {}
	end
end

function QuestReactor:Trigger( unit, activator )
	GlobalQuest.Trigger( self, unit, activator )

	self.questPlayerMinigames[activator.id] = unit.questUnitIndex
end

function QuestReactor:MinigameResult( data )
	local unitIndex = self.questPlayerMinigames[data.PlayerID]
	
	if not unitIndex or not self.questCompletes[unitIndex] then
		if not data.done then
			GameMode.players[data.PlayerID]:SetMinigame()
		end

		return
	end

	if data.completed == 1 then
		self.questCompletes[unitIndex][data.PlayerID] = true
	elseif data.failure == 1 then
		self.questCompletes[unitIndex][data.PlayerID] = nil
		self.questPlayerMinigames[data.PlayerID] = nil

		if not data.done then
			GameMode.players[data.PlayerID]:SetMinigame()
		end
	end

	self:CalcStep()
end

function QuestReactor:CalcStep()
	self.stepNow = 1

	for index, players in pairs( self.questCompletes ) do
		for id, v in pairs( players ) do
			self.stepNow = self.stepNow + 1

			break
		end
	end

	if self.stepNow > self.stepCount then
		self:Destroy( true )

		return
	end

	Quests:NetTable()
end

SabotageReactor = class( {}, nil, BaseSabotage )

function SabotageReactor:OnStart()
	QuestReactor( "reactor", AU_MINIGAME_REACTOR, self, 2 )
end