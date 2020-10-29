modifier_au_impostor_pudge_eat = {}

function modifier_au_impostor_pudge_eat:IsHidden()
	return false
end

function modifier_au_impostor_pudge_eat:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

if IsClient() then
	return
end

function modifier_au_impostor_pudge_eat:OnCreated()
	self:GetParent():AddNoDraw()
	self:StartIntervalThink( 0 )
end

function modifier_au_impostor_pudge_eat:OnIntervalThink()
	self:GetParent():SetAbsOrigin( self:GetCaster():GetAbsOrigin() )
end

function modifier_au_impostor_pudge_eat:OnDestroy()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local pos = caster:GetAbsOrigin()

	parent:RemoveNoDraw()
	parent:SetAbsOrigin( pos )

	Debug:Execute( function()
		parent.player:Kill( true, caster.player, false, true )
	end )

	ability.hero = nil
	ability:StartCooldown( ability:GetSpecialValueFor( "cooldown" ) )

	FindClearSpaceForUnit( caster, pos, true )
end