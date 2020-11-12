modifier_au_impostor_riki_smoke_thinker = {}

if IsClient() then
	return
end

function modifier_au_impostor_riki_smoke_thinker:OnCreated()
	self:StartIntervalThink( 0.1 )
end

function modifier_au_impostor_riki_smoke_thinker:OnIntervalThink()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local duration = {
		duration = 0.15
	}
	local units = FindUnitsInRadius(
		0,
		parent:GetAbsOrigin(),
		nil,
		ability:GetSpecialValueFor( "radius" ),
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_ANY_ORDER,
		false
	)

	for _, unit in pairs( units ) do
		for _, u in pairs( units ) do
			if u == caster or u:GetUnitName() == "npc_au_tomb" then
				u:AddNewModifier( unit, nil, "modifier_truesight", duration )
			end
		end

		if unit == caster or unit:GetUnitName() == "npc_au_tomb" then
			unit:AddNewModifier( caster, ability, "modifier_au_impostor_riki_smoke_invis", duration )
		end
	end
end