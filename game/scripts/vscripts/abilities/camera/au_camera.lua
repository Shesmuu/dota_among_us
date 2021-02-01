LinkLuaModifier( "modifier_camera_passive", "abilities/camera/au_camera", LUA_MODIFIER_MOTION_NONE )

au_camera = {}

if IsClient() then
	return
end

function au_camera:GetIntrinsicModifierName()
    return "modifier_camera_passive"
end

modifier_camera_passive = class({})

function modifier_camera_passive:IsHidden()
    return true
end

function modifier_camera_passive:OnCreated()
    self:StartIntervalThink(FrameTime())
end

function modifier_camera_passive:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_au_camera") then return end
    self:GetParent():SetMaterialGroup("1")
end