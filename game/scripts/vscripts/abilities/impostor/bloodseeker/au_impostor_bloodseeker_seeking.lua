LinkLuaModifier( "modifier_au_impostor_bloodseeker_seeking", "abilities/impostor/bloodseeker/modifier_au_impostor_bloodseeker_seeking", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_bloodseeker_seeking_aura", "abilities/impostor/bloodseeker/modifier_au_impostor_bloodseeker_seeking", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_bloodseeker_seeking_speed", "abilities/impostor/bloodseeker/modifier_au_impostor_bloodseeker_seeking_speed", LUA_MODIFIER_MOTION_NONE )

au_impostor_bloodseeker_seeking = {}

function au_impostor_bloodseeker_seeking:GetIntrinsicModifierName()
    return "modifier_au_impostor_bloodseeker_seeking_aura"
end

function au_impostor_bloodseeker_seeking:OnToggle()
	local caster = self:GetCaster()

	if self:GetToggleState() then
		caster:AddNewModifier( caster, self, "modifier_au_impostor_bloodseeker_seeking_speed", nil )
	else
		caster:RemoveModifierByName( "modifier_au_impostor_bloodseeker_seeking_speed" )
		self:StartCooldown(3)
	end
end

function au_impostor_bloodseeker_seeking:Removing()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName( "modifier_au_impostor_bloodseeker_seeking_speed" )
		self:ToggleAbility()
	end
end

function au_impostor_bloodseeker_seeking:RemovePreapring()
	self:Removing()
end