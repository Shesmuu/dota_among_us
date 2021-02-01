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
	local radius = dir:Length2D()

	if dir == Vector() then
		dir = Vector( 1, 0, 0 )
	else
		dir = dir:Normalized()
	end

	Debug:Execute( function()
	    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target )
		ParticleManager:SetParticleControl( effect_cast, 4, self.target.hero:GetOrigin() )
		ParticleManager:SetParticleControlForward( effect_cast, 3, dir )
		ParticleManager:SetParticleControlForward( effect_cast, 4, dir )
        ParticleManager:ReleaseParticleIndex(effect_cast)

		if radius > 75 then 
			caster:SetAbsOrigin(pos)
		else
			caster:SetAbsOrigin(pos)
			caster:SetForwardVector( dir )
		end
		self.target:Kill( true, caster.player, false, true )
		if caster:HasModifier("modifier_au_impostor_sf_ghost_passive") then
			caster:FindModifierByName("modifier_au_impostor_sf_ghost_passive"):SetStackCount(caster:FindModifierByName("modifier_au_impostor_sf_ghost_passive"):GetStackCount() + 1)
		end
		self:StartCooldown( self:GetSpecialValueFor( "cooldown" ) )
	end )
end