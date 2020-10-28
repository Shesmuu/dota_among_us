SabotageInterference = class( {}, nil, BaseSabotage )

function SabotageInterference:OnStart()
	GlobalQuest( "interference", AU_MINIGAME_INTERFERENCE, self )
	Quests.interferenced = true
	Quests:NetTable()
end

function SabotageInterference:OnEnd( i )
	Quests.interferenced = false
	Quests:NetTable()
end