timer_cycle = class({})

function timer_cycle:StartGameTimer()  
	local timer = SpawnEntityFromTableSynchronous("info_target", { targetname = "timer_cycle" })
	nCOUNTDOWNTIMER = 0
    timer:SetThink( TimerOnThink, 1 )
end

function TimerOnThink()
	if GameMode.state ~= AU_GAME_STATE_KICK_VOTING then
		nCOUNTDOWNTIMER = nCOUNTDOWNTIMER + 1
		CountdownTimer()
	end
	return 1
end

function CountdownTimer()
    local t = nCOUNTDOWNTIMER
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer = 
    {
    	time_full = minutes,
        timer_minute_10 = m10,
        timer_minute_01 = m01,
        timer_second_10 = s10,
        timer_second_01 = s01,
    }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
	if math.fmod(minutes,2)~=0 then
		for _, p in pairs( GameMode.players ) do
			if p.hero and p.alive then
				p.hero:SetBaseMoveSpeed( 450 )
				if p.hero:GetUnitName() == "npc_dota_hero_invoker" then
					p.hero:SetBaseMoveSpeed( 400 )
				end
			end
		end
		if Quests.eclipse == true then return end
		GameMode:DefaultNight()
	else
		for _, p in pairs( GameMode.players ) do
			if p.hero and p.alive then
				p.hero:SetBaseMoveSpeed( 500 )
				if p.hero:GetUnitName() == "npc_dota_hero_invoker" then
					p.hero:SetBaseMoveSpeed( 450 )
				end
			end
		end 
		if Quests.eclipse == true then return end
		GameMode:DefaultDay()
	end
end









