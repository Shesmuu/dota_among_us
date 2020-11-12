LinkLuaModifier( "modifier_au_impostor_riki_smoke_thinker", "abilities/impostor/riki/modifier_au_impostor_riki_smoke_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_riki_smoke_invis", "abilities/impostor/riki/modifier_au_impostor_riki_smoke_invis", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_riki_smoke", "abilities/impostor/riki/modifier_au_impostor_riki_smoke", LUA_MODIFIER_MOTION_NONE )

au_impostor_riki_smoke = {}

if IsClient() then
	return
end

function au_impostor_riki_smoke:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor( "radius" )

	self:Removing()

	self.thinker = CreateModifierThinker(
		caster,
		self,
		"modifier_au_impostor_riki_smoke_thinker",
		nil,
		caster:GetAbsOrigin(),
		0,
		false
	)

	self.effects = {}

	for _, p in pairs( GameMode.players ) do
		if p.role == AU_ROLE_IMPOSTOR and p.hero and p.alive then
			local effect = ParticleManager:CreateParticleForTeam(
				"particles/units/heroes/hero_riki/riki_smokebomb.vpcf",
				PATTACH_WORLDORIGIN,
				nil,
				p.team
			)

			ParticleManager:SetParticleControl( effect, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( effect, 1, Vector( radius, 0, radius ) )

			self.effects[p.team] = effect
		end
	end
end

function au_impostor_riki_smoke:Removing()
	if self.thinker then
		self.thinker:Destroy()

		for _, effect in pairs( self.effects or {} ) do
			ParticleManager:DestroyParticle( effect, false )
			ParticleManager:ReleaseParticleIndex( effect )
		end

		self.thinker = nil
	end
end