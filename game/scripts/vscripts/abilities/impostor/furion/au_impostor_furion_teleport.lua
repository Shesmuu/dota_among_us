LinkLuaModifier( "modifier_au_impostor_furion_teleport", "abilities/impostor/furion/modifier_au_impostor_furion_teleport", LUA_MODIFIER_MOTION_NONE )

au_impostor_furion_teleport = class({})

function au_impostor_furion_teleport:OnAbilityPhaseStart()
	self.vTargetPosition = self:GetCursorPosition()
	if not GridNav:IsTraversable( self.vTargetPosition ) then
		return false
	end
	local nTeam = self:GetCaster():GetTeamNumber()
	self.nFXIndexStart = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_furion/furion_teleport.vpcf", PATTACH_CUSTOMORIGIN, nil, nTeam )
	ParticleManager:SetParticleControl( self.nFXIndexStart, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControl( self.nFXIndexStart, 2, Vector( 1, 0, 0 ) )
	self.nFXIndexEnd = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_furion/furion_teleport_end.vpcf", PATTACH_CUSTOMORIGIN, nil, nTeam )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 1, self.vTargetPosition )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 2, Vector ( 1, 0, 0 ) )
	self.nFXIndexEndTeam = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_furion/furion_teleport_end_team.vpcf", PATTACH_CUSTOMORIGIN, nil, nTeam )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 1, self.vTargetPosition )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 2, Vector ( 1, 0, 0 ) )

	MinimapEvent( nTeam, self:GetCaster(), self.vTargetPosition.x, self.vTargetPosition.y, DOTA_MINIMAP_EVENT_TEAMMATE_TELEPORTING, self:GetCastPoint() )

	local kv = {
		duration = self:GetCastPoint(),
		target_x = self.vTargetPosition.x,
		target_y = self.vTargetPosition.y,
		target_z = self.vTargetPosition.z
	}

	self.modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_furion_teleport", {})
	return true;
end

function au_impostor_furion_teleport:OnAbilityPhaseInterrupted()
	ParticleManager:SetParticleControl( self.nFXIndexStart, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nFXIndexEnd, 2, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( self.nFXIndexEndTeam, 2, Vector( 0, 0, 0 ) )
	ParticleManager:DestroyParticle( self.nFXIndexStart, false )
	ParticleManager:DestroyParticle( self.nFXIndexEnd, false )
	ParticleManager:DestroyParticle( self.nFXIndexEndTeam, false )
	MinimapEvent( self:GetCaster():GetTeamNumber(), self:GetCaster(), 0, 0, DOTA_MINIMAP_EVENT_CANCEL_TELEPORTING, 0 )
	self:UseResources(true, false, true)
	if self.modifier then
		self.modifier:Destroy()
	end
end

function au_impostor_furion_teleport:OnSpellStart()
	FindClearSpaceForUnit( self:GetCaster(), self.vTargetPosition, true )
	self:GetCaster():SetClearSpaceOrigin( self.vTargetPosition )
	self:GetCaster():StartGesture( ACT_DOTA_TELEPORT_END )
	ParticleManager:DestroyParticle( self.nFXIndexStart, false )
	ParticleManager:DestroyParticle( self.nFXIndexEnd, false )
	ParticleManager:DestroyParticle( self.nFXIndexEndTeam, false )
	if self.modifier then
		self.modifier:Destroy()
	end
end