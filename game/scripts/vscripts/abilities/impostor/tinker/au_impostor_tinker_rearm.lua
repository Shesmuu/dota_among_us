au_impostor_tinker_rearm = {}

if IsClient() then
	return
end

function au_impostor_tinker_rearm:OnSpellStart()
	local caster = self:GetCaster()

	caster:StartGesture( ACT_DOTA_TINKER_REARM1 )

	Delay( 0.03 * 60, function()
		if self:IsChanneling() then
			caster:FadeGesture( ACT_DOTA_TINKER_REARM1 )
			caster:StartGesture( ACT_DOTA_TINKER_REARM3 )
		end
	end )
end

function au_impostor_tinker_rearm:OnChannelFinish( i )
	local caster = self:GetCaster()

	caster:FadeGesture( ACT_DOTA_TINKER_REARM1 )
	caster:FadeGesture( ACT_DOTA_TINKER_REARM3 )

	if i then
		return
	end

	local ability = caster:FindAbilityByName( "au_impostor_kill" )

	if ability then
		ability:EndCooldown()
	end
end