LinkLuaModifier( "modifier_au_commissar_track", "abilities/vote_kick/au_commissar_track", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_commissar_track_anim", "abilities/vote_kick/au_commissar_track", LUA_MODIFIER_MOTION_NONE )

modifier_au_commissar_track = {}

function modifier_au_commissar_track:IsHidden()
	return true
end

function modifier_au_commissar_track:OnCreated()
	if not IsServer() then return end
	self.head = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), PlayerResource:GetPlayer( self:GetCaster():GetPlayerOwnerID()))
	ParticleManager:SetParticleControl(self.head, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(self.head, false, false, -1, false, true)
	self.particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), PlayerResource:GetPlayer( self:GetCaster():GetPlayerOwnerID()))
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.particle, 8, Vector(1,0,0))
	self:AddParticle(self.particle, false, false, -1, false, false)
	self:StartIntervalThink(FrameTime())
end

function modifier_au_commissar_track:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_au_ghost") then self:Destroy() return end
	if kickvoting_teleport_start == true then return end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 10, FrameTime(), false)
end

modifier_au_commissar_track_anim = {}

function modifier_au_commissar_track_anim:IsHidden()
	return true
end

function modifier_au_commissar_track_anim:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
	}
	return funcs
end

function modifier_au_commissar_track_anim:GetModifierIgnoreCastAngle()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return 1
	end
end

au_commissar_track = {}

function au_commissar_track:GetIntrinsicModifierName()
	return "modifier_au_commissar_track_anim"
end

if IsClient() then
	return
end

function au_commissar_track:OnAbilityPhaseStart()
	local target = self:GetCursorTarget()

	if target == self:GetCaster() then
		return false
	end

	if target.player then
		return true
	end

	return false
end

function au_commissar_track:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	self:SetActivated( false )
	local particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf", PATTACH_CUSTOMORIGIN, caster, PlayerResource:GetPlayer( caster:GetPlayerOwnerID() ))
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
	target:AddNewModifier(caster, nil, "modifier_au_commissar_track", {})
	GameMode.commisar_use_track = true
end
