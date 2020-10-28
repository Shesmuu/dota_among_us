modifier_au_impostor_invoker_invis = {}

function modifier_au_impostor_invoker_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_au_impostor_invoker_invis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}
end

function modifier_au_impostor_invoker_invis:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor( "movespeed" )
end

function modifier_au_impostor_invoker_invis:GetModifierInvisibilityLevel()
	return 1
end