modifier_au_impostor_storm_remnant = {}

function modifier_au_impostor_storm_remnant:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_au_impostor_storm_remnant:OnCreated()
	self:StartIntervalThink( FrameTime() )
end

function modifier_au_impostor_storm_remnant:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local player = caster.player

	if kickvoting_teleport_start == true then
		ParticleManager:DestroyParticle( self:GetParent().effect, false )
		self:GetParent():Destroy()
	end
end

function modifier_au_impostor_storm_remnant:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle( self:GetParent().effect, false )
end