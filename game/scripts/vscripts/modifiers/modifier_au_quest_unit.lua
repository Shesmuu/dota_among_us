modifier_au_quest_unit = {}

function modifier_au_quest_unit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
end

function modifier_au_quest_unit:GetModifierProvidesFOWVision()
	return 1
end