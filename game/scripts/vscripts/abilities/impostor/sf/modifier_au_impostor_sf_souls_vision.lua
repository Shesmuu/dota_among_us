modifier_au_impostor_sf_souls_vision = {}

if IsClient() then
	return
end

function modifier_au_impostor_sf_souls_vision:OnCreated()
	self:StartIntervalThink( 0.1 )
end

function modifier_au_impostor_sf_souls_vision:OnIntervalThink()
	local caster = self:GetCaster()
	local player = caster.player

	AddFOWViewer( player.team, caster:GetAbsOrigin(), 2500, 0.1, false )
end