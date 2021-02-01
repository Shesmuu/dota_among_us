modifier_au_camera = {}

function modifier_au_camera:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_au_camera:IsHidden()
	return true
end

function modifier_au_camera:OnCreated(kv)
	if not IsServer() then return end
	self.team = kv.team
	self.id = kv.id
	self:GetParent():SetMaterialGroup("0")
	self:StartIntervalThink(FrameTime())
end

function modifier_au_camera:OnDestroy(kv)
	if not IsServer() then return end
end

function modifier_au_camera:OnIntervalThink()
	if not IsServer() then return end
	if GameRules:IsDaytime() then
		AddFOWViewer(self.team, self:GetParent():GetAbsOrigin(), 1000, FrameTime(), false)
	else
		AddFOWViewer(self.team, self:GetParent():GetAbsOrigin(), 700, FrameTime(), false)
	end
	self:GetParent():SetMaterialGroup("0")
end