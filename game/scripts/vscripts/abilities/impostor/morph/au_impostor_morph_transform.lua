LinkLuaModifier( "modifier_au_impostor_morph_caster", "abilities/impostor/morph/modifier_au_impostor_morph_caster", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_morph_target", "abilities/impostor/morph/modifier_au_impostor_morph_target", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_au_impostor_morph_duration", "abilities/impostor/morph/modifier_au_impostor_morph_duration", LUA_MODIFIER_MOTION_NONE )

au_impostor_morph_transform = {}

if IsClient() then
	return
end

function au_impostor_morph_transform:OnSpellStart()
	Debug:Execute( function()
		self:SpellStart()
	end )
end

function au_impostor_morph_transform:SpellStart()
	local caster = self:GetCaster()
	local playerID = caster.player.id
	local player = PlayerResource:GetPlayer( playerID )

	if caster:HasModifier( "modifier_au_impostor_morph_duration" ) then
		if caster:HasModifier( "modifier_au_impostor_morph_caster" ) then
			self:DestroyIllusion()
		else
			self:CreateIllusion()
		end
	else
		if player then
			local heroes = {}

			for id, p in pairs( GameMode.players ) do
				if p.alive and id ~= playerID then
					heroes[id] = PlayerResource:GetSelectedHeroName( id )
				end
			end

			CustomGameEventManager:Send_ServerToPlayer( player, "au_morph_transform_start", heroes )
		end
	end
end

function au_impostor_morph_transform:Transform( id )
	local caster = self:GetCaster()
	local player = caster.player

	if caster:HasModifier( "modifier_au_impostor_morph_duration" ) then
		return
	end

	if not id or id == player.id then
		return
	end

	local p = GameMode.players[id]

	if not p or not p.alive or not p.hero then
		return
	end

	caster:AddNewModifier( caster, self, "modifier_au_impostor_morph_duration", {
		duration = self:GetSpecialValueFor( "duration" )
	} )

	self.hero = p.hero

	self:CreateIllusion()
end

function au_impostor_morph_transform:CreateIllusion()
	local caster = self:GetCaster()
	local player = caster.player
	local p = GameMode.players[id]

	caster:AddNoDraw()
	caster:AddNewModifier( caster, self, "modifier_au_impostor_morph_caster", nil )
	self.hero:AddNewModifier( caster, self, "modifier_au_impostor_morph_target", {
		duration = self:GetSpecialValueFor( "duration" )
	} )

	self.illusion = CreateUnitByName(
		self.hero:GetUnitName(),
		caster:GetAbsOrigin(),
		true,
		self.hero,
		self.hero,
		player.team
	)
	self.illusion:SetForwardVector( caster:GetForwardVector() )
	self.illusion:AddNewModifier( caster, self, "modifier_au_unselectable", nil )
	self.illusion:HeroSettings()

	GameMode:CreateImpostorEffects( self.illusion, true )
end

function au_impostor_morph_transform:DestroyIllusion()
	if self.illusion then
		self.illusion:Destroy()
		self.illusion = nil
	end

	local caster = self:GetCaster()

	caster:RemoveNoDraw()
	caster:RemoveModifierByName( "modifier_au_impostor_morph_caster" )
	self.hero:RemoveModifierByName( "modifier_au_impostor_morph_target" )
end

function au_impostor_morph_transform:Removing()
	self:GetCaster():RemoveModifierByName( "modifier_au_impostor_morph_duration" )
	if self.hero then
		self.hero:RemoveModifierByName( "modifier_au_impostor_morph_target" )
	end
end