LinkLuaModifier( "modifier_au_vote_kick_vision", "abilities/vote_kick/au_vote_kick", LUA_MODIFIER_MOTION_NONE )

modifier_au_vote_kick_vision = {}

function modifier_au_vote_kick_vision:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_au_vote_kick_vision:OnIntervalThink()
	if not IsServer() then return end
	if GameMode.state == AU_GAME_STATE_KICK_VOTING then
		self:SetStackCount(2000)
	else
		self:SetStackCount(0)
	end
end

function modifier_au_vote_kick_vision:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
	return funcs
end

function modifier_au_vote_kick_vision:GetBonusDayVision()
	return self:GetStackCount()
end

function modifier_au_vote_kick_vision:GetBonusNightVision()
	return self:GetStackCount()
end

au_vote_kick = {}

function au_vote_kick:GetIntrinsicModifierName()
	return "modifier_au_vote_kick_vision"
end

function modifier_au_vote_kick_vision:IsHidden()
	return true
end

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