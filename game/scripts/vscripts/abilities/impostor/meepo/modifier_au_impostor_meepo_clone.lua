modifier_au_impostor_meepo_clone = {}

function modifier_au_impostor_meepo_clone:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true
	}
end

if IsClient() then
	return
end

function modifier_au_impostor_meepo_clone:OnDestroy()
	Debug:Execute( function()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local casterKill = caster:FindAbilityByName( "au_impostor_kill" )
		local parentKillCd = parent:FindAbilityByName( "au_impostor_kill" ):GetCooldownTimeRemaining()

		self:GetAbility().illusion = nil

		if casterKill then
			casterKill:SetActivated( true )

			if parentKillCd and parentKillCd > 0 then
				casterKill:StartCooldown( parentKillCd )
			end
		end

		parent:Destroy()
	end )
end