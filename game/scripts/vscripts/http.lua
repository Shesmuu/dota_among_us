local hostes = {
	[0] = "http://91.228.152.171:1337/",
	[1] = "http://91.228.152.171:1488/",
	[2] = "http://localhost:1488/",
}

Http = {
	host = hostes[HTTP_MODE],
	dedicatedKey = HTTP_MODE == 0 and GetDedicatedServerKeyV2( "AllHailLelouch" ) or "AllHailLelouch"
}

function Http:AfterMatch()
	
end

function Http:CustomGameSetup()
	local steamIDs = {}

	for id, _ in pairs( GameMode.players ) do
		table.insert( steamIDs, tostring( PlayerResource:GetSteamID( id ) ) )
	end

	self:Request( "api/match/before", steamIDs, function( data )
		if GameRules:State_Get() >= DOTA_GAMERULES_STATE_STRATEGY_TIME then
			return
		end

		for steamID, heroName in pairs( data.favoriteHeroes ) do
			for id, player in pairs( GameMode.players ) do
				if player.steamID == steamID then
					player.stats.favoriteHero = heroName
				end
			end
		end

		for steamID, count in pairs( data.totalMatches ) do
			for id, player in pairs( GameMode.players ) do
				if player.steamID == steamID then
					player.stats.totalMatches = count
				end
			end
		end

		for id, player in pairs( GameMode.players ) do
			for _, p in pairs( data.players ) do
				if player.steamID == p.steam_id then
					player.stats.peace_streak = p.peace_streak
					player.stats.low_priority = p.low_priority_
					player.stats.ban = p.ban
					player.stats.rating = p.rating

					player.stats.toxic_reports = p.toxic_reports
					player.stats.party_reports = p.party_reports
					player.stats.cheat_reports = p.cheat_reports
					player.stats.reports_update_countdown = p.reports_update_countdown

					player.admin = p.admin == 1
					player.reportsRemaining = p.reports_remaining
				end
			end

			player:NetTable()
		end


		CustomNetTables:SetTableValue( "game", "global_matches", {
			peace_wins = data.peaceWins,
			imposter_wins = data.imposterWins
		} )

		GameMode.hasServerData = true
	end, 5, true )
end

function Http:IsValidGame()
	if HTTP_MODE ~= 0 then
		return true
	end

	if not IsInToolsMode() and GameRules:IsCheatMode() then
		return false
	end

	if not IsTest() and GameMode.playerCount < 10 then
		return false
	end

	return true
end

function Http:Request( url, data, success, att, perm )
	if not self:IsValidGame() or ( not GameMode.hasServerData and not perm ) then
		return
	end

	local r = CreateHTTPRequestScriptVM( "POST", self.host .. url )

	r:SetHTTPRequestHeaderValue( "dedicated_server_key", self.dedicatedKey )

	if data then
		r:SetHTTPRequestRawPostBody( "application/json", json.encode( data ) )
	end

	r:Send( function( res )
		if res.StatusCode == 200 then
			local decoded = json.decode( res.Body )

			if success then
				success( decoded )
			end
		else
			if att and att > 0 then
				print( "Status code ~= 200" )

				Delay( 1, function()
					self:Request( url, data, success, att - 1 )
				end )
			end
		end
	end )
end