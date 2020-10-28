function CDOTA_BaseNPC:RemoveAbilities()
	for i = 31, 0, -1 do
		local ability = self:GetAbilityByIndex( i )

		if ability then
			ability:Removing()
			ability:SetHidden( true )
		end
	end
end

function CDOTA_BaseNPC:SetClearSpaceOrigin( v )
	self:SetAbsOrigin( v )

	FindClearSpaceForUnit( self, v, true )
end

function CDOTA_BaseNPC:HeroSettings( nightVision, dayVision )
	self:SetDayTimeVisionRange( dayVision or 2000 )
	self:SetNightTimeVisionRange( nightVision or 2000 )
	self:SetBaseMoveSpeed( 550 )
end

function CDOTA_BaseNPC:Ability( name, index, cooldown )
	local ability = self:FindAbilityByName( name )

	if ability then
		ability:SetHidden( false )
		ability:SetActivated( true )
	else
		ability = self:AddAbility( name )
		ability:SetLevel( 1 )
	end

	if cooldown then
		ability:StartCooldown( cooldown )
	end

	if index then
		local swapAbility = self:GetAbilityByIndex( index )

		if swapAbility and swapAbility ~= ability then
			self:SwapAbilities(
				swapAbility:GetAbilityName(),
				ability:GetAbilityName(),
				false,
				true
			)
		end
	end

	return ability
end