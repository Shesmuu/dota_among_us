LinkLuaModifier( "modifier_au_impostor_ls_infest_check", "abilities/impostor/ls/modifier_au_impostor_ls_infest_check", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_au_impostor_ls_infest", "abilities/impostor/ls/au_impostor_ls_infest", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "modifier_au_impostor_ls_infest_effect", "abilities/impostor/ls/au_impostor_ls_infest", LUA_MODIFIER_MOTION_NONE  )

au_impostor_ls_infest = {}

function au_impostor_ls_infest:GetIntrinsicModifierName()
    return "modifier_au_impostor_ls_infest_check"
end

function au_impostor_ls_infest:GetCastRange()
    return 270
end

function au_impostor_ls_infest:OnSpellStart()
    if not self.target or not self.target.alive then
        return
    end
    local target = self.target.hero
    local duration = self:GetSpecialValueFor("duration")
    local infest_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf", PATTACH_POINT, target)
    ParticleManager:SetParticleControl(infest_particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(infest_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(infest_particle)
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_ls_infest", { target_ent = target:entindex(), duration = duration})
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_ls_infest_effect", { duration = duration})
end

modifier_au_impostor_ls_infest = {}

function modifier_au_impostor_ls_infest:IsPurgable() return false end

function modifier_au_impostor_ls_infest:OnCreated(params)
    if not IsServer() then return end
    self.target_ent = EntIndexToHScript(params.target_ent)
    self.target_team = self.target_ent.player.team
    self:GetParent():AddNoDraw()
    self.target_ent:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
    self.target_ent:SetTeam(self:GetCaster().player.team)
    self:StartIntervalThink(FrameTime())
end

function modifier_au_impostor_ls_infest:OnIntervalThink()
    if not IsServer() then return end
    if kickvoting_teleport_start == true then self:Destroy() return end
    self:GetCaster().player:SendEvent( "au_set_select_unit", { unit = self.target_ent:GetEntityIndex() } )
    self:GetParent():SetAbsOrigin(self.target_ent:GetAbsOrigin())
end

function modifier_au_impostor_ls_infest:OnDestroy()
    if not IsServer() then return end
    self:GetCaster().player:SendEvent( "au_set_select_unit", { unit = self:GetParent():GetEntityIndex() } )
    self.target_ent:RemoveModifierByName("modifier_au_impostor_ls_infest_effect")
    self.target_ent.player:Kill( true, self:GetCaster().player, false, true )
    local infest_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(infest_particle)
    self:GetParent():StartGesture(ACT_DOTA_LIFESTEALER_INFEST_END)
    FindClearSpaceForUnit(self:GetParent(), self.target_ent:GetAbsOrigin(), false)
    self:GetParent():RemoveNoDraw()
    self:GetAbility():StartCooldown( self:GetAbility():GetSpecialValueFor( "cooldown" ) )
end

function modifier_au_impostor_ls_infest:CheckState(keys)
    if not IsServer() then return end
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_SILENCED] = true,
    }
end

modifier_au_impostor_ls_infest_effect = {}