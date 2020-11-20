modifier_au_impostor_sf_souls = {}

function modifier_au_impostor_sf_souls:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
end

function modifier_au_impostor_sf_souls:OnTooltip()
	return self:GetStackCount()
end

function modifier_au_impostor_sf_souls:OnAbilityFullyCast() end

if IsClient() then
	return
end

function modifier_au_impostor_sf_souls:OnCreated()
	self:StartIntervalThink( 0.2 )
end

function modifier_au_impostor_sf_souls:OnIntervalThink()
	Debug:Execute( function()
		local units = FindUnitsInRadius(
			DOTA_TEAM_GOODGUYS,
			self:GetParent():GetAbsOrigin(),
			nil,
			2500,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_CLOSEST,
			false
		)

		local count = 0

		for _, hero in pairs( units ) do
			if
				hero.player and
				hero.player.role ~= AU_ROLE_IMPOSTOR and
				hero.player.alive
			then
				count = count + 1
			end
		end

		self:SetStackCount( count )
	end )
end

function modifier_au_impostor_sf_souls:OnAbilityFullyCast( data )
	local caster = self:GetCaster()

	if data.unit ~= caster or data.ability:GetAbilityName() ~= "au_impostor_kill" or data.ability:IsCooldownReady() then
		return
	end

	caster:AddNewModifier( caster, self:GetAbility(), "modifier_au_impostor_sf_souls_vision", {
		duration = self:GetAbility():GetSpecialValueFor( "duration" )
	} )
end