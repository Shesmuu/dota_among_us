LinkLuaModifier( "modifier_au_impostor_meepo_invis", "abilities/impostor/meepo/modifier_au_impostor_meepo_invis", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_meepo_caster", "abilities/impostor/meepo/modifier_au_impostor_meepo_caster", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_meepo_clone", "abilities/impostor/meepo/modifier_au_impostor_meepo_clone", LUA_MODIFIER_MOTION_NONE )

au_impostor_meepo_clone = {}

if IsClient() then
	return
end

function au_impostor_meepo_clone:OnSpellStart()
	Debug:Execute( function()
		if self.illusion then
			self:Removing()
		end

		local caster = self:GetCaster()
		local player = caster.player
		local duration = {
			duration = self:GetSpecialValueFor( "duration" )
		}

		caster:AddNewModifier( caster, self, "modifier_au_impostor_meepo_caster", duration )
		caster:FindAbilityByName( "au_impostor_kill" ):SetActivated( false )

		local killAbility = caster:FindAbilityByName( "au_impostor_kill" )
		local cooldown

		if killAbility then
			cooldown = killAbility:GetCooldownTimeRemaining()
		end

		self.illusion = CreateUnitByName( "npc_dota_hero_meepo", caster:GetAbsOrigin(), true, caster, caster, player.team )
		self.illusion:SetControllableByPlayer( player.id, true )
		self.illusion:RemoveModifierByName( "modifier_invulnerable" )
		self.illusion:HeroSettings()
		self.illusion:RemoveAbilities()
		self.illusion:Ability( "au_impostor_kill", 1, cooldown )
		self.illusion:AddNewModifier( caster, self, "modifier_au_impostor_meepo_clone", duration )
		self.illusion:AddNewModifier( caster, self, "modifier_au_impostor_meepo_invis", {
			duration = self:GetSpecialValueFor( "invis_duration" )
		} )

		GameMode:CreateImpostorEffects( self.illusion, true )
	end )
end

function au_impostor_meepo_clone:Removing()
	if self.illusion then
		self.illusion:RemoveModifierByName( "modifier_au_impostor_meepo_clone" )
	end

	self:GetCaster():RemoveModifierByName( "modifier_au_impostor_meepo_caster" )
end