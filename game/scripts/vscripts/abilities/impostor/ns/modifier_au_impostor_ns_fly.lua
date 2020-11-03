modifier_au_impostor_ns_fly = {}

function modifier_au_impostor_ns_fly:IsHidden()
	return true
end

if IsClient() then
	return
end

function modifier_au_impostor_ns_fly:OnCreated()
	self:OnIntervalThink()
	self:StartIntervalThink( 0.1 )
end

function modifier_au_impostor_ns_fly:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	if GameRules:IsDaytime() then
		if ability:GetToggleState() then
			ability:Removing()
		end

		ability:SetActivated( false )
	else
		ability:SetActivated( true )
	end
end