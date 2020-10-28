au_impostor_sabotage_interference = {}

function au_impostor_sabotage_interference:OnSpellStart()
	Debug:Execute( function()
		Sabotage:GetSabotage( AU_SABOTAGE_INTERFERENCE ):Start()
	end )
end