modifier_au_impostor_meepo_invis = {}

function modifier_au_impostor_meepo_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_au_impostor_meepo_invis:DeclareFunctions()
	return {
		--MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}
end

function modifier_au_impostor_meepo_invis:GetModifierMoveSpeed_Absolute()
	return 1200
end

function modifier_au_impostor_meepo_invis:GetModifierInvisibilityLevel()
	return 1
end