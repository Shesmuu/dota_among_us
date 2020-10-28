LinkLuaModifier( "modifier_au_impostor_ember_remnant", "abilities/impostor/ember/modifier_au_impostor_ember_remnant", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_ember_remnant_caster", "abilities/impostor/ember/modifier_au_impostor_ember_remnant_caster", LUA_MODIFIER_MOTION_NONE )

au_impostor_ember_remnant = {}

function au_impostor_ember_remnant:GetAbilityTextureName()
	if self:GetCaster():HasModifier( "modifier_au_impostor_ember_remnant_caster" ) then
		return "ember_spirit_activate_fire_remnant"
	else
		return "ember_spirit_fire_remnant"
	end
end

if IsClient() then
	return
end

function au_impostor_ember_remnant:OnSpellStart()
	Debug:Execute( function()
		local caster = self:GetCaster()
		local player = caster.player

		if caster:HasModifier( "modifier_au_impostor_ember_remnant_caster" ) then
			caster:Stop()
			caster:SetAbsOrigin( self.unit:GetAbsOrigin() )
			caster:SetForwardVector( self.unit:GetForwardVector() )
			caster:RemoveModifierByName( "modifier_au_impostor_ember_remnant_caster" )

			self:StartCooldown( self:GetSpecialValueFor( "cooldown" ) )

			if not self.unit then
				return
			end

			self.unit:RemoveModifierByName( "modifier_au_impostor_ember_remnant" )
		elseif self.unit then
			self:Removing()
		else
			local duration = {
				duration = self:GetSpecialValueFor( "duration" )
			}

			caster:AddNewModifier( caster, self, "modifier_au_impostor_ember_remnant_caster", duration )

			self.unit = CreateUnitByName( "npc_au_ember_remnant", caster:GetAbsOrigin(), true, nil, nil, player.team )
			self.unit:AddNewModifier( caster, self, "modifier_au_impostor_ember_remnant", duration )
			self.unit:SetForwardVector( caster:GetForwardVector() )
		end
	end )
end

function au_impostor_ember_remnant:Removing()
	self:GetCaster():RemoveModifierByName( "modifier_au_impostor_ember_remnant_caster" )

	if self.unit then
		self.unit:RemoveModifierByName( "modifier_au_impostor_ember_remnant" )
	end
end