LinkLuaModifier( "modifier_au_impostor_kill", "abilities/impostor/kill/modifier_au_impostor_kill", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_pudge_eat", "abilities/impostor/pudge/modifier_au_impostor_pudge_eat", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_au_impostor_pudge_eat_delay", "abilities/impostor/pudge/modifier_au_impostor_pudge_eat_delay", LUA_MODIFIER_MOTION_NONE )

au_impostor_pudge_eat = {}

function au_impostor_pudge_eat:GetCastRange()
	return 270
end

function au_impostor_pudge_eat:GetIntrinsicModifierName()
	return "modifier_au_impostor_kill"
end

function au_impostor_pudge_eat:GetAbilityTextureName()
	if self:GetCaster():HasModifier( "modifier_au_impostor_pudge_eat_delay" ) then
		return "pudge_eject"
	else
		return "pudge_dismember"
	end
end

if IsClient() then
	return
end

function au_impostor_pudge_eat:OnSpellStart()
	if ( not self.target or not self.target.alive ) and not self.hero then
		return
	end

	Debug:Execute( function()
		if self.hero then
			self:Removing()
		elseif self.target then
			self.hero = self.target.hero

			local caster = self:GetCaster()
			local player = caster.player
			local pos = self.hero:GetAbsOrigin()
			local dir = caster:GetAbsOrigin() - pos
			local radius = dir:Length2D()
			local duration = {
				duration = self:GetSpecialValueFor( "duration" )
			}

			if dir == Vector() then
				dir = Vector( 1, 0, 0 )
			else
				dir = dir:Normalized()
			end

			caster:AddNewModifier( caster, self, "modifier_au_impostor_pudge_eat_delay", duration )
			self.hero:AddNewModifier( caster, self, "modifier_au_impostor_pudge_eat", duration )
		
			if radius > 75 then 
				caster:SetAbsOrigin(pos)
			else
				caster:SetAbsOrigin(pos)
				caster:SetForwardVector( dir )
			end
		end
	end )
end

function au_impostor_pudge_eat:Removing()
	local caster = self:GetCaster()

	caster:RemoveModifierByName( "modifier_au_impostor_pudge_eat_delay" )

	if self.hero then
		self.hero:RemoveModifierByName( "modifier_au_impostor_pudge_eat" )
	end
end