custom_selection = class({})

LinkLuaModifier( "modifier_starting_game", "custom_selection", LUA_MODIFIER_MOTION_NONE )

AMONG_US_PICK_STATE_PLAYERS_LOADED = "AMONG_US_PICK_STATE_PLAYERS_LOADED"
AMONG_US_PICK_STATE_BAN = "AMONG_US_PICK_STATE_BAN"
AMONG_US_PICK_STATE_SELECT = "AMONG_US_PICK_STATE_SELECT"
AMONG_US_PICK_STATE_PRE_END = "AMONG_US_PICK_STATE_PRE_END"
AMONG_US_PICK_STATE_END = "AMONG_US_PICK_STATE_END"

PICK_STATE_STATUS = {}
PICK_STATE_STATUS[1] = AMONG_US_PICK_STATE_PLAYERS_LOADED
PICK_STATE_STATUS[2] = AMONG_US_PICK_STATE_SELECT
PICK_STATE_STATUS[3] = AMONG_US_PICK_STATE_PRE_END
PICK_STATE_STATUS[4] = AMONG_US_PICK_STATE_END

TIME_OF_STATE = {}
TIME_OF_STATE[1] = 3
TIME_OF_STATE[2] = 60
TIME_OF_STATE[3] = 10

PLAYERS = {}
HEROES = {}
PICKED_HEROES = {}
IN_STATE = false
PICK_STATE = AMONG_US_PICK_STATE_PLAYERS_LOADED
DISCONNECTED = {}

function custom_selection:RegisterPlayerInfo( pid )
	local pinfo = PLAYERS[ pid ] or {
		bRegistred = false,
		bLoaded = false,
		steamid = PlayerResource:GetSteamAccountID( pid ),
		picked_hero = nil,
	}
	
	PLAYERS[ pid ] = pinfo
	return pinfo
end

function custom_selection:Init()
	IN_STATE = true
	StartTimerLoading()
	custom_selection:RegisterHeroes()
	CustomGameEventManager:RegisterListener( 'among_us_pick_select_hero', Dynamic_Wrap( self, 'PlayerSelect'))
	CustomGameEventManager:RegisterListener( 'among_us_pick_player_registred', Dynamic_Wrap( self, 'PlayerRegistred' ) )
	CustomGameEventManager:RegisterListener( 'among_us_pick_player_loaded', Dynamic_Wrap( self, 'PlayerLoaded' ) )
	
	for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidTeamPlayerID(i) then
			custom_selection:RegisterPlayerInfo(i)
		end
	end
	
	Schedule( 1, function()
		custom_selection:ServerReady()
	end )
end

function custom_selection:ServerReady()
	custom_selection:CheckReadyPlayers()
end

function custom_selection:CheckReadyPlayers( attempt )
	if PICK_STATE ~= AMONG_US_PICK_STATE_PLAYERS_LOADED then
		return
	end
	
	local bAllReady = true
	for pid, pinfo in pairs( PLAYERS ) do
		if pinfo.bRegistred and not pinfo.bLoaded then
			bAllReady = false
		end
	end

	if bAllReady then
		custom_selection:Start()
	else
		local check_interval = 0.5
		attempt = ( attempt or 0 ) + check_interval
		if attempt > TIME_OF_STATE[1] then
			custom_selection:Start()
		else
			Schedule( check_interval, function()
				custom_selection:CheckReadyPlayers( attempt )
			end )
		end
	end
end

function custom_selection:PlayerRegistred( kv )
	local pinfo = custom_selection:RegisterPlayerInfo( kv.PlayerID )
	pinfo.bRegistred = true
end

function custom_selection:PlayerLoaded( kv )
	local pid = kv.PlayerID
	if not PLAYERS[ pid ] then
		CustomGameEventManager:Send_ServerToPlayer( player, 'pick_end', {} )
		return
	end
	
	PLAYERS[ pid ].bLoaded = true
	
	local player = PlayerResource:GetPlayer( pid )
	local team = PlayerResource:GetTeam( pid )
	
	if not IN_STATE then
		CustomGameEventManager:Send_ServerToPlayer( player, 'pick_end', {} )
		return
	end

	if PICK_STATE ~= AMONG_US_PICK_STATE_PLAYERS_LOADED then
		custom_selection:DrawHeroesForPlayer( pid )
		custom_selection:DrawPickScreenForPlayer( pid )
		CustomGameEventManager:Send_ServerToPlayer( player, 'pick_filter_reconnect', {picked = PICKED_HEROES, picked_length = #PICKED_HEROES})
		if PICK_STATE == AMONG_US_PICK_STATE_SELECT then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pick_start_selection', {} )
		elseif PICK_STATE == AMONG_US_PICK_STATE_PRE_END then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pick_preend_start', {} )
		elseif PICK_STATE == AMONG_US_PICK_STATE_END then
			CustomGameEventManager:Send_ServerToPlayer( player, 'pick_end', {} )
		end
	end
end

function custom_selection:Start()
	for pid, pinfo in pairs( PLAYERS ) do
		if pinfo.bLoaded then
			custom_selection:DrawHeroesForPlayer()
			custom_selection:DrawPickScreenForPlayer( pid )
		end
	end
	custom_selection:StartSelectionStage()
end

function custom_selection:DrawPickScreenForPlayer( pid )
	if not PlayerResource:IsValidPlayerID( pid ) then
		return
	end
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( pid ), 'pick_start', {} )
end

function custom_selection:DrawHeroesForPlayer()
	CustomGameEventManager:Send_ServerToAllClients( 'pick_load_heroes', HEROES)
end

function custom_selection:RegisterHeroes()
	local enable_heroes = {}
	local all_heroes = {}
	rating_heroes = {}
	local heroes = LoadKeyValues("scripts/npc/activelist.txt")
	local heroes_info = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	for k,v in pairs(heroes) do
		if v == 1 then
			table.insert(enable_heroes, k)
		end
	end
	for _,hero in pairs(enable_heroes) do
		local abilities = {}
		for i = 1, 2 do
			local ability = IMPOSTOR_ABILITIES[hero][i]
			if ability then
				if ability ~= nil and ability ~= "" then
					table.insert(abilities, ability)
				end
			end
		end
		CustomNetTables:SetTableValue("among_us_pick", tostring(hero), abilities)
	end
	HEROES = enable_heroes
	for _,hero in pairs(enable_heroes) do
		table.insert(all_heroes, hero)
		if heroes_info[hero] and heroes_info[hero].RatingHero == 1 then
			table.insert(rating_heroes, {hero = hero, ratingneed = heroes_info[hero].RatingNeed})
		end
	end
	CustomNetTables:SetTableValue("among_us_pick", "hero_list", {all_heroes = all_heroes, all_heroes_length = #all_heroes , rating_heroes = rating_heroes, rating_heroes_lenght = #rating_heroes})
end

function custom_selection:StartSelectionStage()
	PICK_STATE = AMONG_US_PICK_STATE_SELECT
	CustomGameEventManager:Send_ServerToAllClients( 'pick_start_selection', {} )
	custom_selection:StartTimers( TIME_OF_STATE[2], function()
		custom_selection:EndSelectionStage()
	end )	
end

function custom_selection:EndSelectionStage()
	if PICK_STATE ~= AMONG_US_PICK_STATE_SELECT then
		return
	end
	CustomNetTables:SetTableValue("among_us_pick", "picked_heroes", PICKED_HEROES)
	custom_selection:StartPreEndSelection()
end

function custom_selection:StartPreEndSelection()
	PICK_STATE = AMONG_US_PICK_STATE_PRE_END
	CustomGameEventManager:Send_ServerToAllClients( 'pick_preend_start', {} )
	custom_selection:GiveHeroes()
	custom_selection:StartTimers( TIME_OF_STATE[3], function()
		custom_selection:EndSelection()
	end )	
end

function custom_selection:EndSelection()
	if not IN_STATE then
		return
	end
	IN_STATE = false
	PICK_STATE = AMONG_US_PICK_STATE_END
	pick_ended = true
	CustomGameEventManager:Send_ServerToAllClients( 'pick_end', {} )
	for pid, pinfo in pairs( PLAYERS ) do
		PlayerResource:SetCameraTarget(pid, nil)
	end
	Settings:Start()
end

function custom_selection:PlayerSelect( kv )
	local pid = kv.PlayerID
	local pinfo = PLAYERS[ pid ]
	if PICK_STATE == AMONG_US_PICK_STATE_SELECT then
		if kv.random then
			kv.hero = custom_selection:RandomHeroForPlayer()
		end
		if IsHeroNotAvailable(kv.hero) or pinfo.picked_hero then return end
		pinfo.picked_hero = kv.hero
		table.insert(PICKED_HEROES, kv.hero)
		CustomGameEventManager:Send_ServerToAllClients( 'pick_select_hero', { hero = kv.hero})
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(pid), 'hero_is_picked', {})
		custom_selection:GiveHeroPlayer(pid, pinfo.picked_hero)
		CheckPlayerHeroes()
	end
end

function CheckPlayerHeroes()
	if PICK_STATE == AMONG_US_PICK_STATE_PRE_END or PICK_STATE == AMONG_US_PICK_STATE_END then return end
	for pid, pinfo in pairs( PLAYERS ) do
		if pinfo.picked_hero == nil then
			return 
		end
	end
	custom_selection:EndSelectionStage()
end

function custom_selection:GiveHeroPlayer(id,hero)
	local wisp = PlayerResource:GetSelectedHeroEntity(id)
	PlayerResource:ReplaceHeroWith(id, hero, 700, 0)
	UTIL_Remove(wisp)
	local new_hero = PlayerResource:GetSelectedHeroEntity(id)
	PlayerResource:SetCameraTarget(new_hero:GetPlayerOwnerID(), new_hero)
	GameMode.players[id]:HeroSpawned( hero )
	if PICK_STATE == AMONG_US_PICK_STATE_END then
		PlayerResource:SetCameraTarget(new_hero:GetPlayerOwnerID(), nil)
	end
end

function custom_selection:RandomHeroForPlayer()
	local table = CustomNetTables:GetTableValue("among_us_pick", "hero_list")
	local random_hero = RandomInt(1, #HEROES)
	if IsHeroNotAvailable(HEROES[random_hero]) then return self:RandomHeroForPlayer() end
	for i = 1, table.rating_heroes_lenght do
		print(rating_heroes[i].hero, HEROES[random_hero])
		if HEROES[random_hero] == rating_heroes[i].hero then return self:RandomHeroForPlayer() end
	end
	return HEROES[random_hero]
end

function IsHeroNotAvailable(hero)
	for a = 1, #PICKED_HEROES do
		if hero == PICKED_HEROES[a] then
			return true
		end
	end
	return false
end

function IsHeroReconnectPicked(hero)
	for a = 1, #PICKED_HEROES do
		if hero == PICKED_HEROES[a] then
			return true
		end
	end
	return false
end

function custom_selection:GiveHeroes()
	for pid, pinfo in pairs( PLAYERS ) do
		if pinfo.picked_hero == nil then
			local hero = custom_selection:RandomHeroForPlayer()
			pinfo.picked_hero = hero
			table.insert(PICKED_HEROES, hero)
			CustomGameEventManager:Send_ServerToAllClients( 'pick_select_hero', { hero = hero})
			--if IsPlayerDisconnected(pid) then
			--	DISCONNECTED[pid] = hero
			--else
				custom_selection:GiveHeroPlayer(pid, hero)
			--end
		end
	end
end

function custom_selection:StartTimers( delay, fExpire )
	local n = 1
	local f = function()
		n = n - 1
		if n == 0 then
			fExpire()
		end
	end
	self:StartTimer( delay, f )
end

function custom_selection:StartTimer( delay, fExpire )
	local timer_number = ( self.StartTimerNumber or 0 ) + 1
	self.StartTimerNumber = timer_number
	self.Timers = delay
	local tick_interval = 1/30
	local delay_int
	
	Timer( function( dt )
		if self.StartTimerNumber ~= timer_number then
			return
		end
		
		delay = delay - dt
		self.Timers = delay
		
		if delay <= 0 then
			self.Timers = 0
			fExpire()
			return
		end
		
		local new_delay_int = math.floor( delay )
		if delay_int ~= new_delay_int then
			delay_int = new_delay_int
			CustomGameEventManager:Send_ServerToAllClients( 'pick_timer_upd', { timer = delay_int })
		end
		return tick_interval
	end )
end

modifier_starting_game = class({})

function modifier_starting_game:IsHidden()
	return true
end

function modifier_starting_game:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,[MODIFIER_STATE_MUTED]= true,[MODIFIER_STATE_SILENCED]= true,[MODIFIER_STATE_NIGHTMARED] = true,[MODIFIER_STATE_NO_HEALTH_BAR] = true,[MODIFIER_STATE_OUT_OF_GAME] = true,[MODIFIER_STATE_MAGIC_IMMUNE] = true,[MODIFIER_STATE_INVULNERABLE] = true, }
end

function modifier_starting_game:OnCreated()
	self:StartIntervalThink(FrameTime())
end

function modifier_starting_game:OnIntervalThink()
	if pick_ended then 
		self:Destroy() 
	end
end

function StartTimerLoading()  
	local timer = SpawnEntityFromTableSynchronous("info_target", { targetname = "hero_selection_timer" })
    timer:SetThink( _TimerThinker, 1 )
end

local _TimerThinker__Timers = {}
local _TimerThinker__Events = {}
local _TimerThinker__Events_Index = {}
local timer_dt = 1/30
local timer_time = 0
function _TimerThinker()
    local i = 1
    while _TimerThinker__Events_Index[i] and _TimerThinker__Events_Index[i] <= timer_time do
        local event_time = _TimerThinker__Events_Index[i]
        local tRemove_timers = {}
        
        for _, timer_id in pairs( _TimerThinker__Events[ event_time ] ) do
            local next_event_time = event_time
            if next_event_time and next_event_time <= timer_time then
                local interval = (_TimerThinker__Timers[ timer_id ])()
                if type(interval) ~= 'number' or interval < 0 then
                    next_event_time = nil
                else
                    next_event_time = next_event_time + interval
                end
            end
            
            if next_event_time then
                _AddTimerEvent( next_event_time, timer_id )
            else
                tRemove_timers[ timer_id ] = true
            end
        end
        
        for timer_id in pairs( tRemove_timers ) do
            _RemoveTimer( timer_id )
        end
        
        _RemoveTimerEvent( i )      
        i = i + 1
    end
    
    timer_time = timer_time + timer_dt
    return timer_dt
end

function _AddTimerEvent( event_time, timer_id )
    local i = 1
    while _TimerThinker__Events_Index[i] and _TimerThinker__Events_Index[i] < event_time do
        i = i + 1
    end
    
    if event_time == _TimerThinker__Events_Index[i] then
        local event = _TimerThinker__Events[ event_time ]
        table.insert( event, timer_id )
    else
        _TimerThinker__Events[ event_time ] = {timer_id}
        table.insert( _TimerThinker__Events_Index, i, event_time )
    end
    
    return i
end

function _RemoveTimerEvent( event_id )
    local event_time = _TimerThinker__Events_Index[ event_id ]
    table.remove( _TimerThinker__Events_Index, event_id )
    _TimerThinker__Events[ event_time ] = nil
end

function _AddTimer( f )
    local timer_id = 1
    while _TimerThinker__Timers[ timer_id ] do
        timer_id = timer_id + 1
    end
    _TimerThinker__Timers[ timer_id ] = f
    return timer_id
end

function _RemoveTimer( id )
    for _, event in pairs( _TimerThinker__Events ) do
        for k, timer_id in pairs( event ) do
            if timer_id == id then
                table.remove( event, k )
            end
        end
    end
    _TimerThinker__Timers[ id ] = nil
end

function Schedule( d, f )
    d = d or 0
    if type(d) ~= 'number' or d < 0 then
    end

    while d and d == 0 do
        d = f()
    end
    
    local next_trigger_time = timer_time
    if d and d > 0 then
        next_trigger_time = next_trigger_time + d
    else
        next_trigger_time = nil
    end
    
    if next_trigger_time then
        local timer_id = _AddTimer(f)
        _AddTimerEvent( next_trigger_time, timer_id )
        return timer_id
    end
end

function Timer( f, d )
    local lasttime = GameRules:GetGameTime()
    local oldcall_time = lasttime
    local interval = d
    return Schedule( d, function()
        local curtime = GameRules:GetGameTime()
        local dt = curtime - lasttime
        lasttime = curtime
        interval = ( interval or 0 ) - dt
        if interval < 1/32 then
            local new_interval = f( curtime - oldcall_time )
            oldcall_time = curtime
            if type(new_interval) == 'number' then
                interval = math.max( 0.01, interval + new_interval )
                return interval
            else
                return
            end
        end
        return math.max( interval, 0.01 )
    end )
end  











