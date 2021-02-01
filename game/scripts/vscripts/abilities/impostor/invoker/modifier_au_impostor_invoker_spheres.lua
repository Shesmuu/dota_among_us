modifier_au_impostor_invoker_exort = {}
modifier_au_impostor_invoker_quas = {}
modifier_au_impostor_invoker_wex = {}
modifier_au_impostor_invoker_quas_debuff = {}
modifier_au_impostor_invoker_quas_debuff_frozen = {}
modifier_au_impostor_invoker_wex_position = {}
modifier_au_impostor_invoker_exort_sun = {}

modifier_au_impostor_invoker_quas_check = {}

function modifier_au_impostor_invoker_quas_check:IsHidden()
	return true
end

function modifier_au_impostor_invoker_wex_position:IsHidden()
	return true
end

function modifier_au_impostor_invoker_quas_debuff:IsHidden()
  	return true
end

function modifier_au_impostor_invoker_quas_debuff_frozen:IsHidden()
  	return true
end

function modifier_au_impostor_invoker_exort_sun:IsHidden()
	return true
end

function modifier_au_impostor_invoker_exort:GetTexture()
  	return "invoker_exort"
end

function modifier_au_impostor_invoker_wex:GetTexture()
  	return "invoker_wex"
end

function modifier_au_impostor_invoker_quas:GetTexture()
  	return "invoker_quas"
end

function modifier_au_impostor_invoker_quas_debuff:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
	self.pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_drow/drow_hypothermia_counter_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster().player.team)
	self.stack = 0
	self:SetStackCount(3)
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self:GetStackCount(), 0))
end

function modifier_au_impostor_invoker_quas_debuff:OnIntervalThink()
	if not IsServer() then return end
	if kickvoting_teleport_start == true then self:Destroy() return end
	self.stack = self.stack + 1
	if self.stack == 33 then
		self:SetStackCount(self:GetStackCount()-1)
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self:GetStackCount(), 0))
		self.stack = 1
	end
	for _, p in pairs( GameMode.players ) do
		if p.role == AU_ROLE_IMPOSTOR and p.hero and p.alive then
			AddFOWViewer( p.team, self:GetParent():GetAbsOrigin(), 100, FrameTime(), false )
		end
	end
end

function modifier_au_impostor_invoker_quas_debuff:OnDestroy()
	if not IsServer() then return end
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	if kickvoting_teleport_start == true then return end
  	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_au_impostor_invoker_quas_debuff_frozen", {duration = self:GetAbility():GetSpecialValueFor("duration")})
end

function modifier_au_impostor_invoker_quas_debuff_frozen:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_au_impostor_invoker_quas_debuff_frozen:OnIntervalThink()
	if not IsServer() then return end
	if kickvoting_teleport_start == true then self:Destroy() return end
	for _, p in pairs( GameMode.players ) do
		if p.role == AU_ROLE_IMPOSTOR and p.hero and p.alive then
			AddFOWViewer( p.team, self:GetParent():GetAbsOrigin(), 100, FrameTime(), false )
		end
	end
end

function modifier_au_impostor_invoker_quas_debuff_frozen:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf"
end

function modifier_au_impostor_invoker_quas_debuff_frozen:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_au_impostor_invoker_wex_position:OnCreated(kv)
	if not IsServer() then return end
	local radius_active = self:GetAbility():GetSpecialValueFor("vision")
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	for _, p in pairs( GameMode.players ) do
		if p.role == AU_ROLE_IMPOSTOR and p.hero and p.alive then
			self.particle = ParticleManager:CreateParticleForTeam("particles/items4_fx/seer_stone.vpcf", PATTACH_WORLDORIGIN, self:GetParent(), p.team)
			ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle, 1, Vector(duration+0.5, radius_active, 0))
		end
	end
	self:StartIntervalThink(FrameTime())
end

function modifier_au_impostor_invoker_wex_position:OnIntervalThink()
	if not IsServer() then return end
	if kickvoting_teleport_start == true then self:Destroy() return end
	local radius_active = self:GetAbility():GetSpecialValueFor("vision")
	for _, p in pairs( GameMode.players ) do
		if p.role == AU_ROLE_IMPOSTOR and p.hero and p.alive then
			AddFOWViewer( p.team, self:GetParent():GetAbsOrigin(), radius_active, FrameTime(), false )
		end
	end
end

function modifier_au_impostor_invoker_exort:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
    }

    return funcs
end

function modifier_au_impostor_invoker_exort:GetBonusDayVision( params )
	if self:GetParent():GetMana() <= 3 then return 0 end
    return self:GetAbility():GetSpecialValueFor("vision")
end

function modifier_au_impostor_invoker_wex:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }

    return funcs
end

function modifier_au_impostor_invoker_wex:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

if not IsServer() then return end

function modifier_au_impostor_invoker_exort:OnCreated()
    if not IsServer() then return end
	self.orb_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_1, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb1", self:GetParent():GetAbsOrigin(), false)
    self.orb_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb2", self:GetParent():GetAbsOrigin(), false)
    self.orb_3 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_3, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb3", self:GetParent():GetAbsOrigin(), false)
    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_au_impostor_invoker_exort:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent().player.role ~= AU_ROLE_IMPOSTOR then
    	if (self:GetParent():GetMana() - (self:GetAbility():GetSpecialValueFor("manacost_exort")*0.1)) >= 0 then
	    	self:GetParent():SpendMana((self:GetAbility():GetSpecialValueFor("manacost_exort")*0.1), self:GetAbility())
	    end
	end
end

function modifier_au_impostor_invoker_exort:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle( self.orb_1, false )
	ParticleManager:DestroyParticle( self.orb_2, false )
	ParticleManager:DestroyParticle( self.orb_3, false )
end

function modifier_au_impostor_invoker_wex:OnCreated()
    if not IsServer() then return end
    self.orb_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_1, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb1", self:GetParent():GetAbsOrigin(), false)
    self.orb_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb2", self:GetParent():GetAbsOrigin(), false)
    self.orb_3 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_3, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb3", self:GetParent():GetAbsOrigin(), false)
    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end

function modifier_au_impostor_invoker_wex:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent().player.role ~= AU_ROLE_IMPOSTOR then
    	if (self:GetParent():GetMana() - (self:GetAbility():GetSpecialValueFor("manacost")*0.1)) >= 0 then
			self:GetParent():SpendMana((self:GetAbility():GetSpecialValueFor("manacost")*0.1), self:GetAbility())
		else
			self:GetParent():CastAbilityNoTarget(self:GetAbility(), self:GetParent():GetPlayerID())
		end
	end
end

function modifier_au_impostor_invoker_wex:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle( self.orb_1, false )
	ParticleManager:DestroyParticle( self.orb_2, false )
	ParticleManager:DestroyParticle( self.orb_3, false )
end

function modifier_au_impostor_invoker_quas:OnCreated()
	if not IsServer() then return end
	self.orb_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_1, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb1", self:GetParent():GetAbsOrigin(), false)
    self.orb_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb2", self:GetParent():GetAbsOrigin(), false)
    self.orb_3 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.orb_3, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_orb3", self:GetParent():GetAbsOrigin(), false)
    self.timeElapsed = 0
	self.cooldownTick = 1
    self:StartIntervalThink( 0 )
end

function modifier_au_impostor_invoker_quas:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }

    return funcs
end

function modifier_au_impostor_invoker_quas:GetModifierConstantManaRegen()
	if not IsServer() then return end
	if self:GetParent().player.role == AU_ROLE_IMPOSTOR then return end
	return self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_au_impostor_invoker_quas:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle( self.orb_1, false )
	ParticleManager:DestroyParticle( self.orb_2, false )
	ParticleManager:DestroyParticle( self.orb_3, false )
end

function modifier_au_impostor_invoker_quas:OnIntervalThink()
	 if self:GetParent().player.role == AU_ROLE_IMPOSTOR then
		local caster = self:GetCaster()
		local ability = caster:FindAbilityByName( "au_impostor_invoker_wex" )
		local ability2 = caster:FindAbilityByName( "au_impostor_invoker_quas" )
		local ability3 = caster:FindAbilityByName( "au_impostor_invoker_exort" )

		self.timeElapsed = self.timeElapsed + 0.03
		if math.floor( self.timeElapsed ) >= self.cooldownTick then
			if not ability:IsCooldownReady() then
				local time = ability:GetCooldownTimeRemaining() - 0.3

				ability:EndCooldown()
				ability:StartCooldown( time )
			end
			if not ability2:IsCooldownReady() then
				local time = ability2:GetCooldownTimeRemaining() - 0.3

				ability2:EndCooldown()
				ability2:StartCooldown( time )
			end
			if not ability3:IsCooldownReady() then
				local time = ability3:GetCooldownTimeRemaining() - 0.3

				ability3:EndCooldown()
				ability3:StartCooldown( time )
			end
			self.cooldownTick = self.cooldownTick + 1
		end
	end
end

function modifier_au_impostor_invoker_quas_debuff_frozen:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end

function modifier_au_impostor_invoker_exort_sun:OnCreated( kv )
	if IsServer() then
		local sun_strike = ParticleManager:CreateParticleForTeam(  "particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
		ParticleManager:SetParticleControl( sun_strike, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( sun_strike, 1, Vector( 175, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( sun_strike )
	end
end

function modifier_au_impostor_invoker_exort_sun:OnDestroy( kv )
	if IsServer() then
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),
			self:GetParent():GetOrigin(),
			nil,
			175,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			0,
			false
		)

		if kickvoting_teleport_start == true then UTIL_Remove( self:GetParent() ) return end

		for i = 1, #enemies do
			if enemies[i].player and enemies[i].player.role ~= AU_ROLE_IMPOSTOR and enemies[i].player.alive and enemies[i] ~= self:GetParent() then
				local target = enemies[i]
				if target:HasModifier("modifier_au_tiny_toss") then return end
				target.player:Kill( true, self:GetCaster().player, false, true )
				break
			end
		end

		local destroy_particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControl( destroy_particle, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( destroy_particle, 1, Vector( 175, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( destroy_particle )
		UTIL_Remove( self:GetParent() )
	end
end


function modifier_au_impostor_invoker_quas_check:OnCreated()
	self.radius = self:GetAbility():GetCastRange()
	self:StartIntervalThink( 0.2 )
end

function modifier_au_impostor_invoker_quas_check:OnIntervalThink()
	Debug:Execute( function()
		local ability = self:GetAbility()
		local parent = self:GetParent()

		if not ability:IsActivated() or ability:IsHidden() then
			ability.target = nil
			self:DestroyEffect()

			return
		end

		local units = FindUnitsInRadius(
			DOTA_TEAM_GOODGUYS,
			self:GetParent():GetAbsOrigin(),
			nil,
			800,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_CLOSEST,
			false
		)

		for _, hero in pairs( units ) do
			if
				hero.player and
				hero ~= parent and
				parent:GetPlayerOwnerID() ~= hero.player.id and
				hero.player.role ~= AU_ROLE_IMPOSTOR and
				hero.player.alive
			then
				if ability.target ~= hero then
					ability.target = hero
					local player = PlayerResource:GetPlayer( parent:GetPlayerOwnerID() )

					self:DestroyEffect()

					if player then
						self.effect = ParticleManager:CreateParticleForPlayer(
							"particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_target.vpcf",
							PATTACH_OVERHEAD_FOLLOW,
							hero,
							player
						)
					end
				end

				return
			end
		end

		ability.target = nil

		self:DestroyEffect()
	end )
end

function modifier_au_impostor_invoker_quas_check:DestroyEffect()
	if self.effect then
		ParticleManager:DestroyParticle( self.effect, true )

		self.effect = nil
	end
end

function modifier_au_impostor_invoker_quas_check:OnRemove()
	self:DestroyEffect()
end

function modifier_au_impostor_invoker_quas_check:OnDestroy()
	self:DestroyEffect()
end