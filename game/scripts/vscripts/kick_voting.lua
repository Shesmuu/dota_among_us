KickVoting = {
	unitEffects = {}
}

function KickVoting:Activate()
	local ent =  Quests:GetUnits( "kick_voting" )[1]
	kickvoting_teleport_start = false
	self.center = ent:GetAbsOrigin()
	self.direction = ent:GetForwardVector()
	self.skipDummy = ent

	--local killEnt = Entities:FindByName( nil, "tower_killer" )

	--self.towerKiller = CreateUnitByName( "npc_au_tower_killer", Vector(), false, nil, nil, AU_DUMMIES_TEAM )
	--self.towerKiller:SetAbsOrigin( killEnt:GetAbsOrigin() )
	--self.towerKiller:SetForwardVector( killEnt:GetForwardVector() )
	--self.towerKiller:AddNewModifier( self.towerKiller, nil, "modifier_au_quest_unit", nil )
	--self.towerKiller:AddNewModifier( self.towerKiller, nil, "modifier_au_unselectable", nil )

	--killEnt:Destroy()
end

function KickVoting:Update( now )
	if GameMode.state ~= AU_GAME_STATE_KICK_VOTING then
		return
	end

	if now >= self.endTime then
		self:End()
	end
end

function KickVoting:FindTeam( ib )
	for _, player in pairs( GameMode.players ) do
		if player.alive and player.team ~= GameMode.ghostTeam and ( ib or player.stats.ban <= 0 ) then
			return player.team
		end
	end
end

function KickVoting:Start( starter )
	if GameMode.state == AU_GAME_STATE_KICK_VOTING then
		return
	end

	GameMode.state = AU_GAME_STATE_KICK_VOTING

	for i, effect in pairs( self.unitEffects ) do
		ParticleManager:DestroyParticle( effect, false )
	end

	self.unitEffects = {}

	local team = self:FindTeam( false )

	team = team or self:FindTeam( true )
	team = team or AU_DUMMIES_TEAM

	self.visionUnit = CreateUnitByName( "npc_au_kick_voting_vision", self.center, false, nil, nil, team )

	self.votes = {}
	self.voteStacks = {}
	self.skipCount = 0

	for i = 0, GameMode.playerCount - 1 do
		local player = GameMode.players[i]
		local r = math.pi * 2 / GameMode.playerCount * i
		local pos = self.center + Vector(
			440 * math.cos( r ),
			440 * math.sin( r )
		)

		if player then
			player:KickVoting( pos, self.skipDummy, self.center - pos, team )

			if player.alive and player.hero then
				self.votes[i] = 0
			end
		end
	end

	if starter and starter.hero then
		local pos = starter.hero:GetAbsOrigin()

		self.starterEffect = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf",
			PATTACH_OVERHEAD_FOLLOW,
			starter.hero
		)
		ParticleManager:SetParticleControl( self.starterEffect, 0, pos )
		ParticleManager:SetParticleControlEnt( self.starterEffect, 1, starter.hero, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", pos, true )
		ParticleManager:SetParticleControlEnt( self.starterEffect, 2, starter.hero, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", pos, true )
	end

	local duration = IsTest() and 20 or 90

	self.endTime = GameRules:GetGameTime() + duration

	GameMode:ClearTombs()
	GameMode:ClearCorpses()
	GameMode:NetTableDied()
	GameMode:NetTableState()

	for _, player in pairs( GameMode.players ) do
		if player.alive then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( player.id ), 'chat_visible', {} )
		end
	end
end

function KickVoting:ReduceEndTime()
	local now = GameRules:GetGameTime()
	local remainingTime = self.endTime - now

	if remainingTime < 20 then
		return
	end

	local newRemaining = math.max( remainingTime - 20, 20 )

	self.endTime = newRemaining + now

	GameMode:NetTableState()
end

function KickVoting:Vote( voter, player )
	local id = player.id

	self.votes[id] = self.votes[id] + 1

	self:Projectile( voter.hero, player.hero )

	if not self.voteStacks[id] then
		self.voteStacks[id] = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_stack.vpcf",
			PATTACH_OVERHEAD_FOLLOW,
			player.hero
		)
	end

	if player.role == AU_ROLE_IMPOSTOR then
		voter.stats.imposterVotes = voter.stats.imposterVotes + 1
	else
		voter.stats.wrongVotes = voter.stats.wrongVotes + 1
	end

	ParticleManager:SetParticleControl( self.voteStacks[id], 1, Vector( 0, self.votes[id] ) )

	self:ReduceEndTime()
	self:CheckEnd()
end

function KickVoting:Skip( voter )
	if not self.skipStacks then
		self.skipStacks = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_stack.vpcf",
			PATTACH_OVERHEAD_FOLLOW,
			self.skipDummy
		)
	end

	self.skipCount = self.skipCount + 1

	ParticleManager:SetParticleControl( self.skipStacks, 1, Vector( 0, self.skipCount ) )

	voter.stats.skipVotes = voter.stats.skipVotes + 1

	self:ReduceEndTime()
	self:Projectile( voter.hero, self.skipDummy )
	self:CheckEnd()
end

function KickVoting:CheckEnd()
	local notEnd = false

	for _, player in pairs( GameMode.players ) do
		if player.alive and player.hero then
			local ability = player.hero:FindAbilityByName( "au_vote_kick" )

			if ability and ability:IsActivated() then
				notEnd = true

				break
			end
		end
	end

	if notEnd then
		return
	end

	self:End()
end

function KickVoting:Projectile( from, to )
	Projectile( from, to, "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf", 800 )
end

function KickVoting:End()
	for _, player in pairs( GameMode.players ) do
		if player.alive and player.hero then
			local ability = player.hero:FindAbilityByName( "au_vote_kick" )

			if ability and ability:IsActivated() then
				self:Skip( player )

				ability:SetActivated( false )
			end
		end
	end

	if self.starterEffect then
		ParticleManager:DestroyParticle( self.starterEffect, false )
		self.starterEffect = nil
	end

	if self.skipStacks then
		ParticleManager:DestroyParticle( self.skipStacks, false )
		self.skipStacks = nil
	end

	for _, particle in pairs( self.voteStacks ) do
		ParticleManager:DestroyParticle( particle, false )
	end

	local onceTop = false
	local topCount = 0
	local top

	for id, count in pairs( self.votes ) do
		if count > topCount and count > ( IsTest() and 0 or self.skipCount ) then
			topCount = count
			top = id
			onceTop = true
		elseif count == topCount then
			onceTop = false
		end
	end

	if onceTop then
		local player = GameMode.players[top]

		player:Kill( false, nil, false, false )

		GameMode.lastKicked = player.id

		if player.role == AU_ROLE_PEACE then
			GameMode:ScreenNotice( AU_NOTICE_TYPE_PEACE_KICKED )
		else
			GameMode:ScreenNotice( AU_NOTICE_TYPE_IMPOSTOR_KICKED )
		end
	else
		GameMode:ScreenNotice( AU_NOTICE_TYPE_NO_KICKED )
	end

	Delay( 3.6, function()
		if self.visionUnit then
			self.visionUnit:Destroy()
			self.visionUnit = nil
		end

		GameMode:CalculateWinner()

		Quests:NetTable()

		kickvoting_teleport_start = false

		GameMode:Process()
	end )
	for _, player in pairs( GameMode.players ) do
		if player.alive and player.team ~= GameMode.ghostTeam then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( player.id ), 'chat_hidden', {} )
		end
	end
end

function KickVoting:Preparing()
	for _, quest in pairs( Quests.globalQuests ) do
		quest:Destroy( true )
	end
	for id, player in pairs( GameMode.players ) do
		local unit = player:GetUnit()

		if unit then
			local morphTransform = unit:FindAbilityByName( "au_impostor_morph_transform" )

			if morphTransform and morphTransform.illusion then
				unit = morphTransform.illusion
			end

			unit:SetHealth(1000)

			if unit:GetUnitName() == "npc_dota_hero_invoker" then
				local quas = unit:FindModifierByName("modifier_au_impostor_invoker_quas")
				local exort = unit:FindModifierByName("modifier_au_impostor_invoker_exort")
				local wex = unit:FindModifierByName("modifier_au_impostor_invoker_wex")
				if quas then
					quas:Destroy()
				end
				if exort then
					exort:Destroy()
				end
				if wex then
					wex:Destroy()
				end
			end

			local keeper = unit:FindModifierByName("modifier_au_impostor_keeper_teleport")
			if keeper then
				keeper:Destroy()
			end

			local mirana = unit:FindModifierByName("modifier_au_impostor_mirana_moonlight")
			if mirana then
				mirana:Destroy()
			end

			local commisar_track = unit:FindModifierByName("modifier_au_commissar_track")
			if commisar_track then
				commisar_track:Destroy()
			end

			if unit:FindAbilityByName("au_impostor_sf_ghost") then
				unit:SetMana(1000)
			end

			if not unit:HasModifier( "modifier_au_impostor_mk_mischief" ) then
				local effect = ParticleManager:CreateParticle(
					"particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf",
					PATTACH_ABSORIGIN_FOLLOW,
					unit
				)
				ParticleManager:SetParticleControl( effect, 1, Vector( 150 ) )
				ParticleManager:SetParticleControlEnt(
					effect,
					2,
					unit,
					PATTACH_ABSORIGIN_FOLLOW,
					"attach_hitloc",
					Vector(),
					true
				)

				table.insert( self.unitEffects, effect )
			end

			unit:AbilitiesRemovePreparing()
			unit:Stop()
		end

		player:SetMinigame()
	end
	kickvoting_teleport_start = true
	Quests:NetTable()
end