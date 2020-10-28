modifier_au_unselectable = {}

function modifier_au_unselectable:IsHidden()
	return true
end

function modifier_au_unselectable:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true
	}
end

function modifier_au_unselectable:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end