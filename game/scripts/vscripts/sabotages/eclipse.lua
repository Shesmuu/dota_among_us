SabotageEclipse = class( {}, nil, BaseSabotage )

function SabotageEclipse:OnStart()
	GlobalQuest( "eclipse", AU_MINIGAME_ECLIPSE, self )
	EmitGlobalSound( "Game.Eclipse" )
	GameMode:DefaultNight()
	for _, p in pairs( GameMode.players ) do
		if p.role ~= AU_ROLE_IMPOSTOR and p.hero and p.alive then
			p.hero:SetNightTimeVisionRange( 150 )
		end
	end
	Quests.eclipse = true
end

function SabotageEclipse:OnEnd( i )
	GameMode:DefaultDay()
	for _, p in pairs( GameMode.players ) do
		if p.role ~= AU_ROLE_IMPOSTOR and p.hero and p.alive then
			p.hero:SetNightTimeVisionRange( 700 )
		end
	end
	Quests.eclipse = false
end

function SabotageEclipse:OnStop()
	GameMode:DefaultDay()
	for _, p in pairs( GameMode.players ) do
		if p.role ~= AU_ROLE_IMPOSTOR and p.hero and p.alive then
			p.hero:SetNightTimeVisionRange( 700 )
		end
	end
	Quests.eclipse = false
end

function SabotageEclipse:OnReturn()
	GameMode:DefaultNight()
	for _, p in pairs( GameMode.players ) do
		if p.role ~= AU_ROLE_IMPOSTOR and p.hero and p.alive then
			p.hero:SetNightTimeVisionRange( 150 )
		end
	end
	Quests.eclipse = true
end