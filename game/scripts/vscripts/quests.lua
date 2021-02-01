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
_G.AU_MINIGAME_OSU = 16
_G.AU_MINIGAME_MORTRED = 17
_G.AU_MINIGAME_COLLECT = 18
_G.AU_MINIGAME_ALCHEMIST = 19
_G.AU_MINIGAME_BATRIDER = 20
_G.AU_MINIGAME_INTERFERENCE = 101
_G.AU_MINIGAME_ECLIPSE = 102
_G.AU_MINIGAME_OXYGEN = 103
_G.AU_MINIGAME_REACTOR = 104
_G.AU_MINIGAME_KICK_VOTING = 228
_G.AU_MINIGAME_CAMERA = 105
_G.AU_MINIGAME_CAMERA_WARD_1 = 106
_G.AU_MINIGAME_CAMERA_WARD_2 = 107
_G.AU_MINIGAME_CAMERA_WARD_3 = 108
_G.AU_MINIGAME_CAMERA_WARD_4 = 109


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

	if GameMode.visibleTaks then
		Quests:NetTable(false)
	else
		Quests:NetTable(true)
	end
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

	if GameMode.visibleTaks then
		Quests:NetTable(false)
	else
		Quests:NetTable(true)
	end
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
							GameMode.KickVotingCount > 0
						then
							GameMode.KickVotingCount = GameMode.KickVotingCount - 1
							EmitGlobalSound( "Game.KickVotingButton" )
							GameMode:KickVoting( AU_NOTICE_TYPE_KICK_VOTING_CONVENE, player )
						end
					elseif data.failure == 1 then
						player:SetMinigame()
					end
				end
			} )
		end,
		radius = 350,
		ghostDisable = true
	},
	camera = {
		event = function( _, player )
			player:SetMinigame( {
				type = AU_MINIGAME_CAMERA,
			} )
		end,
		ghostDisable = true
	},
	stone = {},
	voker = {},
	camera_ward_1 = {},
	camera_ward_2 = {},
	camera_ward_3 = {},
	camera_ward_4 = {},
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
	batrider = {},
	osu = {},
	mortred = {},
	collect = {},
	alchemist = {},
	interference = { globalQuest = true, ghostDisable = true },
	eclipse = { globalQuest = true, ghostDisable = true },
	reactor = { globalQuest = true, ghostDisable = true },
	oxygen_1 = { globalQuest = true, questName = "oxygen", ghostDisable = true },
	oxygen_2 = { globalQuest = true, questName = "oxygen", color = { 139, 69, 19 }, ghostDisable = true }
}

local minigameRecipes = {
	item_recipe_moon_shard = "item_moon_shard",
	item_recipe_magic_wand = "item_magic_wand",
	item_recipe_travel_boots = "item_travel_boots",
	item_recipe_travel_boots_2 = "item_travel_boots_2",
	item_recipe_phase_boots = "item_phase_boots",
	item_recipe_power_treads = "item_power_treads",
	item_recipe_hand_of_midas = "item_hand_of_midas",
	item_recipe_oblivion_staff = "item_oblivion_staff",
	item_recipe_pers = "item_pers",
	item_recipe_poor_mans_shie = "item_poor_mans_shield",
	item_recipe_bracer = "item_bracer",
	item_recipe_wraith_band = "item_wraith_band",
	item_recipe_null_talisman = "item_null_talisman",
	item_recipe_mekansm = "item_mekansm",
	item_recipe_vladmir = "item_vladmir",
	item_recipe_buckler = "item_buckler",
	item_recipe_ring_of_basili = "item_ring_of_basilius",
	item_recipe_holy_locket = "item_holy_locket",
	item_recipe_pipe = "item_pipe",
	item_recipe_urn_of_shadows = "item_urn_of_shadows",
	item_recipe_headdress = "item_headdress",
	item_recipe_sheepstick = "item_sheepstick",
	item_recipe_orchid = "item_orchid",
	item_recipe_bloodthorn = "item_bloodthorn",
	item_recipe_echo_sabre = "item_echo_sabre",
	item_recipe_cyclone = "item_cyclone",
	item_recipe_aether_lens = "item_aether_lens",
	item_recipe_force_staff = "item_force_staff",
	item_recipe_hurricane_pike = "item_hurricane_pike",
	item_recipe_dagon = "item_dagon",
	item_recipe_necronomicon = "item_necronomicon",
	item_recipe_assault = "item_assault",
	item_recipe_refresher = "item_refresher",
	item_recipe_black_king_bar = "item_black_king_bar",
	item_recipe_shivas_guard = "item_shivas_guard",
	item_recipe_bloodstone = "item_bloodstone",
	item_recipe_sphere = "item_sphere",
	item_recipe_lotus_orb = "item_lotus_orb",
	item_recipe_meteor_hammer = "item_meteor_hammer",
	item_recipe_nullifier = "item_nullifier",
	item_recipe_aeon_disk = "item_aeon_disk",
	item_recipe_kaya = "item_kaya",
	item_recipe_spirit_vessel = "item_spirit_vessel",
	item_recipe_vanguard = "item_vanguard",
	item_recipe_crimson_guard = "item_crimson_guard",
	item_recipe_blade_mail = "item_blade_mail",
	item_recipe_soul_booster = "item_soul_booster",
	item_recipe_hood_of_defiance = "item_hood_of_defiance",
	item_recipe_rapier = "item_rapier",
	item_recipe_monkey_king_bar = "item_monkey_king_bar",
	item_recipe_radiance = "item_radiance",
	item_recipe_butterfly = "item_butterfly",
	item_recipe_greater_crit = "item_greater_crit",
	item_recipe_basher = "item_basher",
	item_recipe_bfury = "item_bfury",
	item_recipe_manta = "item_manta",
	item_recipe_lesser_crit = "item_lesser_crit",
	item_recipe_dragon_lance = "item_dragon_lance",
	item_recipe_armlet = "item_armlet",
	item_recipe_invis_sword = "item_invis_sword",
	item_recipe_silver_edge = "item_silver_edge",
	item_recipe_sange_and_yasha = "item_sange_and_yasha",
	item_recipe_kaya_and_sange = "item_kaya_and_sange",
	item_recipe_yasha_and_kaya = "item_yasha_and_kaya",
	item_recipe_satanic = "item_satanic",
	item_recipe_mjollnir = "item_mjollnir",
	item_recipe_skadi = "item_skadi",
	item_recipe_sange = "item_sange",
	item_recipe_helm_of_the_dominator = "item_helm_of_the_dominator",
	item_recipe_maelstrom = "item_maelstrom",
	item_recipe_desolator = "item_desolator",
	item_recipe_yasha = "item_yasha",
	item_recipe_mask_of_madness = "item_mask_of_madness",
	item_recipe_diffusal_blade = "item_diffusal_blade",
	item_recipe_ethereal_blade = "item_ethereal_blade",
	item_recipe_soul_ring = "item_soul_ring",
	item_recipe_arcane_boots = "item_arcane_boots",
	item_recipe_octarine_core = "item_octarine_core",
	item_recipe_ancient_janggo = "item_ancient_janggo",
	item_recipe_medallion_of_courage = "item_medallion_of_courage",
	item_recipe_solar_crest = "item_solar_crest",
	item_recipe_veil_of_discord = "item_veil_of_discord",
	item_recipe_guardian_greaves = "item_guardian_greaves",
	item_recipe_rod_of_atos = "item_rod_of_atos",
	item_recipe_iron_talon = "item_iron_talon",
	item_recipe_abyssal_blade = "item_abyssal_blade",
	item_recipe_heavens_halberd = "item_heavens_halberd",
	item_recipe_ring_of_aquila = "item_ring_of_aquila",
	item_recipe_tranquil_boots = "item_tranquil_boots",
	item_recipe_glimmer_cape = "item_glimmer_cape",
	item_recipe_trident = "item_trident",
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
	suns = { type = AU_MINIGAME_SUNS },
	batrider = { type = AU_MINIGAME_BATRIDER },
	osu = { type = AU_MINIGAME_OSU, stepCount = 3 },
	mortred = { type = AU_MINIGAME_MORTRED, stepCount = 2 },
	collect = { type = AU_MINIGAME_COLLECT, stepCount = 3 },
	alchemist = { type = AU_MINIGAME_ALCHEMIST, stepCount = 3},
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
	local minigameCollect = {}
	
	for recipeName, itemData in pairs( LoadKeyValues( "scripts/npc/npc_items_custom.txt" ) ) do
		if type( itemData ) == "table" then
			local requirements = itemData.ItemRequirements
			if minigameRecipes[recipeName] and requirements then
				local _, v = next( requirements )
	
				if v then
					local item = {}
					local i = 1
	
					for name in v:gmatch( "([^;]+)" ) do
						item[i] = name
						i = i + 1
					end
					
					minigameCollect[minigameRecipes[recipeName]] = item
				end
			end
		else
			print( recipeName, itemData )
		end
	end

	CustomNetTables:SetTableValue( "game", "minigame_collect_items", minigameCollect )
	
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

			if quest and not quest.completed then
				quest:Trigger( unit, activator )
			end
		end
	else
		event = function( unit, activator )
			local quest = activator:FindQuest( questName )

			if quest and not quest.completed then
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
		"bottle",
		"osu",
		"alchemist",
		"collect"
	}
	local quests2 = {
		"meepo",
		"meteorites",
		"mortred"
	}
	local quests3 = {
		"suns",
		"faceless",
		"search",
		"wisp",
		"cog",
		"batrider"
	}

	local quests = {
		--quests1[RandomInt( 1, #quests1 )],
		quests2[RandomInt( 1, #quests2 )],
		--quests3[RandomInt( 1, #quests3 )]
	}

	for i = 1, 2 do
		local r = RandomInt( 1, #quests3 )

		table.insert( quests, quests3[r] )
		table.remove( quests3, r )
	end

	for i = 1, 2 do
		local r = RandomInt( 1, #quests1 )

		table.insert( quests, quests1[r] )
		table.remove( quests1, r )
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

	if GameMode.visibleTaks then
		Quests:NetTable()
	end
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
			taskPointsToWin = taskPointsToWin + 5
		end
	end

	if taskPointsToWin == 0 then
		taskPointsToWin = 10
	end

	self.taskPointsToWin = taskPointsToWin

	if GameMode.visibleTaks then
		Quests:NetTable()
	end
end

function Quests:NetTable(task)
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

	if task then
		local table = CustomNetTables:GetTableValue("game", "quests")
		if table then
			local old_p = table.points
			if old_p then
				t.points = old_p
				CustomNetTables:SetTableValue( "game", "quests", t )
				return
			end
		end
	end
	CustomNetTables:SetTableValue( "game", "quests", t )
end