au_vote_kick = {}

if IsClient() then
	return
end

function au_vote_kick:OnAbilityPhaseStart()
	local target = self:GetCursorTarget()

	if target == self:GetCaster() then
		return false
	end

	if target.player or target:GetUnitName() == "npc_au_quest_kick_voting" then
		return true
	end

	return false
end

function au_vote_kick:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	self:SetActivated( false )

	Debug:Execute( function()
		if target:GetUnitName() == "npc_au_quest_kick_voting" then
			KickVoting:Skip( caster.player )
		else
			KickVoting:Vote( caster.player, target.player )
		end
	end )
end