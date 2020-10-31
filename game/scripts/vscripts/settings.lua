Settings = {}

function Settings:Activate()
	self.playerVotes = {}
	self.availableSettings = {
		custom = {
			{
				name = "impostor_info",
				priority = 1,
				options = {
					[0] = "#au_settings_yes",
					[1] = "#au_settings_no",
				}
			}
		}
	}
	self.settingVotes = {}
	self.votedSettings = {}

	for _, tn in pairs( { "custom" } ) do
		for _, setting in pairs( self.availableSettings[tn] ) do
			self.settingVotes[setting.name] = {}
			self.votedSettings[setting.name] = -1

			for i, _ in pairs( setting.options ) do
				self.settingVotes[setting.name][i] = 0
			end
		end
	end

	ListenToClient( "au_settings_vote", Debug:F( self.VoteOption ), self )

	CustomNetTables:SetTableValue( "settings", "available", self.availableSettings )
	CustomNetTables:SetTableValue( "settings", "votes", self.settingVotes )
	CustomNetTables:SetTableValue( "settings", "players", self.playerVotes )
	CustomNetTables:SetTableValue( "settings", "voted", self.votedSettings )
end

function Settings:Start()
	if GameMode.state == AU_GAME_STATE_SETTINGS then
		return
	end

	self.endTime = GameRules:GetGameTime() + 20

	for id, _ in pairs( GameMode.players ) do
		self.playerVotes[id] = {}
	end

	self:NetTableState()

	GameMode.state = AU_GAME_STATE_SETTINGS
	GameMode:NetTableState()
end

function Settings:NetTableState()
	CustomNetTables:SetTableValue( "settings", "state", {
		end_time = self.endTime
	} )
end

function Settings:Update( now )
	if GameMode.state ~= AU_GAME_STATE_SETTINGS then
		return
	end

	if now >= self.endTime then
		self:End()
	end
end

function Settings:VoteOption( data )
	if
		not self.votedSettings[data.name] or
		self.votedSettings[data.name] ~= -1 or
		not self.playerVotes[data.PlayerID] or
		not self.settingVotes[data.name] or
		self.playerVotes[data.PlayerID][data.name]
	then
		return
	end

	self.playerVotes[data.PlayerID][data.name] = data.option
	self.settingVotes[data.name][data.option] = self.settingVotes[data.name][data.option] + 1

	local d = math.floor( GameMode.playerCount / 2 )

	if data.name == "impostor_info" then
		if self.settingVotes.impostor_info[0] >= d + 1 then
			self:SetVoted( "impostor_info", 0 )
		elseif self.settingVotes.impostor_info[1] >= d then
			self:SetVoted( "impostor_info", 1 )
		end
	end

	CustomNetTables:SetTableValue( "settings", "votes", self.settingVotes )
	CustomNetTables:SetTableValue( "settings", "players", self.playerVotes )
end

function Settings:SetVoted( name, option )
	self.votedSettings[name] = option

	local skip = true

	for n, o in pairs( self.votedSettings ) do
		if o == -1 then
			skip = false

			break
		end
	end

	if false then
		self.endTime = math.min( GameRules:GetGameTime() + 3, self.endTime )
		self:NetTableState()
	end

	CustomNetTables:SetTableValue( "settings", "voted", self.votedSettings )
end

function Settings:End()
	if self.ended then
		return
	end

	self.ended = true

	GameMode.visibleImpostorCount = self.votedSettings.impostor_info == 0

	GameRules:ForceGameStart()
end