modifier_au_impostor_qp_knife = {}

function modifier_au_impostor_qp_knife:IsHidden()
	return true
end

function modifier_au_impostor_qp_knife:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self:GetAbility():SetActivated(false)
	for _, p in pairs( GameMode.players ) do
		if p.role == AU_ROLE_IMPOSTOR and p.hero and p.alive then
			local effect_cast = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_queenofpain/queen_shadow_strike_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), p.team )
			ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
			self:AddParticle( effect_cast, false, false, -1, false, false )
		end
	end
end

function modifier_au_impostor_qp_knife:OnDestroy()
	if not IsServer() then return end
	self:GetCaster():FindAbilityByName("au_impostor_qp_scream"):SetActivated(false)
	self:GetAbility():SetActivated(true)
	self:GetCaster():RemoveModifierByName("modifier_au_impostor_qp_scream_status")
end

function modifier_au_impostor_qp_knife:OnIntervalThink()
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	local caster = self:GetCaster()
	local player = caster.player
	if kickvoting_teleport_start == true then self:Destroy() return end
	if not self:GetParent().player.alive then self:Destroy() return end
	if self:GetParent():HasModifier("modifier_au_impostor_pudge_eat") then self:Destroy() return end
	if self:GetParent():HasModifier("modifier_au_tiny_toss") then self:Destroy() return end

	if Quests.interferenced then
		for _, p in pairs( GameMode.players ) do
			if p.role == AU_ROLE_IMPOSTOR and p.hero and p.alive then
				AddFOWViewer( p.team, self:GetParent():GetAbsOrigin(), self.radius, FrameTime(), false )
			end
		end
	else
		AddFOWViewer( player.team, self:GetParent():GetAbsOrigin(), self.radius, FrameTime(), false )
	end
end