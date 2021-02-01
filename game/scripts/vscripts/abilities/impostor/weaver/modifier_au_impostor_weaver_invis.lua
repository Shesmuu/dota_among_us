modifier_au_impostor_weaver_invis = {}

function modifier_au_impostor_weaver_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_au_impostor_weaver_invis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}
end

function modifier_au_impostor_weaver_invis:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor( "movespeed" )
end

function modifier_au_impostor_weaver_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_au_impostor_weaver_invis:GetEffectName()
	return "particles/units/heroes/hero_weaver/weaver_shukuchi.vpcf"
end

function modifier_au_impostor_weaver_invis:OnCreated()
	if not IsServer() then return end
	self.radius				= self:GetAbility():GetSpecialValueFor("radius")
	self.hit_targets		= {}
	self.shukuchi_particle	= nil
	self:StartIntervalThink(FrameTime())
end

function modifier_au_impostor_weaver_invis:OnIntervalThink()
	self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(self.enemies) do
		if not self.hit_targets[enemy] then
			if
				enemy.player and
				enemy.player.role ~= AU_ROLE_IMPOSTOR and
				enemy.player.alive
			then
				self.shukuchi_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_shukuchi_damage_arc.vpcf", PATTACH_ABSORIGIN, enemy)
				ParticleManager:SetParticleControl(self.shukuchi_particle, 1, enemy:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(self.shukuchi_particle)
				self.shukuchi_particle = nil
				self.hit_targets[enemy]	= true
			end
		end
	end
end