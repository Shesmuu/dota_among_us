modifier_au_impostor_zuus_global = {}

function modifier_au_impostor_zuus_global:IsHidden()
	return true
end

if IsClient() then
	return
end

function modifier_au_impostor_zuus_global:OnCreated()
	local caster = self:GetParent()
	local player = caster.player
	local pos = caster:GetAbsOrigin()

	self:StartIntervalThink( 0.1 )

	if player.role == AU_ROLE_IMPOSTOR then
		return
	end

	for _, p in pairs( GameMode.players ) do
		if p.role == AU_ROLE_IMPOSTOR and p.hero and p.alive then
			local effect = ParticleManager:CreateParticleForTeam(
				"particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf",
				PATTACH_ABSORIGIN_FOLLOW,
				caster,
				p.team
			)
			ParticleManager:SetParticleControl( effect, 0, pos )
			ParticleManager:SetParticleControl( effect, 1, pos + Vector( 0, 0, 2000 ) )
			ParticleManager:SetParticleControl( effect, 2, pos )
		end
	end
end

function modifier_au_impostor_zuus_global:OnIntervalThink()
	for _, player in pairs( GameMode.players ) do
		if player.role == AU_ROLE_IMPOSTOR and player.hero and player.alive then
			AddFOWViewer( player.team, self:GetParent():GetAbsOrigin(), 2000, 0.1, false )
		end
	end
end