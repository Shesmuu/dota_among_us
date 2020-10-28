modifier_au_stone_meepo = {}

function modifier_au_stone_meepo:IsHidden()
	return true
end

function modifier_au_stone_meepo:CheckState()
	return {
		[MODIFIER_STATE_FROZEN] = true
	}
end

function modifier_au_stone_meepo:GetStatusEffectName()
	return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function modifier_au_stone_meepo:StatusEffectPriority()
	return 2281337
end