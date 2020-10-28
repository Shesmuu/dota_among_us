LinkLuaModifier( "modifier_au_impostor_mk_mischief", "abilities/impostor/mk/modifier_au_impostor_mk_mischief", LUA_MODIFIER_MOTION_NONE )

au_impostor_mk_mischief = {}

function au_impostor_mk_mischief:GetAbilityTextureName()
	if self:GetCaster():HasModifier( "modifier_au_impostor_mk_mischief" ) then
		return "monkey_king_untransform"
	else
		return "monkey_king_mischief"
	end
end

if IsClient() then
	return
end

function au_impostor_mk_mischief:OnSpellStart()
	local caster = self:GetCaster()

	if caster:HasModifier( "modifier_au_impostor_mk_mischief" ) then
		self:GetCaster():RemoveModifierByName( "modifier_au_impostor_mk_mischief" )
	else
		local modifier = caster:AddNewModifier( caster, self, "modifier_au_impostor_mk_mischief", nil )
	end
end

function au_impostor_mk_mischief:Removing()
	self:GetCaster():RemoveModifierByName( "modifier_au_impostor_mk_mischief" )
end 