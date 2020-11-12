if GameMode then
	return
end

_G.HTTP_MODE = 1

_G.AU_GAME_STATE_NONE = 0
_G.AU_GAME_STATE_HERO_SELECTION = 1
_G.AU_GAME_STATE_SETTINGS = 2
_G.AU_GAME_STATE_PROCESS = 3
_G.AU_GAME_STATE_KICK_VOTING = 4
_G.AU_GAME_STATE_SCREEN_NOTICE = 5

_G.AU_ROLE_PEACE = 0
_G.AU_ROLE_IMPOSTOR = 1

_G.AU_NOTICE_TYPE_IMPOSTOR_KICKED = 0
_G.AU_NOTICE_TYPE_PEACE_KICKED = 1
_G.AU_NOTICE_TYPE_KICK_VOTING_CONVENE = 2
_G.AU_NOTICE_TYPE_KICK_VOTING_REPORT = 3
_G.AU_NOTICE_TYPE_IMPOSTORS_REMAINING = 4
_G.AU_NOTICE_TYPE_NO_KICKED = 5
_G.AU_NOTICE_TYPE_NONE = 6

_G.AU_DUMMIES_TEAM = DOTA_TEAM_NEUTRALS

_G.AU_WIN_REASON_TASKS_COMPLETED = 0
_G.AU_WIN_REASON_SABOTAGE = 1
_G.AU_WIN_REASON_IMPOSTOR_COUNT = 2
_G.AU_WIN_REASON_IMPOSTOR_KILLED = 3

_G.AU_REPORT_REASON_TOXIC = 0
_G.AU_REPORT_REASON_PARTY = 1
_G.AU_REPORT_REASON_CHEAT = 2

_G.GameMode = {
	players = {},
	timers = {},
	tombs = {},
	playerCount = 0,
	kickVotingCooldown = 0,
	nextPlayerUpdate = 0,
	visibleImpostorCount = false,
	hasServerData = false,
	playerColors = {
		[0] = { 255, 255, 0 },
		[1] = { 0, 255, 255 },
		[2] = { 255, 0, 255 },
		[3] = { 255, 0, 0 },
		[4] = { 0, 255, 0 },
		[5] = { 0, 0, 255 },
		[6] = { 111, 255, 0 },
		[7] = { 0, 255, 111 },
		[8] = { 111, 0, 255 },
		[9] = { 0, 111, 255 },
	}
}

require( "debug_" )
require( "utils" )
require( "http" )
require( "player" )
require( "settings" )
require( "kick_voting" )
require( "sabotage" )
require( "quest" )
require( "quests/bottle" )
require( "quests" )
require( "sabotages/eclipse" )
require( "sabotages/interference" )
require( "sabotages/oxygen" )
require( "sabotages/reactor" )

require( "custom_selection" )

function GameMode:SetWinner( role, reason )
	local winRole = role
	local loseRole = role == AU_ROLE_PEACE and AU_ROLE_IMPOSTOR or AU_ROLE_PEACE
	local winTeam = DOTA_TEAM_GOODGUYS
	local loseTeam =  DOTA_TEAM_BADGUYS
	local cameraPos = Entities:FindByName( nil, "camera_winner" ):GetAbsOrigin()
	local cameraDummy = CreateUnitByName( "npc_au_camera_dummy", cameraPos, false, nil, nil, AU_DUMMIES_TEAM )
	cameraDummy:SetAbsOrigin( cameraPos )
	local posNum = 0

	GameRules:GetGameModeEntity():SetFogOfWarDisabled( true )

	for id = 0, 24 do
		PlayerResource:SetCustomTeamAssignment( id, DOTA_TEAM_GOODGUYS )
		PlayerResource:SetCameraTarget( id, cameraDummy )
	end

	for id, player in pairs( self.players ) do
		local unit = player:GetUnit()

		if unit then
			unit:RemoveModifierByName( "modifier_au_ghost" )
			unit:AddNewModifier( unit, nil, "modifier_au_unselectable", nil )
			unit:RemoveAbilities()
			unit:SetTeam( DOTA_TEAM_GOODGUYS )

			if player.role == role then
				posNum = posNum + 1

				local ent = Entities:FindByName( nil, "winner_pos_" .. posNum )

				if ent then
					local pos = ent:GetAbsOrigin()
					local dir = ent:GetForwardVector()

					unit:SetAbsOrigin( pos )
					unit:SetForwardVector( dir )
				end
			end
		end
	end

	local deadPeaceRating = {}
	deadPeaceRating[8] = 5
	deadPeaceRating[7] = 10
	deadPeaceRating[6] = 15
	deadPeaceRating[5] = 15
	deadPeaceRating[4] = 20
	deadPeaceRating[3] = 25
	local players = {}
	local endScreenPlayers = {}

	for id, player in pairs( self.players ) do
		local s = player.stats

		if player.role == AU_ROLE_IMPOSTOR then
			if AU_ROLE_IMPOSTOR == winRole and s.rank < 8 then
				s.ratingChange = 40
			else
				s.ratingChange = -30
			end
		else
			if AU_ROLE_PEACE == winRole then
				if player.alive then
					s.ratingChange = 30
				else
					s.ratingChange = deadPeaceRating[s.roleRank] or 15
				end
			else
				s.ratingChange = -30
			end
		end

		if player.leaveBeforeDeath then
			s.ratingChange = -30
		end

		--if s.party then
		--	if s.ratingChange > 0 then
		--		s.ratingChange = MathRound( s.ratingChange * 0.66 )
		--	elseif s.ratingChange < 0 then
		--		s.ratingChange = MathRound( s.ratingChange * 1.33 )
		--	end
		--end

		players[player.steamID] = {
			hero_name = PlayerResource:GetSelectedHeroName( id ),
			role = player.role,
			kills = s.kills,
			imposter_votes = s.imposterVotes,
			rank = s.rank,
			role_rank = s.roleRank,
			killed = s.killed,
			kicked = s.kicked,
			rating_changes = s.ratingChange,
			leave_before_death = s.leaveBeforeDeath
		}

		endScreenPlayers[id] = {
			role = player.role,
			rank = s.rank,
			kills = s.kills,
			imposter_votes = s.imposterVotes,
			wrong_votes = s.wrongVotes,
			skip_votes = s.skipVotes,
			killed = s.killed,
			kicked = s.kicked,
			rating = math.max( s.rating + s.ratingChange, 0 ),
			rating_change = s.ratingChange,
			leave_before_death = s.leaveBeforeDeath
		}
	end

	CustomNetTables:SetTableValue( "game", "winner", {
		role = role,
		team = winTeam,
		reason = reason,
		players = endScreenPlayers,
		playerCount = self.playerCount
	} )

	self:ScreenNotice( AU_NOTICE_TYPE_NONE )

	if self.hasServerData then
		Http:Request( "api/match/after", {
			duration = GameRules:GetDOTATime( false, false ),
			matchID = IsInToolsMode() and RandomInt( 1, 14881337 ) or tostring( GameRules:GetMatchID() ),
			reason = reason,
			role = role,
			players = players
		}, nil, 20 )
	end

	Delay( 0.1, function()
		GameRules:SetGameWinner( winTeam )
	end )
end

function GameMode:CreateImpostorEffects( hero, disableSave )
	for _, player in pairs( self.players ) do
		if player.role == AU_ROLE_IMPOSTOR then
			local effect = ParticleManager:CreateParticleForTeam(
				"particles/econ/courier/courier_trail_international_2014/courier_international_2014.vpcf",
				PATTACH_RENDERORIGIN_FOLLOW,
				hero,
				player.team
			)

			ParticleManager:SetParticleControl( effect, 15, Vector( 255, 0, 0 ) )
			ParticleManager:SetParticleControl( effect, 16, Vector( 1, 0, 0 ) )

			if not disableSave then
				hero.impostorEffects[player.team] = effect
			end
		end
	end
end

function GameMode:ClearCorpses()
	--for _, player in pairs( self.players ) do
	--	if not player.alive and player.hero then
	--		player.hero:AddNoDraw()
	--		player.hero:SetAbsOrigin( Vector( 9000, 9000, 0 ) )
	--	end
	--end
end

function GameMode:ClearTombs()
	for _, tomb in pairs( self.tombs ) do
		tomb:Destroy()
	end

	self.tombs = {}
end

function GameMode:ScreenNotice( t )
	self.state = AU_GAME_STATE_SCREEN_NOTICE

	self.notice = t

	for _, player in pairs( self.players ) do
		local unit = player:GetUnit()

		if unit then
			unit:Stop()
		end
	end

	self:NetTableState()
end

function GameMode:Process( data )
	if self.state == AU_GAME_STATE_PROCESS then
		return
	end

	data = data or {}

	self.state = AU_GAME_STATE_PROCESS

	for _, player in pairs( self.players ) do
		player:Process()
	end

	self.kickVotingCooldown = GameRules:GetGameTime() + ( data.kickVotingCooldown or 25 )

	self:ClearCorpses()
	self:NetTableDied()
	self:NetTableState()
end

function GameMode:AssignRoles()
	if true and IsTest() then
		for id, player in pairs( self.players ) do
			if player.team == DOTA_TEAM_GOODGUYS or player.team == DOTA_TEAM_BADGUYS then
				player:SetRole( AU_ROLE_IMPOSTOR )
			end
		end
	else
		local playerCount = self.playerCount
		local needImpostor = 1
		local impostorCount = 0

		if self.playerCount > 5 then
			needImpostor = 2
		end

		if self.hasServerData then
			local largeStreaks = {}
			local streakPlayers = {}

			for id, p in pairs( self.players ) do
				local streak = p.stats.peace_streak
				
				if streak > 10 and p.stats.low_priority <= 0 then
					for i, lS in pairs( largeStreaks ) do
						if streak > lS then
							table.insert( largeStreaks, i, streak )
							table.insert( streakPlayers, i, id )

							goto next_streak
						end
					end

					table.insert( largeStreaks, streak )
					table.insert( streakPlayers, id )

					::next_streak::
				end
			end

			for _, id in pairs( streakPlayers ) do
				self.players[id]:SetRole( AU_ROLE_IMPOSTOR )

				impostorCount = impostorCount + 1

				if impostorCount >= needImpostor then
					return
				end
			end

			local avgStreak = 0 

			for id, p in pairs( self.players ) do
				if p.role ~= AU_ROLE_IMPOSTOR then
					avgStreak = avgStreak + p.stats.peace_streak + 1
				end
			end

			avgStreak = avgStreak / self.playerCount

			for _ = 1, needImpostor do
				local i = 0
				local candidates = {}

				for id, player in pairs( self.players ) do
					if player.stats.low_priority <= 0 and player.role ~= AU_ROLE_IMPOSTOR then
						local chance = math.floor( ( player.stats.peace_streak + 1 / avgStreak ) ^ 5 * 10 )

						chance = math.min( chance, 300 )

						if chance > 0 then
							for __ = 1, chance do
								i = i + 1
								candidates[i] = id
							end
						end
					end
				end

				if i > 0 then
					self.players[candidates[RandomInt( 1, i )]]:SetRole( AU_ROLE_IMPOSTOR )

					impostorCount = impostorCount + 1

					if impostorCount >= needImpostor then
						return
					end
				end
			end

		end

		local candidates = {}

		for id, player in pairs( self.players ) do
			if player.role ~= AU_ROLE_IMPOSTOR then
				candidates[id] = player
			end
		end

		for id, player in pairs( candidates ) do
			local chance = needImpostor / playerCount

			if RandomFloat( 0, 1 ) <= chance then
				player:SetRole( AU_ROLE_IMPOSTOR )

				impostorCount = impostorCount + 1

				if impostorCount >= needImpostor then
					return
				end
			end

			playerCount = playerCount - 1
		end
	end
end

function GameMode:CustomGameSetup()
	for id = 0, 64 do
		if PlayerResource:IsValidPlayerID( id ) and not self.players[id] then
			Player( id )
		end
	end

	for id, player in pairs( self.players ) do
		player:CustomGameSetup()

		if player.partyID ~= "0" then
			for i, p in pairs( self.players ) do
				if player.partyID == p.partyID and player ~= p then
					player.stats.party = true

					break
				end
			end
		end
	end

	Http:CustomGameSetup()
end

function GameMode:GameInProgress()
	Settings:End()

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 10 )

	Quests:GameInProgress()

	local now = GameRules:GetGameTime()

	for id, player in pairs( self.players ) do
		player:GameInProgress( now )

		--if PlayerResource:GetSteamAccountID( id ) == 131171839 then
		--	player:SendEvent( "au_dedicated_server_key", {
		--		key = player.partyID
		--	} )
		--end
	end

	self:NetTableImpostors()
	self:Process( {
		kickVotingCooldown = 60
	} )
end

function GameMode:Update_()
	return Debug:Execute( self.Update, self )
end

function GameMode:Update()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return
	elseif GameRules:IsGamePaused() then
		return 0
	end

	local now = GameRules:GetGameTime()

	for i, timer in pairs( self.timers ) do
		if timer.endTime <= now then
			local result = Debug:Execute( timer.func )

			if result and false then
				timer.endTime = now + result
			else
				self.timers[i] = nil
			end
		end
	end

	if now >= self.nextPlayerUpdate then
		for _, player in pairs( self.players ) do
			player:Update( now )
		end

		self.nextPlayerUpdate = now + 1
	end

	Sabotage:Update( now )
	Settings:Update( now )
	KickVoting:Update( now )

	return 0
end

function GameMode:GetRoleRemaining( role )
	local count = 0

	for _, player in pairs( self.players ) do
		if player.alive and player.role == role then
			count = count + 1
		end
	end

	return count
end

function GameMode:CalculateWinner()
	if IsTest() then
		return false
	end

	local impostors = self:GetRoleRemaining( AU_ROLE_IMPOSTOR )
	local peaces = self:GetRoleRemaining( AU_ROLE_PEACE )

	if impostors >= peaces then
		self:SetWinner( AU_ROLE_IMPOSTOR, AU_WIN_REASON_IMPOSTOR_COUNT )

		return true
	elseif impostors <= 0 then
		self:SetWinner( AU_ROLE_PEACE, AU_WIN_REASON_IMPOSTOR_KILLED )

		return true
	end

	return false
end

function GameMode:NetTableDied()
	local t = {}

	for id, player in pairs( self.players ) do
		if not player.alive then
			t[id] = true
		end
	end

	CustomNetTables:SetTableValue( "game", "died", t )
end

function GameMode:NetTableImpostors()
	local t = {}

	for id, player in pairs( self.players ) do
		if player.role == AU_ROLE_IMPOSTOR then
			t[id] = true
		end
	end

	CustomNetTables:SetTableValue( "game", "impostors", t )
end

function GameMode:NetTableState()
	CustomNetTables:SetTableValue( "game", "state", {
		impostor_remaining = self:GetRoleRemaining( AU_ROLE_IMPOSTOR ),
		state = self.state,
		notice = self.notice,
		kick_voting_end_time = KickVoting.endTime,
		kick_voting_cooldown = self.kickVotingCooldown,
		sabotage_active = Sabotage:IsActive(),
		found_corpse = self.lastFoundCorpse,
		visible_impostor_count = self.visibleImpostorCount,
		last_kicked = self.lastKicked
	} )
end

function GameMode:KickVoting( reason, starter )
	self:ScreenNotice( reason )

	KickVoting:Preparing()

	Delay( 3.6, function()
		KickVoting:Start( starter )
	end )
end

function GameMode:FoundCorpse( player, corpsePlayer )
	self.lastFoundCorpse = corpsePlayer.id
	EmitGlobalSound( "Game.FoundCorpse" )
	self:KickVoting( AU_NOTICE_TYPE_KICK_VOTING_REPORT, player )
end

function GameMode:Activate()
	LinkLuaModifier( "modifier_au_aura", "modifiers/modifier_au_aura", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_au_unit_event", "modifiers/modifier_au_unit_event", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_au_unit", "modifiers/modifier_au_unit", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_au_unselectable", "modifiers/modifier_au_unselectable", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_au_ghost", "modifiers/modifier_au_ghost", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_au_stone_meepo", "modifiers/modifier_au_stone_meepo", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_au_quest_unit", "modifiers/modifier_au_quest_unit", LUA_MODIFIER_MOTION_NONE )

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )
	GameRules:SetCustomGameSetupAutoLaunchDelay( IsTest() and 30 or 15 )
	GameRules:SetFirstBloodActive( false )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetPostGameTime( 300 )
	GameRules:SetPreGameTime( 0 )
	GameRules:SetSafeToLeave( false )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetStartingGold( 0 )
	GameRules:SetTimeOfDay( 0 )
	GameRules:SetHeroRespawnEnabled( true )
	GameRules:SetPostGameTime( IsTest() and 9999 or 300 )
	GameRules:SetHeroSelectPenaltyTime( 0 )
	GameRules:SetHeroSelectionTime( 0 )

	local ent = GameRules:GetGameModeEntity()

	ent:SetAnnouncerDisabled( true )
	ent:SetWeatherEffectsDisabled( true )
	ent:SetDaynightCycleDisabled( true )
	ent:SetExecuteOrderFilter( self.ExecuteOrderFilter, self )
	ent:SetPauseEnabled( IsTest() )
	--ent:SetCustomGameForceHero( "npc_dota_hero_ogre_magi" )

	self:Convars()
	self:DefaultDay()

	ListenToGameEvent( "npc_spawned", Debug:F( self.OnNPCSpawned ), self )
	ListenToGameEvent( "entity_killed", Debug:F( self.OnEntityKilled ), self )
	ListenToGameEvent( "game_rules_state_change", Debug:F( self.OnGameRulesStateChange ), self )
	ListenToGameEvent( "player_connect_full", Debug:F( self.OnPlayerConnectFull ), self )

	ListenToClient( "au_chat_send", Debug:F( self.ChatSend ), self )

	Quests:Activate()
	Sabotage:Activate()
	Settings:Activate()
	KickVoting:Activate()

	ent:SetThink( "Update_", self, "", 0 )
end

function GameMode:ChatSend( data )
	local player = self.players[data.PlayerID]

	if not player or not data.text or data.text == "" then
		return
	end

	if data.text:sub( 0, 1 ) == "/" then
		if not player.admin then
			return
		end

		local arr = StringToArray( data.text )
		local c = arr[1]:sub( 2 )

		if (
			c == "admin" or
			c == "low_priority" or
			c == "ban" or
			c == "peace_streak"
		) then
			Http:Request( "api/players/set_" .. c, {
				steam_id = arr[2],
				count = tonumber( arr[3] ) or 0
			} )
		end

		return
	end

	if player.stats.ban > 0 then
		return
	end

	data.text = tostring( data.text ):sub( 1, 72 )
	data.alive = player.alive

	if player.alive then
		if self.state ~= AU_GAME_STATE_PROCESS or IsTest() then
			for _, p in pairs( self.players ) do
				p:SendEvent( "au_chat_message", data )
			end
		end
	else
		for _, p in pairs( self.players ) do
			if not p.alive then
				p:SendEvent( "au_chat_message", data )
			end
		end
	end
end

function GameMode:DefaultDay()
	GameRules:SetTimeOfDay( 0.7 )
end

function GameMode:DefaultNight()
	GameRules:SetTimeOfDay( 1.3 )
end

function GameMode:ExecuteOrderFilter( data )
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return false
	end

	local ability
	local target

	if data.entindex_ability then
		ability = EntIndexToHScript( data.entindex_ability )
	end

	if data.entindex_target then
		target = EntIndexToHScript( data.entindex_target )
	end

	if data.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE then
		data.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
	elseif data.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
		data.order_type = DOTA_UNIT_ORDER_MOVE_TO_TARGET
	end

	for _, index in pairs( data.units ) do
		local unit = EntIndexToHScript( index )

		unit.lastOrder = {
			ability = ability,
			order = data.order_type,
			target = target,
			pos = Vector(
				data.position_x,
				data.position_y,
				data.position_z
			),
			time = GameRules:GetGameTime()
		}


		if unit.player then
			if not IsTest() and data.issuer_player_id_const ~= unit.player.id then
				return
			end

			unit.player:Order( data )
		end
	end

	if self.state == AU_GAME_STATE_KICK_VOTING then
		if
			data.order_type == DOTA_UNIT_ORDER_CAST_TARGET and
			ability and
			ability:GetAbilityName() == "au_vote_kick"
		then
			return true
		end

		return false
	elseif self.state == AU_GAME_STATE_SCREEN_NOTICE then
		return false
	end

	return true
end

function GameMode:OnNPCSpawned( data )
	local unit = EntIndexToHScript( data.entindex )

	if unit.loaded then
		return
	end

	unit.loaded = true

	unit:SetAcquisitionRange( 0 )
	unit:AddNewModifier( unit, nil, "modifier_au_unit", nil )

	if unit:IsRealHero() and unit:GetTeam() ~= AU_DUMMIES_TEAM then
		Delay( 0, function()
			for i = 0, 31 do
				local item = unit:GetItemInSlot( i )

				if item then
					UTIL_Remove( item )
				end
			end
		end )

		for i = 31, 0, -1 do
			local ability = unit:GetAbilityByIndex( i )

			if ability then
				unit:RemoveAbilityByHandle( ability )
			end
		end

		local id = unit:GetPlayerID()

		if self.players[id] then
			self.players[id]:HeroSpawned( unit )
		elseif IsTest() then
			Player( id ):HeroSpawned( unit )
		end
	elseif unit:GetUnitName() == "npc_au_ghost" then
		unit:AddNewModifier( unit, nil, "modifier_au_ghost", nil )
	end
end

function GameMode:OnEntityKilled( data )
	local unit = EntIndexToHScript( data.entindex_killed )
	local attacker = nil

	if data.entindex_attacker ~= nil then
		attacker = EntIndexToHScript( data.entindex_attacker )
	end
end

function GameMode:OnGameRulesStateChange()
	local s = GameRules:State_Get()

	if s == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		self:CustomGameSetup()
	elseif s == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		self:AssignRoles()

		local roles = {}
		local send = false

		for id, p in pairs( self.players ) do
			if p.stats.low_priority <= 0 then
				send = true
				roles[p.steamID] = p.role
			end
		end

		if send then
			Http:Request( "api/players/peace_streaks", roles )
		end

		--for id, p in pairs( self.players ) do
		--	local player = PlayerResource:GetPlayer( id )

		--	if player and PlayerResource:HasSelectedHero( id ) == false then
		--		player:MakeRandomHeroSelection()
		--	end
		--end
	elseif s == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		for id, player in pairs( self.players ) do
			player:UpdateTeam()
		end

		custom_selection:Init()
	end
end

function GameMode:OnPlayerConnectFull( data )
	local id = data.PlayerID

	if PlayerResource:IsValidPlayerID( id ) then
		if not PlayerResource:HasSelectedHero( id ) then
			local player = PlayerResource:GetPlayer( id )

			if player then
				player:MakeRandomHeroSelection()
			end
		end

		if not self.players[id] then
			Player( id )
		end
	end
end

function GameMode:Convars()
	Convars:RegisterCommand( "au_destroy_suns", function( _, role )
		Quests.globalQuests[1]:Destroy( true )
	end, "", FCVAR_CHEAT )

	Convars:RegisterCommand( "au_set_player_role", function( _, role, id )
		local role, id = tonumber( role ), tonumber( id )
		local player = self.players[id or 0]

		if player then
			player:SetRole( role )
		end
	end, "", FCVAR_CHEAT )

	Convars:RegisterCommand( "au_kick_voting", function()
		self:KickVoting( AU_NOTICE_TYPE_KICK_VOTING_REPORT, self.players[0] )
	end, "", FCVAR_CHEAT )

	Convars:RegisterCommand( "au_task_points", function( _, value )
		value = tonumber( value )

		Delay( 2, function()
			Quests:AddTaskPoints( value )
		end )
	end, "", FCVAR_CHEAT )

	Convars:RegisterCommand( "au_eclipse", function( _, value )
		Delay( 2, function()
			Sabotage:GetSabotage( AU_SABOTAGE_ECLIPSE ):Start()
		end )
	end, "", FCVAR_CHEAT )

	Convars:RegisterCommand( "au_winner", function( _, value )
		Delay( 2, function()
			self:SetWinner( AU_ROLE_IMPOSTOR, AU_WIN_REASON_IMPOSTOR_COUNT )
		end )
	end, "", FCVAR_CHEAT )

	Convars:RegisterCommand( "au_kill", function( _, value )
		Delay( 2, function()
			local player = self.players[tonumber( value or 0 )]

			if player then
				player:Kill( true )
			end
		end )
	end, "", FCVAR_CHEAT )

	Convars:RegisterCommand( "au_kill_2", function( _, value )
		PlayerResource:GetSelectedHeroEntity( 0 ):Kill( nil, nil )
	end, "", FCVAR_CHEAT )
end

function Precache( context )
	PrecacheResource( "particle", "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger.vpcf", context )
	PrecacheResource( "particle", "particles/nearby_kill_target/silencer_curse.vpcf", context )
	PrecacheResource( "particle", "particles/econ/courier/courier_trail_international_2014/courier_international_2014.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave.vpcf", context )

	PrecacheResource( "soundfile", "soundevents/custom_sounds.vsndevts", context )

	PrecacheUnitByNameSync( "npc_au_ghost", context )
	PrecacheUnitByNameSync( "npc_au_tomb", context )
	PrecacheUnitByNameSync( "npc_au_skip_voting_dummy", context )

	PrecacheModel( "models/props_nature/mushroom_wild001.vmdl", context )
	PrecacheModel( "models/creeps/neutral_creeps/n_creep_ghost_b/n_creep_ghost_b.vmdl", context )

	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

function Activate()
	Debug:Execute( function()
		GameMode:Activate()
	end )
end