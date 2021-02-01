au_impostor_am_blink = {}

if IsClient() then
	return
end

function au_impostor_am_blink:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    if not GridNav:IsTraversable( self.vTargetPosition ) and self:GetCaster():IsRooted() then
        return false
    end
    if self:GetCaster().player.role ~= AU_ROLE_IMPOSTOR and Sabotage:IsActive() then
        return false
    end
    return true;
end

function au_impostor_am_blink:GetManaCost(level)
	if self:GetCaster().player.role == AU_ROLE_IMPOSTOR then
		return 0
	end
    return self.BaseClass.GetManaCost(self, level)
end

function au_impostor_am_blink:OnSpellStart()
    if not IsServer() then return end
    local point = self:GetCursorPosition()
    local origin = self:GetCaster():GetOrigin()
    local range = self:GetSpecialValueFor("radius")
    local direction = (point - origin)
    if direction:Length2D() > range then
        direction = direction:Normalized() * range
    end
    self:PlayEffects2( origin, direction )
    FindClearSpaceForUnit( self:GetCaster(), origin + direction, true )
    ProjectileManager:ProjectileDodge(self:GetCaster())
    self:PlayEffects( origin, direction )
end

function au_impostor_am_blink:PlayEffects( origin, direction )
    local particle_two = ParticleManager:CreateParticle( "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_two, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControlForward( particle_two, 0, direction:Normalized() )
    ParticleManager:ReleaseParticleIndex( particle_two )
    self:GetCaster():EmitSound( "Hero_Antimage.Blink_out" )
end

function au_impostor_am_blink:PlayEffects2( origin, direction )
    local particle_one = ParticleManager:CreateParticle( "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( particle_one, 0, origin )
    ParticleManager:SetParticleControlForward( particle_one, 0, direction:Normalized() )
    ParticleManager:SetParticleControl( particle_one, 1, origin + direction )
    ParticleManager:ReleaseParticleIndex( particle_one )
    self:GetCaster():EmitSound( "Hero_Antimage.Blink_in" )
end