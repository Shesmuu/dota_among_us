LinkLuaModifier( "modifier_au_impostor_ns_fly", "abilities/impostor/ns/modifier_au_impostor_ns_fly", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_ns_fly_flying", "abilities/impostor/ns/modifier_au_impostor_ns_fly_flying", LUA_MODIFIER_MOTION_NONE )

au_impostor_ns_fly = {}

if IsClient() then
	return
end

function au_impostor_ns_fly:GetIntrinsicModifierName()
	return "modifier_au_impostor_ns_fly"
end

function au_impostor_ns_fly:OnToggle()
	local caster = self:GetCaster()

	if self:GetToggleState() then
		caster:AddNewModifier( caster, self, "modifier_au_impostor_ns_fly_flying", nil )
	else
		caster:RemoveModifierByName( "modifier_au_impostor_ns_fly_flying" )

		self:StartCooldown( self:GetCooldown( 1 ) )
	end
end

function au_impostor_ns_fly:Removing()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName( "modifier_au_impostor_ns_fly_flying" )
		self:ToggleAbility()
	end
end

function au_impostor_ns_fly:RemovePreapring()
	self:Removing()
end