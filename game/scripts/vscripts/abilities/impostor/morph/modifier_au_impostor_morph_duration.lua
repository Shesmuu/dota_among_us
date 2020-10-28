modifier_au_impostor_morph_duration = {}

if IsClient() then
	return
end

function modifier_au_impostor_morph_duration:OnDestroy()
	local ability = self:GetAbility()

	ability:DestroyIllusion()
	ability:StartCooldown( ability:GetSpecialValueFor( "cooldown" ) )
end