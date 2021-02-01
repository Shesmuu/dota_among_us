LinkLuaModifier( "modifier_au_impostor_qp_knife", "abilities/impostor/qp/modifier_au_impostor_qp_knife", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_qp_knife_check", "abilities/impostor/qp/modifier_au_impostor_qp_knife_check", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_qp_scream_status", "abilities/impostor/qp/modifier_au_impostor_qp_scream_status", LUA_MODIFIER_MOTION_NONE )

au_impostor_qp_knife = {}

if IsClient() then
	return
end

function au_impostor_qp_knife:GetCastRange()
    return 270
end

function au_impostor_qp_knife:GetIntrinsicModifierName()
    return "modifier_au_impostor_qp_knife_check"
end

function au_impostor_qp_knife:OnSpellStart()
    if self.target then
        self.target:AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_qp_knife", {} )  
        local effect = ParticleManager:CreateParticleForPlayer( "particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf", PATTACH_ABSORIGIN, self:GetCaster(), PlayerResource:GetPlayer( self:GetCaster():GetPlayerOwnerID() ) )
        ParticleManager:SetParticleControl( effect, 0, self.target:GetAbsOrigin() )
        ParticleManager:SetParticleControlForward( effect, 0, self.target:GetAbsOrigin():Normalized() )
        ParticleManager:SetParticleControl( effect, 1, self.target:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex( effect )
        self:GetCaster():FindAbilityByName("au_impostor_qp_scream"):SetActivated(true)
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_qp_scream_status", {} ) 
    end
end

