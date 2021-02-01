LinkLuaModifier( "modifier_au_impostor_weaver_invis", "abilities/impostor/weaver/modifier_au_impostor_weaver_invis", LUA_MODIFIER_MOTION_NONE )

au_impostor_weaver_invis = {}

if IsClient() then
	return
end

function au_impostor_weaver_invis:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier( caster, self, "modifier_au_impostor_weaver_invis", {
		duration = self:GetSpecialValueFor( "duration" )
	} )
end

function au_impostor_weaver_invis:Removing()
	self:GetCaster():RemoveModifierByName( "modifier_au_impostor_weaver_invis" )
end