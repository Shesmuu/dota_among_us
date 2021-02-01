LinkLuaModifier( "modifier_au_impostor_invoker_exort", "abilities/impostor/invoker/modifier_au_impostor_invoker_spheres", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_invoker_quas", "abilities/impostor/invoker/modifier_au_impostor_invoker_spheres", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_invoker_wex", "abilities/impostor/invoker/modifier_au_impostor_invoker_spheres", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_invoker_quas_debuff", "abilities/impostor/invoker/modifier_au_impostor_invoker_spheres", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_invoker_quas_debuff_frozen", "abilities/impostor/invoker/modifier_au_impostor_invoker_spheres", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_invoker_wex_position", "abilities/impostor/invoker/modifier_au_impostor_invoker_spheres", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_invoker_exort_sun", "abilities/impostor/invoker/modifier_au_impostor_invoker_spheres", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_invoker_quas_check", "abilities/impostor/invoker/modifier_au_impostor_invoker_spheres", LUA_MODIFIER_MOTION_NONE )

au_impostor_invoker_spheres = {}

function au_impostor_invoker_spheres:GetAbilityTextureName()
	return "invoker_invoke"
end

function au_impostor_invoker_spheres:OnSpellStart()
	if self.modifier and self:GetCaster():HasModifier("modifier_au_impostor_invoker_quas") then
		self.modifier:Destroy()
		self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_invoker_exort", {} )
	    self:GetCaster():SwapAbilities( "au_impostor_invoker_quas", "au_impostor_invoker_exort", false, true )
	elseif self.modifier and self:GetCaster():HasModifier("modifier_au_impostor_invoker_exort") then
		self.modifier:Destroy()
		self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_invoker_wex", {} )
	    self:GetCaster():SwapAbilities( "au_impostor_invoker_exort", "au_impostor_invoker_wex", false, true )
	elseif self.modifier and self:GetCaster():HasModifier("modifier_au_impostor_invoker_wex") then
		self.modifier:Destroy()
		self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_invoker_quas", {} )
	    self:GetCaster():SwapAbilities( "au_impostor_invoker_wex", "au_impostor_invoker_quas", false, true )
	else
		self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_invoker_quas", {} )
	    self:GetCaster():SwapAbilities( "invoker_empty1", "au_impostor_invoker_quas", false, true )
	end
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

au_impostor_invoker_spheres_2 = {}

function au_impostor_invoker_spheres_2:GetAbilityTextureName()
	return "invoker_invoke"
end

function au_impostor_invoker_spheres_2:OnSpellStart()
	if self.modifier and self:GetCaster():HasModifier("modifier_au_impostor_invoker_quas") then
		self.modifier:Destroy()
		self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_invoker_exort", {} )
	    self:GetCaster():SwapAbilities( "au_impostor_invoker_quas", "au_impostor_invoker_exort", false, true )
	elseif self.modifier and self:GetCaster():HasModifier("modifier_au_impostor_invoker_exort") then
		self.modifier:Destroy()
		self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_invoker_wex", {} )
	    self:GetCaster():SwapAbilities( "au_impostor_invoker_exort", "au_impostor_invoker_wex", false, true )
	elseif self.modifier and self:GetCaster():HasModifier("modifier_au_impostor_invoker_wex") then
		self.modifier:Destroy()
		self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_invoker_quas", {} )
	    self:GetCaster():SwapAbilities( "au_impostor_invoker_wex", "au_impostor_invoker_quas", false, true )
	else
		self.modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_au_impostor_invoker_quas", {} )
	    self:GetCaster():SwapAbilities( "invoker_empty1", "au_impostor_invoker_quas", false, true )
	end
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

au_impostor_invoker_wex = {}

function au_impostor_invoker_wex:OnSpellStart()
	CreateModifierThinker(self:GetCaster(), self, "modifier_au_impostor_invoker_wex_position", {duration = self:GetSpecialValueFor("duration")}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
end

au_impostor_invoker_quas = {}

function au_impostor_invoker_quas:GetCastRange()
    return 800
end

if IsServer() then
	function au_impostor_invoker_quas:GetIntrinsicModifierName()
	    return "modifier_au_impostor_invoker_quas_check"
	end

	function au_impostor_invoker_quas:OnSpellStart()
		if self.target then
			self.target:AddNewModifier(self:GetCaster(), self, "modifier_au_impostor_invoker_quas_debuff", {duration = self:GetSpecialValueFor("delay")})
		end
	end
end

au_impostor_invoker_exort = {}

function au_impostor_invoker_exort:GetAOERadius()
	return 175
end

function au_impostor_invoker_exort:OnSpellStart()
	CreateModifierThinker( self:GetCaster(), self, "modifier_au_impostor_invoker_exort_sun", { duration = 1.7 }, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
	AddFOWViewer( self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), 400, 4, false )
end