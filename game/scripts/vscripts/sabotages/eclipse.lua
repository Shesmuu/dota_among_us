SabotageEclipse = class( {}, nil, BaseSabotage )

function SabotageEclipse:OnStart()
	GlobalQuest( "eclipse", AU_MINIGAME_ECLIPSE, self )
	EmitGlobalSound( "Game.Eclipse" )
	GameMode:DefaultNight()
end

function SabotageEclipse:OnEnd( i )
	GameMode:DefaultDay()
end

function SabotageEclipse:OnStop()
	GameMode:DefaultDay()
end

function SabotageEclipse:OnReturn()
	GameMode:DefaultNight()
end