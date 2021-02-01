modifier_au_impostor_ns_fly_flying = {}

function modifier_au_impostor_ns_fly_flying:IsHidden()
	return true
end

function modifier_au_impostor_ns_fly_flying:CheckState()
	return {
		[MODIFIER_STATE_FLYING] = true
	}
end

function modifier_au_impostor_ns_fly_flying:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end

function modifier_au_impostor_ns_fly_flying:GetActivityTranslationModifiers()
	return "haste"
end

function modifier_au_impostor_ns_fly_flying:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

if IsClient() then
	return
end

function modifier_au_impostor_ns_fly_flying:OnCreated()
	self:StartIntervalThink( 0.1 )
end

function modifier_au_impostor_ns_fly_flying:OnIntervalThink()
	local caster = self:GetCaster()
	local player = caster.player
	if kickvoting_teleport_start == true then self:Destroy() return end
	AddFOWViewer( player.team, caster:GetAbsOrigin(), 2000, 0.1, false )
end

function modifier_au_impostor_ns_fly_flying:OnDestroy()
	local caster = self:GetCaster()

	caster:SetClearSpaceOrigin( caster:GetAbsOrigin() )
end