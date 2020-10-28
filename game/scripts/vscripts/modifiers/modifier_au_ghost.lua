modifier_au_ghost = {}

function modifier_au_ghost:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_au_ghost:IsHidden()
	return true
end

function modifier_au_ghost:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_au_ghost:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}
end

function modifier_au_ghost:GetModifierModelChange()
	return "models/creeps/neutral_creeps/n_creep_ghost_b/n_creep_ghost_b.vmdl"
end

function modifier_au_ghost:GetModifierModelScale()
	return 1
end