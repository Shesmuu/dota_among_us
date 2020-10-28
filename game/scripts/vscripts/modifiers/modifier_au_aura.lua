modifier_au_aura = {}

function modifier_au_aura:IsHidden()
	return true
end

function modifier_au_aura:IsAura()
	return true
end

function modifier_au_aura:GetModifierAura()
	return self.modifierAura
end

function modifier_au_aura:GetAuraRadius()
	return self.radius
end

function modifier_au_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_au_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_au_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_au_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end