local peaceAbilities = {
	npc_dota_hero_ogre_magi = {
		"au_ogre_bloodlust"
	},
	npc_dota_hero_antimage = {
		"au_impostor_am_blink"
	},
	npc_dota_hero_invoker = {
		"au_impostor_invoker_spheres_2"
	},
	npc_dota_hero_keeper_of_the_light = {
		"au_impostor_keeper_teleport"
	},
}

IMPOSTOR_ABILITIES = {
	npc_dota_hero_riki = {
		"au_impostor_kill",
		"au_impostor_riki_smoke"
	},
	npc_dota_hero_night_stalker = {
		"au_impostor_kill",
		"au_impostor_ns_fly"
	},
	npc_dota_hero_ogre_magi = {
		"au_impostor_kill",
		"au_ogre_bloodlust"
	},
	npc_dota_hero_zuus = {
		"au_impostor_kill",
		"au_impostor_zuus_global"
	},
	npc_dota_hero_monkey_king = {
		"au_impostor_kill",
		"au_impostor_mk_tree",
	},
	npc_dota_hero_meepo = {
		"au_impostor_kill",
		"au_impostor_meepo_clone"
	},
	npc_dota_hero_invoker = {
		"au_impostor_invoker_spheres",
		"au_impostor_invoker_wex",
		"au_impostor_invoker_quas",
		"au_impostor_invoker_exort",
	},
	npc_dota_hero_rubick = {
		"au_impostor_rubick_kill",
	},
	npc_dota_hero_pudge = {
		"au_impostor_pudge_eat",
	},
	npc_dota_hero_ember_spirit = {
		"au_impostor_kill",
		"au_impostor_ember_remnant"
	},
	npc_dota_hero_morphling = {
		"au_impostor_kill",
		"au_impostor_morph_transform"
	},
	npc_dota_hero_nevermore = {
		"au_impostor_kill",
		"au_impostor_sf_ghost"
	},
	npc_dota_hero_storm_spirit = {
		"au_impostor_kill",
		"au_impostor_storm_remnant"
	},
	npc_dota_hero_tinker = {
		"au_impostor_kill",
		"au_impostor_tinker_rearm"
	},
	npc_dota_hero_furion = {
		"au_impostor_kill",
		"au_impostor_furion_teleport"
	},
	npc_dota_hero_beastmaster = {
		"au_impostor_kill",
		"au_impostor_beastmaster_bird"
	},
	npc_dota_hero_bloodseeker = {
		"au_impostor_kill",
		"au_impostor_bloodseeker_seeking"
	},
	npc_dota_hero_antimage = {
		"au_impostor_kill",
		"au_impostor_am_blink"
	},
	npc_dota_hero_queenofpain = {
		"au_impostor_qp_knife",
		"au_impostor_qp_scream"
	},
	npc_dota_hero_weaver = {
		"au_impostor_kill",
		"au_impostor_weaver_invis"
	},
	npc_dota_hero_mirana = {
		"au_impostor_kill",
		"au_impostor_mirana_moonlight"
	},
	npc_dota_hero_keeper_of_the_light = {
		"au_impostor_kill",
		"au_impostor_keeper_teleport"
	},
	npc_dota_hero_tiny = {
		"au_impostor_tiny_toss",
	},
	npc_dota_hero_life_stealer = {
		"au_impostor_ls_infest",
	},
}

Player = class( {} )

function Player:constructor( id )
	self.id = id
	self.alive = true
	self.steamID = tostring( PlayerResource:GetSteamID( id ) )
	self.partyID = tostring( PlayerResource:GetPartyID( id ) )
	self.team = PlayerResource:GetTeam( self.id )
	self.role = AU_ROLE_PEACE
	self.admin = false
	self.commissar = false
	self.reportsRemaining = 0
	self.reportedPlayers = {}
	self.quests = {}
	self.stats = {
		low_priority = 0,
		peace_streak = 0,
		rank = 1,
		roleRank = 1,
		imposterVotes = 0,
		skipVotes = 0,
		wrongVotes = 0,
		kills = 0,
		leaveBeforeDeath = false,
		totalWins = 0,
		totalLoses = 0,
		totalMatches = 0,
		ratingImposter = 1000,
		ratingPeace = 1000,
		rating = 1000,
		ratingChange = 0,
		killed = false,
		kicked = false,
		favoriteHero = "",
		party = false,
		toxic_reports = 0,
		party_reports = 0,
		cheat_reports = 0,
		ban = 0,
		reports_update_countdown = 0
	}


	PlayerResource:SetCustomPlayerColor(
		self.id,
		unpack( GameMode.playerColors[self.id] or { 0, 0, 0 } )
	)
	--SetTeamCustomHealthbarColor( self.team, 255, 255, 255 )

	ListenToClient( "au_minigame_result", Debug:F( self.MinigameRusult ), self, id )
	ListenToClient( "au_morph_transform_select", Debug:F( self.MorphTransformSelect ), self, id )
	ListenToClient( "au_keeper_teleport_select", Debug:F( self.KeeperTeleportSelect ), self, id )
	ListenToClient( "au_report_player", Debug:F( self.ReportPlayer ), self, id )
	ListenToClient( "camera_start", Debug:F( self.Camera ), self, id )
	ListenToClient( "au_recamera", Debug:F( self.ReCamera ), self, id )
	ListenToClient( "au_setcamera", Debug:F( self.CamCamera ), self, id )

	GameMode.playerCount = GameMode.playerCount + 1
	GameMode.players[id] = self

	self:NetTable()
end

function Player:Update( now )
	local cs = PlayerResource:GetConnectionState( self.id )

	if not self.hero then
		return
	end

	if
		not self.alive and
		self.role == AU_ROLE_PEACE and
		now >= self.nextQuestTime and
		GameMode.state == AU_GAME_STATE_PROCESS
	then
		for _, quest in pairs( self.quests ) do
			if not quest.completed then
				quest:Complete()

				self.nextQuestTime = now + 10

				return
			end
		end
	end

	if not self.alive then
		return
	end

	local text = ""

	if GameMode.visibleImpostorCount then
		if self.role == AU_ROLE_PEACE then
			text = "#au_role_peace"
		else 
			text = "#au_role_imposter"
		end
	end

	if
		self.alive and
		not self.hasLeave and
		self.afkDeathTime and
		GameMode.state == AU_GAME_STATE_PROCESS and
		not self.minigame
	then
		local killTime = self.afkDeathTime

		if self.hero.lastOrder and self.hero.lastOrder.time > killTime then
			killTime = self.hero.lastOrder.time
		end

		local time = killTime + ( IsTest() and 20 or 70 )

		if now >= time then
			if IsTest() then return end
			self:Kill( false, nil, true, true )

			CustomGameEventManager:Send_ServerToAllClients( "au_red_center_message", {
				afk_killed = self.id,
				duration = 4,
				role_text = text,
				right_text = "#au_afk_killed"
			} )

			self:SendEvent( "au_afk_kill_delay_close", {} )
		elseif now >= time - 10 then
			self:SendEvent( "au_afk_kill_delay_start", {
				time = time
			} )
		else
			self:SendEvent( "au_afk_kill_delay_close", {} )
		end
	else
		self:SendEvent( "au_afk_kill_delay_close", {} )
	end

	local ability = self.hero:FindAbilityByName( "au_vote_kick" )
	
	if
		( cs == DOTA_CONNECTION_STATE_DISCONNECTED or 
		cs == DOTA_CONNECTION_STATE_ABANDONED ) and
		GameMode.state == AU_GAME_STATE_KICK_VOTING and
		ability:IsFullyCastable() and
		ability:IsActivated() and
		not ability:IsHidden()
	then
		ability:SetActivated( false )
		KickVoting:Skip( self )
	end

	if self.hasLeave then
		return
	end

	if cs == DOTA_CONNECTION_STATE_ABANDONED then
		--for _, quest in pairs( self.quests ) do
		--	if not quest.completed then
		--		Quests.taskPointsToWin = Quests.taskPointsToWin - 1
		--	end
		--end

		--Quests:AddTaskPoints( 0 )
		if self.alive then
			self:Kill( false, nil, true, true )

			CustomGameEventManager:Send_ServerToAllClients( "au_red_center_message", {
				afk_killed = self.id,
				duration = 4,
				role_text = text,
				right_text = "#au_leave_killed"
			} )
		end

		self.hasLeave = true
	end
end

function Player:ReportPlayer( data )
	if (
		self.reportsRemaining <= 0 or
		self.reportedPlayers[data.player] or
		self.stats.ban > 0
	) then
		return
	end

	local player = GameMode.players[data.player]
	local column = ( {
		[AU_REPORT_REASON_TOXIC] = "toxic_reports",
		[AU_REPORT_REASON_PARTY] = "party_reports",
		[AU_REPORT_REASON_CHEAT] = "cheat_reports"
	} )[data.reason]

	if not player or not column or player == self then
		return
	end

	print( "[Player]:ReportPlayer", data.player, data.reason )

	self.reportsRemaining = self.reportsRemaining - 1
	self.reportedPlayers[data.player] = true

	self:NetTable()

	Http:Request( "api/players/report", {
		reporter = self.steamID,
		to = player.steamID,
		reason = column
	}, function( data )
		self.reportsRemaining = data.reports_remaining

		self:NetTable()
	end )
end

function Player:Camera(kv)
	if Sabotage:CameraCheck() then return end
	local team = kv.team
	local count = kv.count
	local id = kv.id
	local cameras = FindUnitsInRadius(
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
    for _,camera in pairs(cameras) do
    	if count == "1" then
    		if camera:GetUnitName() == "npc_au_quest_camera_ward_1" then
    			camera:AddNewModifier(nil, nil, "modifier_au_camera", {duration = 0.1, team = team, id = id})
    		end
    	elseif count == "2" then
	    	if camera:GetUnitName() == "npc_au_quest_camera_ward_2" then
	    		camera:AddNewModifier(nil, nil, "modifier_au_camera", {duration = 0.1, team = team, id = id})
	    	end
    	elseif count == "3" then
	    	if camera:GetUnitName() == "npc_au_quest_camera_ward_3" then
	    		camera:AddNewModifier(nil, nil, "modifier_au_camera", {duration = 0.1, team = team, id = id})
	    	end
    	elseif count == "4" then
	    	if camera:GetUnitName() == "npc_au_quest_camera_ward_4" then
	    		camera:AddNewModifier(nil, nil, "modifier_au_camera", {duration = 0.1, team = team, id = id})
	    	end
    	end
    end
end

function Player:CamCamera(kv)
	if Sabotage:CameraCheck() then return end
	local count = kv.count
	local cameras = FindUnitsInRadius(
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
    for _,target in pairs(cameras) do
    	if count == "1" then
    		if target:GetUnitName() == "npc_au_quest_camera_ward_1" then
    			self:SendEvent( "au_set_camara_position_new", { unit = target:GetEntityIndex() } )
    		end
    	elseif count == "2" then
	    	if target:GetUnitName() == "npc_au_quest_camera_ward_2" then
	    		self:SendEvent( "au_set_camara_position_new", { unit = target:GetEntityIndex() } )
	    	end
    	elseif count == "3" then
	    	if target:GetUnitName() == "npc_au_quest_camera_ward_3" then
	    		self:SendEvent( "au_set_camara_position_new", { unit = target:GetEntityIndex() } )
	    	end
    	elseif count == "4" then
	    	if target:GetUnitName() == "npc_au_quest_camera_ward_4" then
	    		self:SendEvent( "au_set_camara_position_new", { unit = target:GetEntityIndex() } )
	    	end
    	end
    end
end

function Player:ReCamera()
	self:SetCamera( self.hero )
end

function Player:MorphTransformSelect( data )
	if not self.hero or not self.alive then
		return
	end

	local unit = self:GetUnit()

	if unit then
		for i = 31, 0, -1 do
			local ability = unit:GetAbilityByIndex( i )

			if
				ability and
				ability:GetAbilityName() == "au_impostor_morph_transform" and
				ability:IsFullyCastable()
			then
				ability:Transform( tonumber( data.id ) )
			end
		end
	end
end

function Player:KeeperTeleportSelect( data )
	if not self.hero or not self.alive then
		return
	end

	local unit = self:GetUnit()

	if unit then
		for i = 31, 0, -1 do
			local ability = unit:GetAbilityByIndex( i )
			if ability and ability:GetAbilityName() == "au_impostor_keeper_teleport" and ability:IsFullyCastable() then
				ability:Teleport( tonumber( data.id ) )
			end
		end
	end
end

function Player:NetTable()
	local t = {
		quests = {},
		role = self.role,
		partyid = self.partyID,
		alive = self.alive,
		ban = self.stats.ban,
		reports_remaining = self.reportsRemaining,
		reported_players = self.reportedPlayers,
		low_priority = self.stats.low_priority,
		rating = self.stats.rating,
		total_matches = self.stats.totalMatches,
		favorite_hero = self.stats.favoriteHero,
		toxic_reports = self.stats.toxic_reports,
		party_reports = self.stats.party_reports,
		cheat_reports = self.stats.cheat_reports,
		reports_update_countdown = self.stats.reports_update_countdown
	}

	for i, quest in pairs( self.quests ) do
		t.quests[i] = quest:GetNetTableData()
	end

	if self.minigame then
		t.minigame = self.minigame.type
	end

	CustomNetTables:SetTableValue( "player", tostring( self.id ), t )
end

function Player:DeathTime( now )
	self.afkDeathTime = now or GameRules:GetGameTime()
	self:SendEvent( "au_afk_kill_delay_close" )
end

function Player:SetMinigame( minigame )
	if self.minigame == minigame then
		return
	end

	if self.minigame and self.minigame.failure then
		self.minigame.failure( self )
	end

	self.minigame = minigame
	self:DeathTime()
	self:NetTable()
end

function Player:Order( data )
	if self.minigame then
		self:SetMinigame()
	end
end

function Player:MinigameRusult( data )
	if not self.minigame then
		return
	end

	self.minigame.result( data )
end

function Player:KickVoting( pos, skipDummy, dir, team )
	self:SetMinigame()
	self:SetCamera( skipDummy )

	if self.hero then
		if self.stats.ban <= 0 then
			PlayerResource:SetCustomTeamAssignment( self.id, team )
		end

		self.hero:RemoveAbilities()
		self.hero:Stop()
		self.hero:SetAbsOrigin( pos )
		self.hero:SetForwardVector( dir )

		if self.alive then
			self.hero:RemoveModifierByName( "modifier_au_unselectable" )

			self.hero:Ability( "au_vote_kick", 0, IsTest() and 0 or 30 )
			if self.commissar == true and not GameMode.commisar_use_track then
				self.hero:Ability( "au_commissar_track", 1, IsTest() and 0 or 30 )
			end
		end
	end
end

function Player:Process()
	if self.hero then
		self.hero:AddNewModifier( unit, nil, "modifier_au_unselectable", nil )
		self.hero:Stop()
		self:SetCamera( self.hero )

		PlayerResource:SetCustomTeamAssignment( self.id, self.alive and self.team or GameMode.ghostTeam )
	end

	self.nextQuestTime = GameRules:GetGameTime() + 5

	self:DeathTime()
	if self.hero then
		if self.hero:GetUnitName() == "npc_dota_hero_rubick" then
			self:RoleAbilitiesRubickStart()
		else
			self:RoleAbilities()
		end
	end
end

function Player:HeroSpawned( hero )
	if self.hero then
		return
	end

	self.hero = hero
	self.abilitiesHeroName = hero:GetUnitName()
end

function Player:SendEvent( name, data )
	local player = PlayerResource:GetPlayer( self.id )

	if player then
		CustomGameEventManager:Send_ServerToPlayer( player, name, data )
	end
end

function Player:GetUnit()
	return self.hero
end

function Player:GetRank( anyRole )
	local rank = 0

	for _, player in pairs( GameMode.players ) do
		if player.alive and ( anyRole or player.role == self.role ) then
			rank = rank + 1
		end
	end

	return rank
end

function Player:Kill( spawnTomb, killer, afkDeath, instaCalc )
	if not self.hero or not self.alive then
		return
	end

	if killer then
		killer.stats.kills = killer.stats.kills + 1

		self.stats.killed = true
	else
		self.stats.kicked = true
	end

	if afkDeath then
		self.stats.leaveBeforeDeath = true

		Http:Request( "api/players/add_low_priority", {
			steam_id = self.steamID,
			count = 3
		} )
	end

	self.stats.rank = self:GetRank( true )
	self.stats.roleRank = self:GetRank( false )

	self:SetMinigame()

	for _, quest in pairs( self.quests ) do
		quest.Trigger = function() end
	end

	self.hero:RemoveModifierByName( "modifier_au_impostor_sf_souls" )

	if GameMode.ghostTeam then
		PlayerResource:SetCustomTeamAssignment( self.id, GameMode.ghostTeam )
		self.hero:SetTeam( GameMode.ghostTeam )
	else
		GameMode.ghostTeam = self.team
	end

	if self.hero.impostorEffects then
		for team, effect in pairs( self.hero.impostorEffects ) do
			ParticleManager:DestroyParticle( effect, true )
		end
	end

	self.hero:AddNewModifier( unit, nil, "modifier_au_ghost", nil )
	self.hero:RemoveAbilities()

	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( self.id ), 'chat_visible', {} )

	self:SendEvent( "au_red_center_message", {
		text = "#au_you_killed",
		duration = 4
	} )
	
	if spawnTomb then
		local tomb = CreateEventUnit( "npc_au_tomb", self.hero:GetAbsOrigin(), function( unit, activator )
			GameMode:FoundCorpse( activator, self )
		end )

		tomb:SetForwardVector( Vector( 0, -1 ) )
		tomb:AddNewModifier( tomb, nil, "modifier_au_unselectable", { duration = 1 } )

		local effect = ParticleManager:CreateParticle(
			"particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave.vpcf",
			PATTACH_CUSTOMORIGIN,
			tomb
		)
		ParticleManager:SetParticleControl( effect, 0, self.hero:GetAbsOrigin() )

		table.insert( GameMode.tombs, tomb )
	end

	self.alive = false
	self.nextQuestTime = GameRules:GetGameTime() + 30

	self:RoleAbilities()

	if spawnTomb or instaCalc then
		GameMode:CalculateWinner()
	end
end

function Player:Sabotage( start, cooldown )
	if self.role ~= AU_ROLE_IMPOSTOR then
		return
	end

	if self.hero then
		for i = 31, 0, -1 do
			local ability = self.hero:GetAbilityByIndex( i )

			if ability and ability:GetAbilityName():find( "au_impostor_sabotage_" ) then
				if start then
					ability:SetActivated( false )
				else
					ability:SetActivated( true )
					ability:StartCooldown( cooldown )
				end
			end
		end
	end
end

function Player:SetCamera( unit )
	self:SendEvent( "au_set_camara_position", { unit = unit:GetEntityIndex() } )
end

function Player:SetRole( role )
	if role == self.role then
		return
	end

	self.role = role

	self:RoleAbilities( role )

	GameMode:NetTableState()
end

function Player:SetComissar()
	self.commissar = true
	GameMode:NetTableState()
end

function Player:RoleAbilities()
	if not self.hero then
		return
	end

	self.hero:RemoveAbilities()

	if not self.alive then
		return
	end

	local abilities = self.role == AU_ROLE_IMPOSTOR and IMPOSTOR_ABILITIES or peaceAbilities

	if self.hero:GetUnitName() == "npc_dota_hero_invoker" then
		if self.role == AU_ROLE_IMPOSTOR then
			self.hero:Ability( "au_impostor_invoker_spheres", 0, 0 )
			self.hero:Ability( "invoker_empty1", 1, 0 )
			self.hero:Ability( "au_impostor_invoker_wex", 6, 20 )
			self.hero:Ability( "au_impostor_invoker_quas", 7, 30 )
			self.hero:Ability( "au_impostor_invoker_exort", 8, 30 )
			self.hero:FindAbilityByName( "au_impostor_invoker_wex" ):SetHidden(true)
			self.hero:FindAbilityByName( "au_impostor_invoker_quas" ):SetHidden(true)
			self.hero:FindAbilityByName( "au_impostor_invoker_exort" ):SetHidden(true)
			Sabotage:Abilities( self.hero )
			self.hero:CastAbilityNoTarget(self.hero:FindAbilityByName( "au_impostor_invoker_spheres" ), self.hero:GetPlayerID())
			return
		end
		self.hero:Ability( "au_impostor_invoker_spheres_2", 0, 0 )
		self.hero:Ability( "invoker_empty1", 1, 0 )
		self.hero:CastAbilityNoTarget(self.hero:FindAbilityByName( "au_impostor_invoker_spheres_2" ), self.hero:GetPlayerID())
		return
	end

	for i, abilityName in pairs( abilities[self.abilitiesHeroName] or {} ) do
		if abilityName == "au_impostor_kill" or abilityName == "au_impostor_pudge_eat" or abilityName == "au_impostor_rubick_kill" or abilityName == "au_impostor_qp_scream" then
			self.hero:Ability( abilityName, i - 1, 30 )
			if abilityName == "au_impostor_qp_scream" then
				self.hero:FindAbilityByName("au_impostor_qp_scream"):SetActivated(false)
			end
		else
			self.hero:Ability( abilityName, i - 1, 20 )
		end
	end

	if self.role == AU_ROLE_IMPOSTOR then
		Sabotage:Abilities( self.hero )
	end
end

function Player:RoleAbilitiesRubickStart()
	if not self.hero then
		return
	end

	local ability = self.hero:GetAbilityByIndex( 0 )

	if ability then
		ability:Removing()
		ability:SetHidden( true )
	end

	if not self.alive then
		return
	end

	local abilities = self.role == AU_ROLE_IMPOSTOR and IMPOSTOR_ABILITIES or peaceAbilities

	if self.abilitiesHeroName == "npc_dota_hero_invoker" then
		self.hero:Ability( "au_impostor_invoker_exort", 1, 30 )
		self.hero:Ability( "au_impostor_invoker_quas", 0, 20 )
		Sabotage:Abilities( self.hero )
		return
	end

	for i, abilityName in pairs( abilities[self.abilitiesHeroName] or {} ) do
		if abilityName == "au_impostor_kill" or abilityName == "au_impostor_pudge_eat" or abilityName == "au_impostor_qp_scream" then
			self.hero:Ability( abilityName, i - 1, 30 )
			if abilityName == "au_impostor_qp_scream" then
				self.hero:FindAbilityByName("au_impostor_qp_scream"):SetActivated(false)
			end
		else
			self.hero:Ability( abilityName, i - 1, 20 )
		end
	end
	if self.role == AU_ROLE_IMPOSTOR then
		Sabotage:Abilities( self.hero )
	end
end

function Player:RoleAbilitiesRubick()
	if not self.hero then
		return
	end

	local ability = self.hero:GetAbilityByIndex( 0 )

	if ability then
		ability:Removing()
		ability:SetHidden( true )
	end

	if not self.alive then
		return
	end

	local abilities = self.role == AU_ROLE_IMPOSTOR and IMPOSTOR_ABILITIES or peaceAbilities

	if self.abilitiesHeroName == "npc_dota_hero_invoker" then
		self.hero:Ability( "au_impostor_invoker_exort", 1, 40 )
		self.hero:Ability( "au_impostor_invoker_quas", 0, 50 )
		Sabotage:Abilities( self.hero )
		return
	end

	for i, abilityName in pairs( abilities[self.abilitiesHeroName] or {} ) do
		if abilityName == "au_impostor_kill" or abilityName == "au_impostor_pudge_eat" or abilityName == "au_impostor_qp_scream" then
			self.hero:Ability( abilityName, i - 1, 40 )
			if abilityName == "au_impostor_qp_scream" then
				self.hero:FindAbilityByName("au_impostor_qp_scream"):SetActivated(false)
			end
		else
			self.hero:Ability( abilityName, i - 1, 0 )
		end
	end
	if self.role == AU_ROLE_IMPOSTOR then
		Sabotage:Abilities( self.hero )
	end
end

function Player:CustomGameSetup()
	
end

function Player:UpdateTeam()
	self.team = PlayerResource:GetTeam( self.id )
end

function Player:GameInProgress( now )
	if not self.hero then
		self.alive = false

		return
	end

	self.hero:Ability( "au_vote_kick" )
	self.hero.player = self

	if self.role == AU_ROLE_IMPOSTOR then
		self.hero.impostorEffects = {}

		Delay( 0.3, function()
			self:SendEvent( "au_red_center_message", {
				text = "#au_you_impostor",
				duration = 2.5
			} )
		end )

		GameMode:CreateImpostorEffects( self.hero )

		self.hero:HeroSettings()
	else
		self.hero:HeroSettings( 700, 900 )
	end

	Quests:RandomQuests( self )

	self:NetTable()
end

function Player:FindQuest( name )
	for _, quest in pairs( self.quests ) do
		if quest.name == name then
			return quest
		end
	end
end