modifier_au_impostor_riki_smoke_invis = {}

function modifier_au_impostor_riki_smoke_invis:IsHidden()
	return true
end

function modifier_au_impostor_riki_smoke_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true
	}
end

if IsClient() then
	return
end

function modifier_au_impostor_riki_smoke_invis:OnCreated()
	self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_au_impostor_riki_smoke", nil )
end

function modifier_au_impostor_riki_smoke_invis:OnDestroy()
	self:GetParent():RemoveModifierByName( "modifier_au_impostor_riki_smoke" )
end