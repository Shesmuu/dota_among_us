modifier_au_impostor_kill = {}

function modifier_au_impostor_kill:IsHidden()
	return true
end

if IsClient() then
	return
end

function modifier_au_impostor_kill:OnCreated()
	self.radius = self:GetAbility():GetCastRange()
	self:StartIntervalThink( 0.2 )
end

function modifier_au_impostor_kill:OnIntervalThink()
	Debug:Execute( function()
		local ability = self:GetAbility()
		local parent = self:GetParent()

		if not ability:IsActivated() or ability:IsHidden() then
			ability.target = nil

			self:DestroyEffect()

			return
		end

		local units = FindUnitsInRadius(
			DOTA_TEAM_GOODGUYS,
			self:GetParent():GetAbsOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_BOTH,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_CLOSEST,
			false
		)

		for _, hero in pairs( units ) do
			if
				hero.player and
				hero ~= parent and
				parent:GetPlayerOwnerID() ~= hero.player.id and
				hero.player.role ~= AU_ROLE_IMPOSTOR and
				hero.player.alive and not hero:HasModifier("modifier_au_tiny_toss")
			then
				if ability.target ~= hero.player then
					ability.target = hero.player

					local player = PlayerResource:GetPlayer( parent:GetPlayerOwnerID() )

					self:DestroyEffect()

					if player then
						self.effect = ParticleManager:CreateParticleForPlayer(
							"particles/nearby_kill_target/silencer_curse.vpcf",
							PATTACH_OVERHEAD_FOLLOW,
							hero,
							player
						)
					end
				end

				return
			end
		end

		ability.target = nil

		self:DestroyEffect()
	end )
end

function modifier_au_impostor_kill:DestroyEffect()
	if self.effect then
		ParticleManager:DestroyParticle( self.effect, true )

		self.effect = nil
	end
end

function modifier_au_impostor_kill:OnRemove()
	self:DestroyEffect()
end

function modifier_au_impostor_kill:OnDestroy()
	self:DestroyEffect()
end