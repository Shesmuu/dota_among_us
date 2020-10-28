modifier_au_impostor_morph_caster = {}

function modifier_au_impostor_morph_caster:IsHidden()
	return true
end

function modifier_au_impostor_morph_caster:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true
	}
end

if IsClient() then
	return
end

function modifier_au_impostor_morph_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function modifier_au_impostor_morph_caster:OnCreated()
	self:StartIntervalThink( 0.1 )
end

function modifier_au_impostor_morph_caster:OnIntervalThink()
	local illusion = self:GetAbility().illusion

	if not illusion then
		return
	end

	self:GetParent():SetAbsOrigin( illusion:GetAbsOrigin() )
end

function modifier_au_impostor_morph_caster:OnOrder( data )
	local ability = self:GetAbility()
	local illusion = ability.illusion

	if data.unit ~= self:GetCaster() or not illusion then
		return
	end

	if data.order_type == DOTA_UNIT_ORDER_STOP then
		illusion:Stop()
	elseif data.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
		illusion:MoveToNPC( data.target )
	elseif data.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		illusion:MoveToPosition( data.new_pos )
	end
end

function modifier_au_impostor_morph_caster:OnAbilityExecuted( data )
	if data.unit ~= self:GetParent() then
		return
	end

	if data.ability and data.ability:GetAbilityName() == "au_impostor_kill" then
		--self:GetAbility():Removing()
	end
end