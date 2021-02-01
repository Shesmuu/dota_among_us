modifier_au_impostor_furion_teleport = {}

function modifier_au_impostor_furion_teleport:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self.radius = 100
end

function modifier_au_impostor_furion_teleport:OnIntervalThink()
	if not IsServer() then return end
	self.radius = self.radius + 25
	local caster = self:GetCaster()
	local player = caster.player
	AddFOWViewer( player.team, self:GetAbility().vTargetPosition, self.radius, FrameTime(), false )
end