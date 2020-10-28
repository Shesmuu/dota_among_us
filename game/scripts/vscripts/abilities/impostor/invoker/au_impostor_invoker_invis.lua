LinkLuaModifier( "modifier_au_impostor_invoker_invis", "abilities/impostor/invoker/modifier_au_impostor_invoker_invis", LUA_MODIFIER_MOTION_NONE )

au_impostor_invoker_invis = {}

if IsClient() then
	return
end

function au_impostor_invoker_invis:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier( caster, self, "modifier_au_impostor_invoker_invis", {
		duration = self:GetSpecialValueFor( "duration" )
	} )
end

function au_impostor_invoker_invis:Removing()
	self:GetCaster():RemoveModifierByName( "modifier_au_impostor_invoker_invis" )
end