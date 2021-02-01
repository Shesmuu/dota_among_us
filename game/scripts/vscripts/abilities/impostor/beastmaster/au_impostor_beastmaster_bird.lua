LinkLuaModifier( "modifier_au_impostor_beastmaster_bird", "abilities/impostor/beastmaster/modifier_au_impostor_beastmaster_bird", LUA_MODIFIER_MOTION_NONE )

au_impostor_beastmaster_bird = {}

if IsClient() then
	return
end

function au_impostor_beastmaster_bird:OnSpellStart()
	local point = self:GetCaster():GetAbsOrigin()
	local caster = self:GetCaster()
	local player = caster.player

	self.bird = CreateUnitByName("npc_dota_beastmaster_hawk", point, false, self:GetCaster(), self:GetCaster(), player.team)
	self.bird:AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_beastmaster_bird", {duration = self:GetSpecialValueFor("duration")})
	self.bird:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	local speed = self:GetSpecialValueFor("movespeed")
	self.bird:SetBaseMoveSpeed(speed)
end