LinkLuaModifier( "modifier_au_impostor_mirana_moonlight", "abilities/impostor/mirana/modifier_au_impostor_mirana_moonlight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_mirana_moonlight_night", "abilities/impostor/mirana/au_impostor_mirana_moonlight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_mirana_moonlight_invisible", "abilities/impostor/mirana/modifier_au_impostor_mirana_moonlight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_mirana_moonlight_fade", "abilities/impostor/mirana/modifier_au_impostor_mirana_moonlight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_mirana_moonlight_visual", "abilities/impostor/mirana/modifier_au_impostor_mirana_moonlight", LUA_MODIFIER_MOTION_NONE )

au_impostor_mirana_moonlight = class({})

function au_impostor_mirana_moonlight:GetIntrinsicModifierName()
	return "modifier_au_impostor_mirana_moonlight_night"
end

function au_impostor_mirana_moonlight:OnSpellStart()
	if not IsServer() then return end
	local duration = self:GetSpecialValueFor("duration")
	local player = PlayerResource:GetPlayer( self:GetCaster():GetPlayerOwnerID() )
	local particle_moon = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_mirana/mirana_moonlight_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), player)
	ParticleManager:SetParticleControlEnt(particle_moon, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle_moon)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_mirana_moonlight", {duration = duration})
end

modifier_au_impostor_mirana_moonlight_night = {}

function modifier_au_impostor_mirana_moonlight_night:IsHidden()
	return true
end

function modifier_au_impostor_mirana_moonlight_night:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_au_impostor_mirana_moonlight_night:OnIntervalThink()
	if IsServer() then
		if GameRules:IsDaytime() then
			self:GetAbility():SetActivated( false )
		else
			self:GetAbility():SetActivated( true )
		end
	end
end