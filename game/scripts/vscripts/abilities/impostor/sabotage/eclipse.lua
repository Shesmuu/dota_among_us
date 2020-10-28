au_impostor_sabotage_eclipse = {}

function au_impostor_sabotage_eclipse:OnSpellStart()
	Debug:Execute( function()
		Sabotage:GetSabotage( AU_SABOTAGE_ECLIPSE ):Start()
	end )
end