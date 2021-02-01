LinkLuaModifier( "modifier_au_impostor_bloodseeker_seeking", "abilities/impostor/bloodseeker/modifier_au_impostor_bloodseeker_seeking", LUA_MODIFIER_MOTION_NONE )

modifier_au_impostor_bloodseeker_seeking_aura = {}

function modifier_au_impostor_bloodseeker_seeking_aura:IsAura() return true end
function modifier_au_impostor_bloodseeker_seeking_aura:IsAuraActiveOnDeath() return false end
function modifier_au_impostor_bloodseeker_seeking_aura:IsHidden() return true end
function modifier_au_impostor_bloodseeker_seeking_aura:IsPermanent() return true end
function modifier_au_impostor_bloodseeker_seeking_aura:IsPurgable() return false end

function modifier_au_impostor_bloodseeker_seeking_aura:GetAuraRadius()
	return 9999999
end

function modifier_au_impostor_bloodseeker_seeking_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_au_impostor_bloodseeker_seeking_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_au_impostor_bloodseeker_seeking_aura:GetModifierAura()
	return "modifier_au_impostor_bloodseeker_seeking"
end

modifier_au_impostor_bloodseeker_seeking = {}

function modifier_au_impostor_bloodseeker_seeking:IsHidden() return true end

if IsClient() then
	return
end

function modifier_au_impostor_bloodseeker_seeking:OnCreated()
    self:StartIntervalThink(FrameTime())
end

function modifier_au_impostor_bloodseeker_seeking:OnIntervalThink()
	local caster = self:GetCaster()
	local player = caster.player

	local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
    self:GetParent():GetAbsOrigin(),
    nil,
    self:GetAbility():GetSpecialValueFor("radius"),
    DOTA_UNIT_TARGET_TEAM_BOTH,
    DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
    FIND_ANY_ORDER,
    false)

	local count = 0

	for _, hero in pairs( units ) do
		if hero.player and hero.player.role ~= AU_ROLE_IMPOSTOR and hero.player.alive and hero ~= self:GetParent() then
			count = count + 1
		end
	end

	if count <= 0 then
		if self:GetParent():HasModifier("modifier_au_ghost") then return end
		AddFOWViewer( player.team, self:GetParent():GetAbsOrigin(), 100, FrameTime(), false )
	end
end

