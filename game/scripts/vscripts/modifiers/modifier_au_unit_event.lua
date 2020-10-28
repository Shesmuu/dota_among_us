modifier_au_unit_event = {}

function modifier_au_unit_event:IsHidden()
	return true
end

if IsClient() then
	return
end

function modifier_au_unit_event:OnCreated()
	self:Event()
end

function modifier_au_unit_event:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ORDER
	}
end

function modifier_au_unit_event:OnOrder()
	self:Event()
end

function modifier_au_unit_event:Event()
	Debug:Execute( function()
		local parent = self:GetParent()
		local caster = self:GetCaster()

		if
			parent.player and
			( parent.player.alive or
			caster.ghostActive ) and
			parent.lastOrder and
			parent.lastOrder.order == DOTA_UNIT_ORDER_MOVE_TO_TARGET and
			parent.lastOrder.target == caster
		then
			caster.event( caster, parent.player )
		end
	end )
end

function modifier_au_unit_event:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end