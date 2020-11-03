modifier_au_ogre_bloodlust = {}

function modifier_au_ogre_bloodlust:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
end

function modifier_au_ogre_bloodlust:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "movespeed" )
end

function modifier_au_ogre_bloodlust:GetModifierModelScale()
	return 10
end

function modifier_au_ogre_bloodlust:GetBonusVisionPercentage()
	return self:GetAbility():GetSpecialValueFor( "vision" )
end

function modifier_au_ogre_bloodlust:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_au_ogre_bloodlust:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor( "night_vision" )
end

function modifier_au_ogre_bloodlust:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end