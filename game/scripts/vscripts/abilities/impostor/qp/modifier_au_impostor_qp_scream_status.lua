modifier_au_impostor_qp_scream_status = {}

function modifier_au_impostor_qp_scream_status:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink( FrameTime() )
end

function modifier_au_impostor_qp_scream_status:OnIntervalThink()
	if not IsServer() then return end
	if kickvoting_teleport_start == true then self:Destroy() end
end