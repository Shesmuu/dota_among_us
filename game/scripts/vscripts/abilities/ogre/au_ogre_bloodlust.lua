LinkLuaModifier( "modifier_au_ogre_bloodlust", "abilities/ogre/modifier_au_ogre_bloodlust", LUA_MODIFIER_MOTION_NONE )

au_ogre_bloodlust = {}

function au_ogre_bloodlust:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier( caster, self, "modifier_au_ogre_bloodlust", {
		duration = self:GetSpecialValueFor( "duration" )
	} )
end