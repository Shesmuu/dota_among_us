modifier_au_impostor_qp_scream = {}

function modifier_au_impostor_qp_scream:IsHidden()
	return true
end

function modifier_au_impostor_qp_scream:OnCreated()
	if not IsServer() then return end
	self.tick_interval = 0.5
	self.tick = 3.5
	self.tick_halfway = true
	self:StartIntervalThink( self.tick_interval )
end

function modifier_au_impostor_qp_scream:OnIntervalThink()
	if not IsServer() then return end
	if kickvoting_teleport_start == true then self:Destroy() return end
	if not self:GetParent().player.alive then self:Destroy() return end
	if self:GetParent():HasModifier("modifier_au_impostor_pudge_eat") then self:Destroy() return end
	if self:GetParent():HasModifier("modifier_au_tiny_toss") then self:Destroy() return end
	self.tick = self.tick - self.tick_interval
	if self.tick>0 then
		self.tick_halfway = not self.tick_halfway
		self:PlayEffects()
		self:PlayEffects2()
		return
	end
end

function modifier_au_impostor_qp_scream:OnDestroy()
	if not IsServer() then return end
	if kickvoting_teleport_start == true then return end
	if self:GetParent():HasModifier("modifier_au_impostor_pudge_eat") then self:Destroy() return end
	if self:GetParent():HasModifier("modifier_au_tiny_toss") then self:Destroy() return end
	self:GetParent().player:Kill( true, self:GetCaster().player, false, true )
end

function modifier_au_impostor_qp_scream:PlayEffects2()
	local time = math.floor( self.tick )
	local mid = 1
	if self.tick_halfway then mid = 8 end

	local effect_cast = ParticleManager:CreateParticleForPlayer( "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), PlayerResource:GetPlayer( self:GetCaster():GetPlayerOwnerID() ) )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, time, mid ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 2, 0, 0 ) )

	if time<1 then
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
	end

	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_au_impostor_qp_scream:PlayEffects()
	local time = math.floor( self.tick )
	local mid = 1
	if self.tick_halfway then mid = 8 end

	local effect_cast = ParticleManager:CreateParticleForPlayer( "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), PlayerResource:GetPlayer( self:GetParent():GetPlayerOwnerID() ) )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, time, mid ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 2, 0, 0 ) )

	if time<1 then
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
	end

	ParticleManager:ReleaseParticleIndex( effect_cast )
end