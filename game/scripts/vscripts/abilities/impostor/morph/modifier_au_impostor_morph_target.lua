modifier_au_impostor_morph_target = {}

function modifier_au_impostor_morph_target:IsHidden()
	return true
end

if IsClient() then
	return
end

function modifier_au_impostor_morph_target:OnCreated()
	self:StartIntervalThink(FrameTime())
end

function modifier_au_impostor_morph_target:OnIntervalThink()
	local caster = self:GetCaster()
	local player = caster.player

	if self:GetParent():HasModifier("modifier_au_ghost") then return end
	AddFOWViewer( player.team, self:GetParent():GetAbsOrigin(), 100, FrameTime(), false )
end