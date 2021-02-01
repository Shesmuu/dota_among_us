LinkLuaModifier( "modifier_au_impostor_qp_scream", "abilities/impostor/qp/modifier_au_impostor_qp_scream", LUA_MODIFIER_MOTION_NONE )

au_impostor_qp_scream = {}

if IsClient() then
	return
end

function au_impostor_qp_scream:OnSpellStart()
    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(), 
        nil,   
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        0, 
        0,  
        false 
    )
    for _,enemy in pairs(enemies) do
        if enemy:HasModifier("modifier_au_impostor_qp_knife") then
            if not enemy:HasModifier("modifier_au_impostor_qp_scream") then
                enemy:AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_qp_scream", {duration = 3.5} ) 
                self:StartCooldown(self:GetSpecialValueFor("cooldown"))
            end  
        end
    end
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
    ParticleManager:ReleaseParticleIndex( effect_cast )
end