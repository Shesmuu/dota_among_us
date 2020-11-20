LinkLuaModifier( "modifier_au_ogre_bloodlust", "abilities/ogre/modifier_au_ogre_bloodlust", LUA_MODIFIER_MOTION_NONE )

au_ogre_bloodlust = {}

function au_ogre_bloodlust:GetManaCost()
	local caster = self:GetCaster()
	local t = CustomNetTables:GetTableValue( "player", tostring( caster:GetPlayerOwnerID() ) )

	if t and t.role == 1 then
		return 0
	else
		return 40
	end
end

function au_ogre_bloodlust:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier( caster, self, "modifier_au_ogre_bloodlust", {
		duration = self:GetSpecialValueFor( "duration" )
	} )
end