au_impostor_sabotage_oxygen = {}

function au_impostor_sabotage_oxygen:OnSpellStart()
	Debug:Execute( function()
		Sabotage:GetSabotage( AU_SABOTAGE_OXYGEN ):Start(self:GetCaster().player)
	end )
end