_G.AU_MINIGAME_STONE = 0
_G.AU_MINIGAME_VOKER = 3
_G.AU_MINIGAME_FIREBALLS = 4
_G.AU_MINIGAME_X_MARK = 5
_G.AU_MINIGAME_BOTTLE_1 = 6
_G.AU_MINIGAME_BOTTLE_2 = 7
_G.AU_MINIGAME_BOTTLE_3 = 8
_G.AU_MINIGAME_BOTTLE_4 = 9
_G.AU_MINIGAME_METEORITES = 10
_G.AU_MINIGAME_MEEPO = 11
_G.AU_MINIGAME_SEARCH = 12
_G.AU_MINIGAME_FACELESS = 13
_G.AU_MINIGAME_WISP = 14
_G.AU_MINIGAME_SUNS = 15
_G.AU_MINIGAME_INTERFERENCE = 16
_G.AU_MINIGAME_ECLIPSE = 17
_G.AU_MINIGAME_OXYGEN = 18
_G.AU_MINIGAME_REACTOR = 19
_G.AU_MINIGAME_KICK_VOTING = 228

GlobalQuest = class( {} )

function GlobalQuest:constructor( name, t, sabotage, stepCount )
	self.name = name
	self.minigame = {
		type = t,
		result = function( data )
			self:MinigameResult( data )
		end
	}
	self.sabotage = sabotage
	self.effects = {}

	for _, unit in pairs( self.sabotage.units ) do
		local effect = ParticleManager:CreateParticle(
			"particles/sabotage_quest_unit/msg_deniable.vpcf",
			PATTACH_ABSORIGIN,
			unit
		)
		ParticleManager:SetParticleControl( effect, 0, unit:GetAbsOrigin() + Vector( 0, 0, -120 ) )

		self.effects[unit.questUnitIndex] = effect
	end

	if stepCount then
		self.stepCount = stepCount
		self.stepNow = 1
	end

	self.index = Add( Quests.globalQuests, self )

	Quests:NetTable()
end

function GlobalQuest:Trigger( unit, activator )
	activator:SetMinigame( self.minigame )
end

function GlobalQuest:MinigameResult( data )
	if data.completed == 1 then
		self:Destroy( true )
	elseif data.failure == 1 then
		GameMode.players[data.PlayerID]:SetMinigame()
	end
end

function GlobalQuest:Destroy( i )
	for i, player in pairs( GameMode.players ) do
		if player.minigame == self.minigame then
			player:SetMinigame()
		end
	end

	for _, effect in pairs( self.effects ) do
		ParticleManager:DestroyParticle( effect, false )
	end

	Quests.globalQuests[self.index] = nil

	self.sabotage:End( i )

	Quests:NetTable()
end

function GlobalQuest:GetNetTableData()
	local units = {}

	for i, unit in pairs( self.sabotage:GetUnits() or {} ) do
		units[i] = unit:GetEntityIndex()
	end

	return {
		units = units,
		name = self.name,
		type = self.type,
		sabotage = self.sabotage and self.sabotage:GetNetTableData() or nil,
		step_count = self.stepCount,
		progress = self.stepNow and self.stepNow - 1 or nil
	}
end

local questUnitList = {
	kick_voting = {
		event = function( _, player )
			player:SetMinigame( {
				type = AU_MINIGAME_KICK_VOTING,
				result = function( data )
					if data.completed == 1 then
						local now = GameRules:GetGameTime()

						if
							now >= GameMode.kickVotingCooldown and
							not Sabotage:IsActive() and
							player.kickVotingCount > 0
						then
							player.kickVotingCount = player.kickVotingCount - 1
							EmitGlobalSound( "Game.KickVotingButton" )
							GameMode:KickVoting( AU_NOTICE_TYPE_KICK_VOTING_CONVENE, player )
						end
					elseif data.failure == 1 then
						player:SetMinigame()
					end
				end
			} )
		end,
		color = { 105, 105, 105 },
		radius = 350,
		ghostDisable = true
	},
	stone = {},
	voker = {},
	bottle_1 = { questName = "bottle" },
	bottle_2 = { questName = "bottle" },
	bottle_3 = { questName = "bottle" },
	meepo = {},
	suns = {},
	meteorites_1 = { questName = "meteorites", radius = 400 },
	meteorites_2 = { questName = "meteorites" },
	cog = { dir = Vector( 1, 0, 0 ) },
	search = {},
	faceless = {},
	wisp = {},
	interference = { globalQuest = true, ghostDisable = true },
	eclipse = { globalQuest = true, ghostDisable = true },
	reactor = { globalQuest = true, ghostDisable = true },
	oxygen_1 = { globalQuest = true, questName = "oxygen", ghostDisable = true },
	oxygen_2 = { globalQuest = true, questName = "oxygen", color = { 139, 69, 19 }, ghostDisable = true }
}

local questList = {
	cog = { type = AU_MINIGAME_X_MARK, stepCount = 3 },
	meteorites = { type = AU_MINIGAME_FIREBALLS, stepCount = 2 },
	stone = { type = AU_MINIGAME_STONE, stepCount = 3 },
	voker = { type = AU_MINIGAME_VOKER, stepCount = 3 },
	bottle = QuestBottle,
	meepo = { type = AU_MINIGAME_MEEPO, stepCount = 2 },
	wisp = { type = AU_MINIGAME_WISP },
	search = { type = AU_MINIGAME_SEARCH },
	faceless = { type = AU_MINIGAME_FACELESS },
	suns = { type = AU_MINIGAME_SUNS }
}

Quests = {
	taskPointsToWin = 10,
	taskPoints = 0,
	questUnits = {},
	globalQuests = {},
	interferenced = false,
	alertEnabled = false
}

function Quests:Activate()
	for unitName, unitData in pairs( questUnitList ) do
		self:InitUnits( unitName, unitData )
	end

	self:NetTable()
end

function Quests:InitUnits( unitName, unitData )
	local ents = Entities:FindAllByName( "quest_" .. unitName )
	local questName = unitData.questName or unitName

	self.questUnits[questName] = self.questUnits[questName] or {}

	local radius
	local event

	if unitData.event then
		event = unitData.event
	elseif unitData.globalQuest then
		event = function( unit, activator )
			local quest = self:FindGlobalQuest( questName )

			if quest then
				quest:Trigger( unit, activator )
			end
		end
	else
		event = function( unit, activator )
			local quest = activator:FindQuest( questName )

			if quest then
				quest:Trigger( unit )
			end
		end
	end

	if unitData.radius then
		radius = unitData.radius
	end

	for i, ent in pairs( ents ) do
		local pos = ent:GetAbsOrigin()
		local dir = ent:GetForwardVector()
		local unit = CreateEventUnit( "npc_au_quest_" .. unitName, pos, event, radius )

		unit:SetAbsOrigin( pos )

		if unitData.dir then
			unit:SetForwardVector( unitData.dir )
		else
			unit:SetForwardVector( dir )
		end

		if unitData.modifier then
			if unitData.modifierDelay then
				Delay( unitData.modifierDelay, function()
					unit:AddNewModifier( unit, nil, unitData.modifier, nil )
				end )
			else
				unit:AddNewModifier( unit, nil, unitData.modifier, nil )
			end
		end

		if unitData.color then
			unit:SetRenderColor( unpack( unitData.color ) )
		end

		if unitData.gesture then
			unit.gameInProgressGesture = unitData.gesture
		end

		if not unitData.ghostDisable then
			unit.ghostActive = true
		end

		unit:AddNewModifier( unit, nil, "modifier_au_quest_unit", nil )

		table.insert( self.questUnits[questName], unit )

		ent:Destroy()
	end
end

function Quests:RandomQuests( player )
	if IsTest() then
		for questName, questData in pairs( questList ) do
			local quest

			if isclass( questData ) then
				quest = questData( player, questName, self:GetUnits( questName ) )
			else
				quest = Quest( player, questName, questData, self:GetUnits( questName ) )
			end

			if player.role == AU_ROLE_IMPOSTOR then
				quest.Trigger = function() end
			end
		end

		return
	end

	local quests1 = {
		"voker",
		"stone",
		"bottle"
	}
	local quests2 = {
		"meepo",
		"meteorites"
	}
	local quests3 = {
		"suns",
		"faceless",
		"search",
		"wisp",
		"cog"
	}

	local quests = {
		quests1[RandomInt( 1, #quests1 )],
		quests2[RandomInt( 1, #quests2 )],
		--quests3[RandomInt( 1, #quests3 )]
	}

	for i = 1, 2 do
		local r = RandomInt( 1, #quests3 )

		table.insert( quests, quests3[r] )
		table.remove( quests3, r )
	end

	for _, questName in pairs( quests ) do
		local questData = questList[questName]
		local quest

		if isclass( questData ) then
			quest = questData( player, questName, self:GetUnits( questName ) )
		else
			quest = Quest( player, questName, questData, self:GetUnits( questName ) )
		end

		if player.role == AU_ROLE_IMPOSTOR then
			quest.Trigger = function() end
		end
	end
end

function Quests:GetUnits( name )
	return self.questUnits[name]
end

function Quests:StartMinigame( player )
	if player.minigame then
		player.minigame.failure()
	end

	player.minigame.failure()
end

function Quests:AddTaskPoints( count )
	self.taskPoints = self.taskPoints + count

	if self.taskPointsToWin <= self.taskPoints then
		GameMode:SetWinner( AU_ROLE_PEACE, AU_WIN_REASON_TASKS_COMPLETED )
	end

	self:NetTable()
end

function Quests:FindGlobalQuest( name )
	for _, quest in pairs( self.globalQuests ) do
		if quest.name == name then
			return quest
		end
	end
end

function Quests:GameInProgress()
	for questName, t in pairs( self.questUnits ) do
		for _, unit in pairs( t ) do
			if unit.gameInProgressGesture then
				unit:StartGesture( unit.gameInProgressGesture )
			end
		end
	end

	local taskPointsToWin = 0

	for _, player in pairs( GameMode.players ) do
		if player.role == AU_ROLE_PEACE and player.hero then
			taskPointsToWin = taskPointsToWin + 4
		end
	end

	if taskPointsToWin == 0 then
		taskPointsToWin = 10
	end

	self.taskPointsToWin = taskPointsToWin

	self:NetTable()
end

function Quests:NetTable()
	local t = {
		quests = {},
		points_to_win = self.taskPointsToWin,
		points = self.taskPoints,
		interferenced = self.interferenced,
		alert = self.alertEnabled
	}

	for i, quest in pairs( self.globalQuests ) do
		t.quests[i] = quest:GetNetTableData()
	end

	CustomNetTables:SetTableValue( "game", "quests", t )
end