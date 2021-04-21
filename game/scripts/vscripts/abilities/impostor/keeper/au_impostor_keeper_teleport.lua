LinkLuaModifier( "modifier_au_impostor_keeper_teleport_day", "abilities/impostor/keeper/au_impostor_keeper_teleport", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_keeper_teleport_day_effect", "abilities/impostor/keeper/au_impostor_keeper_teleport", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_keeper_teleport", "abilities/impostor/keeper/au_impostor_keeper_teleport", LUA_MODIFIER_MOTION_NONE )

au_impostor_keeper_teleport = class({})

function au_impostor_keeper_teleport:GetIntrinsicModifierName()
	return "modifier_au_impostor_keeper_teleport_day"
end

modifier_au_impostor_keeper_teleport_day = {}

function modifier_au_impostor_keeper_teleport_day:IsHidden()
	return true
end

function modifier_au_impostor_keeper_teleport_day:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_au_impostor_keeper_teleport_day:OnIntervalThink()
	if IsServer() then
		local modifier = self:GetParent():FindModifierByName("modifier_au_impostor_keeper_teleport_day_effect")
		if GameRules:IsDaytime() then
			if self:GetParent():GetUnitName() == "npc_dota_hero_keeper_of_the_light" then
				if not modifier then
					self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_au_impostor_keeper_teleport_day_effect", {})
				end
			end
			self:GetAbility():SetActivated( true )
		else
			if modifier then
				modifier:Destroy()
			end
			self:GetAbility():SetActivated( false )
		end
	end
end

modifier_au_impostor_keeper_teleport_day_effect = class({})

function modifier_au_impostor_keeper_teleport_day_effect:IsHidden()	return true end

function modifier_au_impostor_keeper_teleport_day_effect:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
end

function modifier_au_impostor_keeper_teleport_day_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_keeper_spirit_form.vpcf"
end

modifier_au_impostor_keeper_teleport = class({})

function modifier_au_impostor_keeper_teleport:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall.vpcf"
end

function modifier_au_impostor_keeper_teleport:OnCreated()
	if not IsServer() then return end
	self:GetParent():EmitSound("Hero_KeeperOfTheLight.Recall.Target")
	self:StartIntervalThink(FrameTime())
end

function modifier_au_impostor_keeper_teleport:OnDestroy()
	if not IsServer() then return end
	if kickvoting_teleport_start == true then return end
	if self:GetParent():HasModifier("modifier_au_tiny_toss") then
		return
	end
	self:GetParent():StopSound("Hero_KeeperOfTheLight.Recall.Target")
	if self:GetRemainingTime() <= 0 then
		local caster_position = self:GetCaster():GetAbsOrigin()
		if self:GetParent().player.alive then
			if self:GetParent():HasModifier( "modifier_au_impostor_morph_duration" ) then
				if self:GetParent():HasModifier( "modifier_au_impostor_morph_caster" ) then
					self:GetParent():CastAbilityNoTarget(self:GetParent():FindAbilityByName( "au_impostor_morph_transform" ), self:GetParent():GetPlayerID())
				end
			end
			if self:GetParent():HasModifier( "modifier_au_impostor_ls_infest" ) then
				self:GetParent():CastAbilityNoTarget(self:GetParent():FindAbilityByName( "au_impostor_ls_infest" ), self:GetParent():GetPlayerID())
			end
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_poof.vpcf", PATTACH_POINT, self:GetParent())
			ParticleManager:ReleaseParticleIndex(particle)
			FindClearSpaceForUnit(self:GetParent(), self:GetCaster():GetAbsOrigin(), false)
			EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_KeeperOfTheLight.Recall.End", self:GetCaster())
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_poof.vpcf", PATTACH_POINT, self:GetParent())
			ParticleManager:ReleaseParticleIndex(particle)
			self:GetParent():Stop()
			self:GetParent().player:SetMinigame()
		end
	end
end

if IsClient() then
	return
end

function au_impostor_keeper_teleport:OnSpellStart()
	Debug:Execute( function()
		self:SpellStart()
	end )
end

function au_impostor_keeper_teleport:SpellStart()
	local caster = self:GetCaster()
	local playerID = caster.player.id
	local player = PlayerResource:GetPlayer( playerID )

	if player then
		local heroes = {}
		for id, p in pairs( GameMode.players ) do
			if id ~= playerID then
				heroes[id] = PlayerResource:GetSelectedHeroName( id )
			end
		end
		CustomGameEventManager:Send_ServerToPlayer( player, "au_keeper_teleport_start", heroes )
	end
end

function au_impostor_keeper_teleport:Teleport( id )
	local caster = self:GetCaster()
	local player = caster.player
	local playerID = caster.player.id
	local player_message = PlayerResource:GetPlayer( playerID )

	local cooldown = self:GetSpecialValueFor("cooldown")
	local duration = self:GetSpecialValueFor("duration")

	if not id or id == player.id then
		return
	end

	local p = GameMode.players[id]

	if not GameRules:IsDaytime() then
		CustomGameEventManager:Send_ServerToPlayer(player_message, "CreateIngameErrorMessage", {message="#au_keeper_day"})
		return
	end 

	if not p or not p.alive or not p.hero or p.hero:HasModifier("modifier_au_tiny_toss") then
		CustomGameEventManager:Send_ServerToPlayer(player_message, "CreateIngameErrorMessage", {message="#au_heroes_is_die"})
		return
	end

	p.hero:AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_keeper_teleport", {duration = duration})

	self:StartCooldown(cooldown)
end