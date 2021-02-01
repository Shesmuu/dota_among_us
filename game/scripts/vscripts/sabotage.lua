_G.AU_SABOTAGE_ECLIPSE = 0
_G.AU_SABOTAGE_INTERFERENCE = 1
_G.AU_SABOTAGE_REACTOR = 2
_G.AU_SABOTAGE_OXYGEN = 3

BaseSabotage = class( {} )

function BaseSabotage:constructor( t, questName, duration, alert )
	self.type = t
	self.duration = duration
	self.started = false
	self.units = Quests:GetUnits( questName )
	self.alertEnabled = alert

	if not self.units then
		print( "Not units of " .. questName )

		return
	end

	for i, unit in pairs( self.units ) do
		unit.questUnitIndex = i
	end
end

function BaseSabotage:Start(caster)
	if self.started then
		return
	end

	self.creator = caster

	Quests.alertEnabled = self.alertEnabled

	for _, player in pairs( GameMode.players ) do
		player:Sabotage( true, 30 )
	end

	if self.duration then
		self.endTime = GameRules:GetGameTime() + self.duration
	end

	self.started = true

	if self.OnStart then
		self:OnStart()
	end

	GameMode:NetTableState()
end

function BaseSabotage:End( interrupted )
	if not self.started then
		return
	end

	Quests.alertEnabled = false

	for _, player in pairs( GameMode.players ) do
		if self.creator == player then
			player:Sabotage( false, 30 )
		elseif self.creator == nil then
			player:Sabotage( false, 30 )
		else
			player:Sabotage( false, 25 )
		end
	end

	self.creator = nil

	if self.duration and not interrupted then
		if not interrupted then
			GameMode:SetWinner( AU_ROLE_IMPOSTOR, AU_WIN_REASON_SABOTAGE )
		end
	end

	self.started = false

	if self.OnEnd then
		self:OnEnd()
	end

	GameMode:NetTableState()
end

function BaseSabotage:Stop()
	if not self.started or self.stoped then
		return
	end

	Quests.alertEnabled = false

	self.stoped = true

	if self.duration and self.endTime then
		local now = GameRules:GetGameTime()

		if now >= self.endTime then
			GameMode:SetWinner( AU_ROLE_IMPOSTOR, AU_WIN_REASON_SABOTAGE )
		else
			self.remainingTimeSaved = self.endTime - now
		end
	end

	if self.OnStop then
		self:OnStop()
	end
end

function BaseSabotage:Return()
	if not self.stoped then
		return
	end

	Quests.alertEnabled = self.alertEnabled

	self.stoped = false

	if self.duration then
		self.endTime = GameRules:GetGameTime() + self.remainingTimeSaved
	end

	if self.OnReturn then
		self:OnReturn()
	end
end

function BaseSabotage:GetNetTableData()
	return {
		duration = self.duration,
		stoped = self.stoped,
		end_time = self.endTime,
		remaining = self.remainingTimeSaved
	}
end

function BaseSabotage:GetUnits()
	return self.units
end

function BaseSabotage:Update( now )
	if not self.started or self.stoped then
		return
	end

	if self.duration and now >= self.endTime and GameMode.state == AU_GAME_STATE_PROCESS then
		self:End( false )
	end
end

Sabotage = {
	sabotages = {}
}

function Sabotage:Activate( value )
	self.sabotages[AU_SABOTAGE_ECLIPSE] = SabotageEclipse( AU_SABOTAGE_ECLIPSE, "eclipse" )
	self.sabotages[AU_SABOTAGE_INTERFERENCE] = SabotageInterference( AU_SABOTAGE_INTERFERENCE, "interference" )
	self.sabotages[AU_SABOTAGE_OXYGEN] = SabotageOxygen( AU_SABOTAGE_OXYGEN, "oxygen", 53, true )
	self.sabotages[AU_SABOTAGE_REACTOR] = SabotageReactor( AU_SABOTAGE_REACTOR, "reactor", 53, true )
end

function Sabotage:IsActive()
	for _, sabotage in pairs( self.sabotages ) do
		if sabotage.started then
			return true
		end
	end

	return false
end

function Sabotage:CameraCheck()
	if Quests.interferenced or Quests.eclipse then
		return true
	end

	return false
end

function Sabotage:GetSabotage( s )
	return self.sabotages[s]
end

function Sabotage:Update( now )
	for _, sabotage in pairs( self.sabotages ) do
		sabotage:Update( now )
	end
end

function Sabotage:Abilities( unit )
	unit:Ability( "au_impostor_sabotage_oxygen", 2, 20 )
	unit:Ability( "au_impostor_sabotage_reactor", 3, 20 )
	unit:Ability( "au_impostor_sabotage_eclipse", 4, 20 )
	unit:Ability( "au_impostor_sabotage_interference", 5, 20 )
end

function Sabotage:AbilitiesRubick( unit )
	unit:Ability( "au_impostor_sabotage_oxygen", 2, 0 )
	unit:Ability( "au_impostor_sabotage_reactor", 3, 0 )
	unit:Ability( "au_impostor_sabotage_eclipse", 4, 0 )
	unit:Ability( "au_impostor_sabotage_interference", 5, 0 )
	if Sabotage:IsActive() then
		for _, player in pairs( GameMode.players ) do
			player:Sabotage( true )
		end
	end
end