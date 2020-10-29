LinkLuaModifier( "modifier_au_impostor_kill", "abilities/impostor/kill/modifier_au_impostor_kill", LUA_MODIFIER_MOTION_NONE )

au_impostor_rubick_kill = {}

function au_impostor_rubick_kill:GetCastRange()
	return 375
end

function au_impostor_rubick_kill:GetIntrinsicModifierName()
	return "modifier_au_impostor_kill"
end

if IsClient() then
	return
end

function au_impostor_rubick_kill:OnAbilityPhaseStart()
	if not self.target or not self.target.alive then
		return false
	end

	self:GetCaster():FaceTowards( self.target.hero:GetAbsOrigin() )

	return true
end

function au_impostor_rubick_kill:OnSpellStart()
	Debug:Execute( function()
		if not self.target then
			return
		end

		local caster = self:GetCaster()
		local player = caster.player

		player.abilitiesHeroName = self.target.hero:GetUnitName()

		self.target:Kill( true, player, false, true )

		Projectile( caster, self.target.hero, "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf" , 1200 )

		player:RoleAbilities()
	end )
end