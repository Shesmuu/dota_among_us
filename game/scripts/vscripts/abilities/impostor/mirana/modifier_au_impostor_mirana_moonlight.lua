LinkLuaModifier( "modifier_au_impostor_mirana_moonlight_invisible", "abilities/impostor/mirana/modifier_au_impostor_mirana_moonlight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_mirana_moonlight_fade", "abilities/impostor/mirana/modifier_au_impostor_mirana_moonlight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_mirana_moonlight_visual", "abilities/impostor/mirana/modifier_au_impostor_mirana_moonlight", LUA_MODIFIER_MOTION_NONE )

modifier_au_impostor_mirana_moonlight = {}

function modifier_au_impostor_mirana_moonlight:OnCreated()
	if IsServer() then
		self.fade_delay = self:GetAbility():GetSpecialValueFor("delay")
		self:StartIntervalThink(0.1)
	end
end

function modifier_au_impostor_mirana_moonlight:OnIntervalThink()
	if IsServer() then
		if kickvoting_teleport_start == true then self:Destroy() return end
		local duration = self:GetRemainingTime()
		local allies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			self:GetCaster():GetAbsOrigin(),
			nil,
			FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_HERO,
			0,
			FIND_ANY_ORDER,
			false)


		for _,ally in pairs(allies) do
			if
				ally.player and
				ally.player.role == AU_ROLE_IMPOSTOR and
				ally.player.alive
			then
				if not ally:HasModifier("modifier_au_impostor_mirana_moonlight_invisible") then
					ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_au_impostor_mirana_moonlight_visual", {duration = duration})
					ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_au_impostor_mirana_moonlight_invisible", {duration = duration})
					ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_au_impostor_mirana_moonlight_fade", {duration = self.fade_delay})
				end
			end
		end
	end
end

function modifier_au_impostor_mirana_moonlight:OnDestroy()
	if IsServer() then
		local allies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
			self:GetCaster():GetAbsOrigin(),
			nil,
			FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_HERO,
			0,
			FIND_ANY_ORDER,
			false)

		for _,ally in pairs(allies) do
			if ally.player then
				if ally:HasModifier("modifier_au_impostor_mirana_moonlight_invisible") then
					ally:RemoveModifierByName("modifier_au_impostor_mirana_moonlight_invisible")
					ally:RemoveModifierByName("modifier_au_impostor_mirana_moonlight_visual")
				end
			end
		end
	end
end

modifier_au_impostor_mirana_moonlight_invisible = class({})

function modifier_au_impostor_mirana_moonlight_invisible:OnCreated()
	if IsServer() then
		self.visual_modifier = self:GetParent():FindModifierByName("modifier_au_impostor_mirana_moonlight_visual")
		self.fade_delay = self:GetAbility():GetSpecialValueFor("delay")
		self:StartIntervalThink(0.1)
	end
end

function modifier_au_impostor_mirana_moonlight_invisible:IsHidden() return true end

function modifier_au_impostor_mirana_moonlight_invisible:OnIntervalThink()
	if self:GetStackCount() == 0 then
		return nil
	end
	self:SetStackCount(1)
end

function modifier_au_impostor_mirana_moonlight_invisible:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end

function modifier_au_impostor_mirana_moonlight_invisible:GetModifierInvisibilityLevel()
	if self:GetStackCount() == 1 then
		return 1
	else
		return 0
	end
end

function modifier_au_impostor_mirana_moonlight_invisible:OnAbilityExecuted(keys)
	if IsServer() then
		local unit = keys.unit
		if self:GetParent() == unit then
			self:SetStackCount(0)
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_au_impostor_mirana_moonlight_fade", {duration = self.fade_delay})
		end
	end
end

function modifier_au_impostor_mirana_moonlight_invisible:CheckState()
	if self:GetStackCount() == 0 then
		return nil
	end
	return {[MODIFIER_STATE_INVISIBLE] = true}
end

modifier_au_impostor_mirana_moonlight_visual = class({})

function modifier_au_impostor_mirana_moonlight_visual:IsHidden() return true end

function modifier_au_impostor_mirana_moonlight_visual:OnCreated()
	if IsServer() then
		local player = PlayerResource:GetPlayer( self:GetParent():GetPlayerOwnerID() )
		self.moon_particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), player)
		ParticleManager:SetParticleControl(self.moon_particle, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(self.moon_particle, false, false, -1, false, true)
	end
end

modifier_au_impostor_mirana_moonlight_fade = class({})

function modifier_au_impostor_mirana_moonlight_fade:IsHidden() return true end

function modifier_au_impostor_mirana_moonlight_fade:OnDestroy()
	if IsServer() then
		local modifier = self:GetParent():FindModifierByName("modifier_au_impostor_mirana_moonlight_invisible")
		if modifier then
			modifier:SetStackCount(1)
		end
	end
end

