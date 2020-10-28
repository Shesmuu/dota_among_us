LinkLuaModifier( "modifier_au_impostor_sf_souls", "abilities/impostor/sf/modifier_au_impostor_sf_souls", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_sf_souls_vision", "abilities/impostor/sf/modifier_au_impostor_sf_souls_vision", LUA_MODIFIER_MOTION_NONE )

au_impostor_sf_souls = {}

function au_impostor_sf_souls:GetIntrinsicModifierName()
    return "modifier_au_impostor_sf_souls"
end