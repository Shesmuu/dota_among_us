LinkLuaModifier( "modifier_au_tiny_toss", "abilities/impostor/tiny/au_impostor_tiny_toss", LUA_MODIFIER_MOTION_HORIZONTAL  )
LinkLuaModifier( "modifier_generic_arc_lua", "abilities/impostor/tiny/au_impostor_tiny_toss", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_au_impostor_kill", "abilities/impostor/tiny/modifier_au_impostor_kill", LUA_MODIFIER_MOTION_NONE )

au_impostor_tiny_toss = {}

function au_impostor_tiny_toss:GetIntrinsicModifierName()
    return "modifier_au_impostor_kill"
end

function au_impostor_tiny_toss:OnAbilityPhaseStart()
    self.vTargetPosition = self:GetCursorPosition()
    if not GridNav:IsTraversable( self.vTargetPosition ) then
        return false
    end
    if not self.target or not self.target.alive then
        return false
    end
    return true
end

function au_impostor_tiny_toss:OnSpellStart()
    if not self.target or not self.target.alive then
        return
    end
    self.point = self:GetCursorPosition()
    local target = self.target.hero
    target:AddNewModifier( self:GetCaster(), self, "modifier_au_tiny_toss", {} )
    target.player:SetMinigame()
end

modifier_au_tiny_toss = class({})

function modifier_au_tiny_toss:IsHidden()
    return true
end

function modifier_au_tiny_toss:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    if not IsServer() then return end
    local duration = self:GetAbility():GetSpecialValueFor( "duration" )
    self.point = self:GetAbility().point

    self.modifier = self.parent:AddNewModifier(
        self.caster,
        self:GetAbility(),
        "modifier_generic_arc_lua",
        {
            duration = duration,
            distance = 0,
            height = 850,
            fix_duration = false,
            isStun = true,
            activity = ACT_DOTA_FLAIL,
        }
    )

    self.modifier:SetEndCallback(function( interrupted )
        self:Destroy()
        if interrupted then return end
        GridNav:DestroyTreesAroundPoint( self.parent:GetOrigin(), 270, false )
        self.parent.player:Kill( true, self.caster.player, false, true )
    end)

    local origin = self.point
    local direction = origin-self.parent:GetOrigin()
    local distance = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    self.distance = distance
    if self.distance==0 then self.distance = 1 end
    self.duration = duration
    self.speed = distance/duration
    self.accel = 100
    self.max_speed = 3000
    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
    end
end

function modifier_au_tiny_toss:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_au_tiny_toss:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

function modifier_au_tiny_toss:UpdateHorizontalMotion( me, dt )
    local target = self.point
    local parent = self.parent:GetOrigin()
    local duration = self:GetElapsedTime()
    local direction = target-parent
    local distance = direction:Length2D()
    direction.z = 0
    direction = direction:Normalized()
    local original_distance = duration/self.duration * self.distance
    local expected_speed
    if self:GetElapsedTime()>=self.duration then
        expected_speed = self.speed
    else
        expected_speed = distance/(self.duration-self:GetElapsedTime())
    end
    if self.speed<expected_speed then
        self.speed = math.min(self.speed + self.accel, self.max_speed)
    elseif self.speed>expected_speed then
        self.speed = math.max(self.speed - self.accel, 0)
    end
    local pos = parent + direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_au_tiny_toss:OnHorizontalMotionInterrupted()
    self:Destroy()
end

function modifier_au_tiny_toss:GetEffectName()
    return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_au_tiny_toss:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end



modifier_generic_arc_lua = class({})

function modifier_generic_arc_lua:IsHidden()
    return true
end

function modifier_generic_arc_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_generic_arc_lua:OnCreated( kv )
    if not IsServer() then return end
    self.interrupted = false
    self:SetJumpParameters( kv )
    self:Jump()
end

function modifier_generic_arc_lua:OnRefresh( kv )
    self:OnCreated( kv )
end

function modifier_generic_arc_lua:OnDestroy()
    if not IsServer() then return end
    local pos = self:GetParent():GetOrigin()
    self:GetParent():RemoveHorizontalMotionController( self )
    self:GetParent():RemoveVerticalMotionController( self )
    if self.end_offset~=0 then
        self:GetParent():SetOrigin( pos )
    end
    if self.endCallback then
        self.endCallback( self.interrupted )
    end
end

function modifier_generic_arc_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_TURNING,
    }
    if self:GetStackCount()>0 then
        table.insert( funcs, MODIFIER_PROPERTY_OVERRIDE_ANIMATION )
    end

    return funcs
end

function modifier_generic_arc_lua:GetModifierDisableTurning()
    if not self.isForward then return end
    return 1
end

function modifier_generic_arc_lua:GetOverrideAnimation()
    return self:GetStackCount()
end

function modifier_generic_arc_lua:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = self.isStun or false,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = self.isRestricted or false,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end

function modifier_generic_arc_lua:UpdateHorizontalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
    local pos = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( pos )
end

function modifier_generic_arc_lua:UpdateVerticalMotion( me, dt )
    if self.fix_duration and self:GetElapsedTime()>=self.duration then return end
    local pos = me:GetOrigin()
    local time = self:GetElapsedTime()
    local height = pos.z
    local speed = self:GetVerticalSpeed( time )
    pos.z = height + speed * dt
    me:SetOrigin( pos )

    if not self.fix_duration then
        local ground = GetGroundHeight( pos, me ) + self.end_offset
        if pos.z <= ground then
            pos.z = ground
            me:SetOrigin( pos )
            self:Destroy()
        end
    end
end

function modifier_generic_arc_lua:OnHorizontalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_generic_arc_lua:OnVerticalMotionInterrupted()
    self.interrupted = true
    self:Destroy()
end

function modifier_generic_arc_lua:SetJumpParameters( kv )
    self.parent = self:GetParent()
    self.fix_end = true
    self.fix_duration = true
    self.fix_height = true
    if kv.fix_end then
        self.fix_end = kv.fix_end==1
    end
    if kv.fix_duration then
        self.fix_duration = kv.fix_duration==1
    end
    if kv.fix_height then
        self.fix_height = kv.fix_height==1
    end

    self.isStun = kv.isStun==1
    self.isRestricted = kv.isRestricted==1
    self.isForward = kv.isForward==1
    self.activity = kv.activity or 0
    self:SetStackCount( self.activity )

    if kv.target_x and kv.target_y then
        local origin = self.parent:GetOrigin()
        local dir = Vector( kv.target_x, kv.target_y, 0 ) - origin
        dir.z = 0
        dir = dir:Normalized()
        self.direction = dir
    end
    if kv.dir_x and kv.dir_y then
        self.direction = Vector( kv.dir_x, kv.dir_y, 0 ):Normalized()
    end
    if not self.direction then
        self.direction = self.parent:GetForwardVector()
    end

    self.duration = kv.duration
    self.distance = kv.distance
    self.speed = kv.speed
    if not self.duration then
        self.duration = self.distance/self.speed
    end
    if not self.distance then
        self.speed = self.speed or 0
        self.distance = self.speed*self.duration
    end
    if not self.speed then
        self.distance = self.distance or 0
        self.speed = self.distance/self.duration
    end

    -- load vertical data
    self.height = kv.height or 0
    self.start_offset = kv.start_offset or 0
    self.end_offset = kv.end_offset or 0

    local pos_start = self.parent:GetOrigin()
    local pos_end = pos_start + self.direction * self.distance
    local height_start = GetGroundHeight( pos_start, self.parent ) + self.start_offset
    local height_end = GetGroundHeight( pos_end, self.parent ) + self.end_offset
    local height_max

    if not self.fix_height then
        self.height = math.min( self.height, self.distance/4 )
    end

    if self.fix_end then
        height_end = height_start
        height_max = height_start + self.height
    else
        local tempmin, tempmax = height_start, height_end
        if tempmin>tempmax then
            tempmin,tempmax = tempmax, tempmin
        end
        local delta = (tempmax-tempmin)*2/3

        height_max = tempmin + delta + self.height
    end

    if not self.fix_duration then
        self:SetDuration( -1, false )
    else
        self:SetDuration( self.duration, true )
    end

    self:InitVerticalArc( height_start, height_max, height_end, self.duration )
end

function modifier_generic_arc_lua:Jump()
    if self.distance>0 then
        if not self:ApplyHorizontalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end

    if self.height>0 then
        if not self:ApplyVerticalMotionController() then
            self.interrupted = true
            self:Destroy()
        end
    end
end

function modifier_generic_arc_lua:InitVerticalArc( height_start, height_max, height_end, duration )
    local height_end = height_end - height_start
    local height_max = height_max - height_start

    if height_max<height_end then
        height_max = height_end+0.01
    end

    if height_max<=0 then
        height_max = 0.01
    end

    local duration_end = ( 1 + math.sqrt( 1 - height_end/height_max ) )/2
    self.const1 = 4*height_max*duration_end/duration
    self.const2 = 4*height_max*duration_end*duration_end/(duration*duration)
end

function modifier_generic_arc_lua:GetVerticalPos( time )
    return self.const1*time - self.const2*time*time
end

function modifier_generic_arc_lua:GetVerticalSpeed( time )
    return self.const1 - 2*self.const2*time
end

function modifier_generic_arc_lua:SetEndCallback( func )
    self.endCallback = func
end