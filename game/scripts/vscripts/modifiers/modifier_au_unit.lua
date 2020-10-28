modifier_au_unit = {}

function modifier_au_unit:IsHidden()
	return true
end

function modifier_au_unit:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = not self:GetParent():IsHero(),
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_au_unit:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end