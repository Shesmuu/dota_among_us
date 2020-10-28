local impostorAbilities = {
	npc_dota_hero_zuus = {
		"au_impostor_kill",
		"au_impostor_zuus_global"
	},
	npc_dota_hero_monkey_king = {
		"au_impostor_kill",
		"au_impostor_mk_mischief"
	},
	npc_dota_hero_meepo = {
		"au_impostor_kill",
		"au_impostor_meepo_clone"
	},
	npc_dota_hero_invoker = {
		"au_impostor_kill",
		"au_impostor_invoker_invis"
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
		"au_impostor_sf_souls"
	},
	npc_dota_hero_storm_spirit = {
		"au_impostor_kill",
		"au_impostor_storm_remnant"
	},
	npc_dota_hero_tinker = {
		"au_impostor_kill",
		"au_impostor_tinker_rearm"
	},
}

Player = class( {} )

function Player:constructor( id )
	self.id = id
	self.alive = true
	self.team = PlayerResource:GetTeam( self.id )
	self.role = AU_ROLE_PEACE
	self.muteNominateCount = 1
	self.kickVotingCount = 1
	self.quests = {}

	PlayerResource:SetCustomPlayerColor( self.id, 255, 255, 255 )
	SetTeamCustomHealthbarColor( self.team, 255, 255, 255 )

	ListenToClient( "au_minigame_result", Debug:F( self.MinigameRusult ), self, id )
	ListenToClient( "au_morph_transform_select", Debug:F( self.MorphTransformSelect ), self, id )

	GameMode.playerCount = GameMode.playerCount + 1
	GameMode.players[id] = self
end

function Player:Update( now )
	local cs = PlayerResource:GetConnectionState( self.id )

	if not self.hero then
		return
	end

	if not self.alive and self.role == AU_ROLE_PEACE and now >= self.nextQuestTime then
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
			self:Kill( false, true )

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
			self:Kill( false, true )

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

function Player:NetTable()
	local t = {
		quests = {},
		alive = self.alive,
		mute_count = self.muteNominateCount,
		kick_count = self.kickVotingCount
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
		PlayerResource:SetCustomTeamAssignment( self.id, team )

		self.hero:RemoveAbilities()
		self.hero:Stop()
		self.hero:SetAbsOrigin( pos )
		self.hero:SetForwardVector( dir )

		if self.alive then
			self.hero:RemoveModifierByName( "modifier_au_unselectable" )
			self.hero:Ability( "au_vote_kick", 0, IsTest() and 0 or 20 )
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

	self:DeathTime()
	self:RoleAbilities()
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

function Player:Kill( spawnTomb, instaCalc )
	if not self.hero or not self.alive then
		return
	end

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
	self.nextQuestTime = GameRules:GetGameTime() + 20

	self:RoleAbilities()

	if spawnTomb or instaCalc then
		GameMode:CalculateWinner()
	end
end

function Player:Sabotage( start )
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
					ability:StartCooldown( 30 )
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

function Player:RoleAbilities()
	if not self.hero then
		return
	end

	self.hero:RemoveAbilities()

	if self.role == AU_ROLE_IMPOSTOR and self.alive then
		for i, abilityName in pairs( impostorAbilities[self.abilitiesHeroName] or {} ) do
			self.hero:Ability( abilityName, i - 1, 20 )
		end
		
		Sabotage:Abilities( self.hero )
	end
end

function Player:CustomGameSetup()
	
end

function Player:HeroSelection()
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
		self.hero:HeroSettings( 150, 1350 )
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