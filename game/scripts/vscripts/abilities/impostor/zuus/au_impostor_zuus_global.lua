LinkLuaModifier( "modifier_au_impostor_zuus_global", "abilities/impostor/zuus/modifier_au_impostor_zuus_global", LUA_MODIFIER_MOTION_NONE )

au_impostor_zuus_global = {}

function au_impostor_zuus_global:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	caster:EmitSound( "Hero_Zuus.GodsWrath.PreCast" )

	local a = caster:GetAttachmentOrigin( caster:ScriptLookupAttachment( "attach_attack1" ) )

	self.phaseEffect = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		caster
	)
	ParticleManager:SetParticleControlEnt( self.phaseEffect, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.phaseEffect, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.phaseEffect, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true )

	return true
end

function au_impostor_zuus_global:OnAbilityPhaseInterrupted()
	if self.phaseEffect then
		ParticleManager:DestroyParticle( self.phaseEffect, true )
		ParticleManager:ReleaseParticleIndex( self.phaseEffect )
	end
end

function au_impostor_zuus_global:OnSpellStart()
	local caster = self:GetCaster()

	if self.phaseEffect then
		ParticleManager:DestroyParticle( self.phaseEffect, false )
		ParticleManager:ReleaseParticleIndex( self.phaseEffect )
	end

	for _, player in pairs( GameMode.players ) do
		if player.alive and player.hero then
			player.hero:AddNewModifier( caster, self, "modifier_au_impostor_zuus_global", {
				duration = self:GetSpecialValueFor( "duration" )
			} )

			if player.role == AU_ROLE_IMPOSTOR then	
				player:SendEvent( "au_emit_sound", { sound = "Hero_Zuus.GodsWrath.Target" } )
				player:SendEvent( "au_emit_sound", { sound = "Hero_Zuus.GodsWrath" } )
			end
		end
	end
end