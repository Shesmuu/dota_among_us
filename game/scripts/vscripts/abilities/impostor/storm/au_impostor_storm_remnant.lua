LinkLuaModifier( "modifier_au_impostor_storm_remnant", "abilities/impostor/storm/modifier_au_impostor_storm_remnant", LUA_MODIFIER_MOTION_NONE )

au_impostor_storm_remnant = {}

if IsClient() then
	return
end

function au_impostor_storm_remnant:OnSpellStart()
	Debug:Execute( function()
		local caster = self:GetCaster()
		local player = caster.player
		local pos = caster:GetAbsOrigin()

		for _, p in pairs( GameMode.players ) do
			if p.alive and p.hero and player.role == p.role then
				local unit = CreateUnitByName( "npc_au_storm_remnant", pos, true, nil, nil, p.team )
				unit:AddNewModifier( caster, self, "modifier_au_impostor_storm_remnant", nil )
				unit:AddNewModifier( caster, self, "modifier_kill", {duration = self:GetSpecialValueFor( "duration" )} )

				unit.effect = ParticleManager:CreateParticleForTeam(
					"particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf",
					PATTACH_WORLDORIGIN,
					unit,
					p.team
				)
				ParticleManager:SetParticleControl( unit.effect, 0, pos )
				ParticleManager:SetParticleControlEnt( unit.effect, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", pos, true )
				ParticleManager:SetParticleControl( unit.effect, 2, Vector( RandomInt( 37, 52 ), 1, 100 ) )
				ParticleManager:SetParticleControl( unit.effect, 11, pos )
			end
		end
	end )
end