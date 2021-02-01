modifier_au_impostor_sf_ghost = {}

function modifier_au_impostor_sf_ghost:OnCreated()
	if not IsServer() then return end
	self:GetParent():SetBaseMaxHealth(self:GetCaster():GetMaxMana())
	self:GetParent():SetHealth(self:GetCaster():GetMana())
	self:StartIntervalThink(FrameTime())
	self:GetCaster():FindAbilityByName("au_impostor_sf_ghost"):SetActivated(false)
	self:GetCaster():FindAbilityByName("au_impostor_sf_ghost"):EndCooldown()
	self:GetCaster().player:SendEvent( "au_set_select_unit", { unit = self:GetParent():GetEntityIndex() } )
end

function modifier_au_impostor_sf_ghost:OnIntervalThink()
	if not IsServer() then return end
	self.radius = self:GetAbility():GetSpecialValueFor("vision") + (self:GetParent():GetOwner():FindModifierByName("modifier_au_impostor_sf_ghost_passive"):GetStackCount() * self:GetAbility():GetSpecialValueFor("vision_bonus"))
	local caster = self:GetCaster()
	local player = caster.player
	AddFOWViewer( player.team, self:GetParent():GetAbsOrigin(), self.radius, FrameTime(), false )
	if kickvoting_teleport_start == true then self:Destroy() end
	if self:GetCaster():HasModifier("modifier_au_ghost") then self:Destroy() end
end

function modifier_au_impostor_sf_ghost:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE
	}
end

function modifier_au_impostor_sf_ghost:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING] = true,
	}
end

function modifier_au_impostor_sf_ghost:GetModifierPercentageCasttime()
	if not IsServer() then return end
	local ability = self:GetParent():GetOwner():FindModifierByName("modifier_au_impostor_sf_ghost_passive"):GetAbility()
	local modifier = self:GetParent():GetOwner():FindModifierByName("modifier_au_impostor_sf_ghost_passive"):GetStackCount()
	return ability:GetSpecialValueFor("cast_bonus") * modifier
end

function modifier_au_impostor_sf_ghost:OnDestroy(params)
	if IsServer() then
		if self:GetParent():GetOwner():HasModifier("modifier_au_impostor_sf_ghost_caster") then
			self:GetParent():GetOwner():RemoveModifierByName("modifier_au_impostor_sf_ghost_caster")
		end
		self:GetCaster():FindAbilityByName("au_impostor_sf_ghost"):SetActivated(true)
		self:GetCaster():FindAbilityByName("au_impostor_sf_ghost"):UseResources(true, false, true)
		self:GetParent():Destroy()
	end
end


function modifier_au_impostor_sf_ghost:IsAura()
    return true
end

function modifier_au_impostor_sf_ghost:IsHidden()
    return true
end

function modifier_au_impostor_sf_ghost:IsPurgable()
    return false
end

function modifier_au_impostor_sf_ghost:GetAuraRadius()
    return 9999999
end

function modifier_au_impostor_sf_ghost:GetModifierAura()
    return "modifier_truesight"
end
   
function modifier_au_impostor_sf_ghost:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_au_impostor_sf_ghost:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_au_impostor_sf_ghost:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_au_impostor_sf_ghost:GetAuraDuration()
    return 0.1
end