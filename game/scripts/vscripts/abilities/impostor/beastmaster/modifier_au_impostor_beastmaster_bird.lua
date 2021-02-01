modifier_au_impostor_beastmaster_bird = {}

function modifier_au_impostor_beastmaster_bird:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self:GetCaster():FindAbilityByName("au_impostor_beastmaster_bird"):SetActivated(false)
	self:GetCaster():FindAbilityByName("au_impostor_beastmaster_bird"):EndCooldown()
end

function modifier_au_impostor_beastmaster_bird:OnIntervalThink()
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor("vision")
	local caster = self:GetCaster()
	local player = caster.player
	AddFOWViewer( player.team, self:GetParent():GetAbsOrigin(), self.radius, FrameTime(), false )
	if kickvoting_teleport_start == true then self:Destroy() self:GetParent():Destroy() end
	if self:GetCaster():HasModifier("modifier_au_ghost") then self:Destroy() self:GetParent():Destroy() end
end

function modifier_au_impostor_beastmaster_bird:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}
end

function modifier_au_impostor_beastmaster_bird:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING] = true,
	}
end

function modifier_au_impostor_beastmaster_bird:GetModifierInvisibilityLevel()
	return 1
end

function modifier_au_impostor_beastmaster_bird:OnDestroy(params)
	if IsServer() then
		self:GetCaster():FindAbilityByName("au_impostor_beastmaster_bird"):SetActivated(true)
		self:GetCaster():FindAbilityByName("au_impostor_beastmaster_bird"):UseResources(true, false, true)
		self:GetParent():Destroy()
	end
end

function modifier_au_impostor_beastmaster_bird:OnRemoved(params)
	if IsServer() then
		self:GetCaster():FindAbilityByName("au_impostor_beastmaster_bird"):SetActivated(true)
		self:GetCaster():FindAbilityByName("au_impostor_beastmaster_bird"):UseResources(true, false, true)
		self:GetParent():Destroy()
	end
end