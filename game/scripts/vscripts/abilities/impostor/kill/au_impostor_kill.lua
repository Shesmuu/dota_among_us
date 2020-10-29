LinkLuaModifier( "modifier_au_impostor_kill", "abilities/impostor/kill/modifier_au_impostor_kill", LUA_MODIFIER_MOTION_NONE )

au_impostor_kill = {}

function au_impostor_kill:GetCastRange()
	return 270
end

function au_impostor_kill:GetIntrinsicModifierName()
	return "modifier_au_impostor_kill"
end

if IsClient() then
	return
end

function au_impostor_kill:OnSpellStart()
	if not self.target or not self.target.alive then
		return
	end

	local caster = self:GetCaster()
	local pos = self.target.hero:GetAbsOrigin()
	local dir = caster:GetAbsOrigin() - pos

	if dir == Vector() then
		dir = Vector( 1, 0, 0 )
	else
		dir = dir:Normalized()
	end

	Debug:Execute( function()
		local effect = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf",
			PATTACH_CUSTOMORIGIN,
			self.target.hero
		)
		ParticleManager:SetParticleControl( effect, 4, pos )
		ParticleManager:ReleaseParticleIndex( effect )
		
		caster:SetClearSpaceOrigin( pos + dir * -100 )
		caster:SetForwardVector( dir )

		self.target:Kill( true, caster.player, false, true )

		self:StartCooldown( self:GetSpecialValueFor( "cooldown" ) )
	end )
end