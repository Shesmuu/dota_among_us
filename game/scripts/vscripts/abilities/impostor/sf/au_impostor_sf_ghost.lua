LinkLuaModifier( "modifier_au_impostor_sf_ghost", "abilities/impostor/sf/modifier_au_impostor_sf_ghost", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_sf_ghost_passive", "abilities/impostor/sf/au_impostor_sf_ghost", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_sf_ghost_caster", "abilities/impostor/sf/au_impostor_sf_ghost", LUA_MODIFIER_MOTION_NONE )

au_impostor_sf_ghost = {}
au_impostor_sf_ghost_teleport = {}
au_impostor_sf_ghost_teleport_sf = {}
modifier_au_impostor_sf_ghost_passive = {}
modifier_au_impostor_sf_ghost_caster = {}

function modifier_au_impostor_sf_ghost_passive:GetTexture()
  	return "nevermore_necromastery"
end

function modifier_au_impostor_sf_ghost_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_BONUS,
    }

    return funcs
end

function modifier_au_impostor_sf_ghost_passive:GetModifierManaBonus( params )
    return 800
end

function au_impostor_sf_ghost:GetIntrinsicModifierName()
    return "modifier_au_impostor_sf_ghost_passive"
end

function au_impostor_sf_ghost:OnSpellStart()
	if not IsServer() then return end
	local point = self:GetCaster():GetAbsOrigin()
	local caster = self:GetCaster()
	local player = caster.player
	self.ghost = CreateUnitByName("npc_au_sf_ghost", point, false, self:GetCaster(), self:GetCaster(), player.team)
	self.ghost:AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_sf_ghost", {})
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_sf_ghost_caster", {})
	self.ghost:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	local speed = self:GetSpecialValueFor("movespeed") + (self:GetCaster():FindModifierByName("modifier_au_impostor_sf_ghost_passive"):GetStackCount() * self:GetSpecialValueFor("movespeed_bonus"))
	self.ghost:SetBaseMoveSpeed(speed)
end

function au_impostor_sf_ghost_teleport:OnAbilityPhaseStart()
	if not IsServer() then return end
	if not GridNav:IsTraversable( self:GetCaster():GetAbsOrigin() ) then
		return false
	end
	local speed = (self:GetCaster():GetOwner():FindModifierByName("modifier_au_impostor_sf_ghost_passive"):GetStackCount() * 0.2) + 1
	self:GetCaster():GetOwner():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_6, speed)
	return true;
end

function au_impostor_sf_ghost_teleport:OnAbilityPhaseInterrupted()
	if not IsServer() then return end
    self:GetCaster():GetOwner():RemoveGesture( ACT_DOTA_CAST_ABILITY_6)
end

function au_impostor_sf_ghost_teleport:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():GetOwner():SetAbsOrigin(self:GetCaster():GetAbsOrigin())
	FindClearSpaceForUnit(self:GetCaster():GetOwner(), self:GetCaster():GetAbsOrigin(), true)
	self:GetCaster():GetOwner():RemoveGesture( ACT_DOTA_CAST_ABILITY_6)
	self:GetCaster():RemoveModifierByName("modifier_au_impostor_sf_ghost")
end

function au_impostor_sf_ghost_teleport_sf:OnSpellStart()
	if not IsServer() then return end
	self:GetCaster():GetOwner().player:SetCamera( self:GetCaster():GetOwner() )
	self:GetCaster():GetOwner():RemoveGesture( ACT_DOTA_CAST_ABILITY_6)
	self:GetCaster():RemoveModifierByName("modifier_au_impostor_sf_ghost")
end

function modifier_au_impostor_sf_ghost_caster:IsHidden()
	return true
end

function modifier_au_impostor_sf_ghost_caster:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(1)
end

function modifier_au_impostor_sf_ghost_caster:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	local ghost = self:GetAbility().ghost
	local damage = self:GetParent():GetMaxMana()/100*self:GetAbility():GetSpecialValueFor("health_cost")
	local health = self:GetParent():GetMana() - damage
	if damage >= self:GetParent():GetMana() then
		self:GetParent().player:Kill( true, self:GetParent().player, false, true )
	else
		caster:SetMana(health)
		ghost:SetHealth(health)
	end
end

function modifier_au_impostor_sf_ghost_caster:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
	}
end

function modifier_au_impostor_sf_ghost_caster:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }

    return funcs
end

function modifier_au_impostor_sf_ghost_caster:GetBonusDayVision( params )
    return -9999999
end

function modifier_au_impostor_sf_ghost_caster:GetBonusNightVision( params )
    return -9999999
end