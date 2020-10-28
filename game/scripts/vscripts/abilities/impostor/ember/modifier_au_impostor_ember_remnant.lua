modifier_au_impostor_ember_remnant = {}

function modifier_au_impostor_ember_remnant:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_au_impostor_ember_remnant:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf"
end

function modifier_au_impostor_ember_remnant:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_au_impostor_ember_remnant:StatusEffectPriority()
	return 20
end

function modifier_au_impostor_ember_remnant:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

if IsClient() then
	return
end

function modifier_au_impostor_ember_remnant:OnDestroy()
	self:GetAbility().unit = nil
	self:GetCaster():RemoveModifierByName( "modifier_au_impostor_ember_remnant_caster" )
	self:GetParent():Destroy()
end