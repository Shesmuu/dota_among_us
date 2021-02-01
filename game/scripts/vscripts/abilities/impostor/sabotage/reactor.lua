au_impostor_sabotage_reactor = {}

function au_impostor_sabotage_reactor:OnSpellStart()
	Debug:Execute( function()
		Sabotage:GetSabotage( AU_SABOTAGE_REACTOR ):Start(self:GetCaster().player)
	end )
end