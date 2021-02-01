modifier_au_impostor_bloodseeker_seeking_speed = {}

function modifier_au_impostor_bloodseeker_seeking_speed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
end

function modifier_au_impostor_bloodseeker_seeking_speed:GetActivityTranslationModifiers()
	return "haste"
end

function modifier_au_impostor_bloodseeker_seeking_speed:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_au_impostor_bloodseeker_seeking_speed:GetModifierMoveSpeed_Max( params )
    return 1000
end

function modifier_au_impostor_bloodseeker_seeking_speed:GetModifierMoveSpeed_Limit( params )
    return 1000
end

function modifier_au_impostor_bloodseeker_seeking_speed:GetModifierIgnoreMovespeedLimit( params )
    return 1
end