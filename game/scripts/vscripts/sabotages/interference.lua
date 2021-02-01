SabotageInterference = class( {}, nil, BaseSabotage )

function SabotageInterference:OnStart()
	GlobalQuest( "interference", AU_MINIGAME_INTERFERENCE, self )
	Quests.interferenced = true
	if GameMode.visibleTaks then
		Quests:NetTable(true)
	else
		Quests:NetTable(false)
	end

	local team_imp = nil

	local sf = FindUnitsInRadius(
        DOTA_TEAM_NOTEAM,
        Vector(0,0,0), 
        nil,   
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        0, 
        0,  
        false 
    )
    for _,hero in pairs(sf) do
    	if hero:GetUnitName() == "npc_dota_hero_nevermore" then
    		if hero.player.alive and hero.player.team ~= GameMode.ghostTeam and hero.player.role == AU_ROLE_IMPOSTOR then
	    		team_imp = hero.player.team
	    		break
	    	end
    	end
    end
	for _, player in pairs( GameMode.players ) do
		if player.alive and player.team ~= GameMode.ghostTeam and player.role == AU_ROLE_IMPOSTOR then
			if team_imp == nil then
				team_imp = player.team
			end
			Delay( 1, function()
				PlayerResource:SetCustomTeamAssignment( player.id, team_imp )
				PlayerResource:GetSelectedHeroEntity(player.id):SetTeam(team_imp)
			end)
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( player.id ), 'chat_visible', {} )
		end
	end
	CustomGameEventManager:Send_ServerToAllClients( 'chat_clean', {} )
end

function SabotageInterference:OnEnd( i )
	Quests.interferenced = false
	if GameMode.visibleTaks then
		Quests:NetTable(false)
	else
		Quests:NetTable(true)
	end
	for _, player in pairs( GameMode.players ) do
		if player.alive and player.team ~= GameMode.ghostTeam and player.role == AU_ROLE_IMPOSTOR then
			Delay( 1, function()
				PlayerResource:SetCustomTeamAssignment( player.id, player.team )
				PlayerResource:GetSelectedHeroEntity(player.id):SetTeam(player.team)
			end)
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( player.id ), 'chat_hidden', {} )
		end
	end
	CustomGameEventManager:Send_ServerToAllClients( 'chat_clean', {} )
end