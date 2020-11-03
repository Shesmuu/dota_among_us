modifier_au_impostor_mk_mischief = {}

function modifier_au_impostor_mk_mischief:IsHidden()
	return true
end

function modifier_au_impostor_mk_mischief:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

if IsClient() then
	return
end

function modifier_au_impostor_mk_mischief:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true
	}
end

function modifier_au_impostor_mk_mischief:OnCreated()
	local parent = self:GetParent()

	parent:AddNoDraw()

	self.prop = Entities:CreateByClassname( "prop_dynamic" )
	self.prop:SetModel( "models/props_nature/mushroom_wild001.vmdl" )
	self.timeElapsed = 0
	self.cooldownTick = 1

	self:StartIntervalThink( 0 )
end

function modifier_au_impostor_mk_mischief:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName( "au_impostor_kill" )

	self.prop:SetAbsOrigin( caster:GetAbsOrigin() )
	self.prop:SetForwardVector( caster:GetForwardVector() )

	self.timeElapsed = self.timeElapsed + 0.03

	if math.floor( self.timeElapsed ) >= self.cooldownTick then
		if not ability:IsCooldownReady() then
			local time = ability:GetCooldownTimeRemaining() - 0.3

			ability:EndCooldown()
			ability:StartCooldown( time )
		end

		self.cooldownTick = self.cooldownTick + 1
	end
end

function modifier_au_impostor_mk_mischief:OnAbilityExecuted( data )
	--if data.unit ~= self:GetParent() then
	--	return
	--end

	--if data.ability and data.ability:GetAbilityName() == "au_impostor_kill" then
	--	self:GetAbility():Removing()
	--end
end

function modifier_au_impostor_mk_mischief:OnDestroy()
	local ability = self:GetAbility()
	local parent = self:GetParent()

	parent:RemoveNoDraw()

	ability:StartCooldown( ability:GetSpecialValueFor( "cooldown" ) )

	self.prop:Destroy()
end