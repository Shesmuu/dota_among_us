Http = {
	host = PRODUCTION_MODE and "http://91.228.152.171:1337/" or "http://91.228.152.171:1488/",
	dedicatedKey = PRODUCTION_MODE and GetDedicatedServerKeyV2( "AllHailLelouch" ) or "AllHailLelouch"
}

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
					player.stats.ratingImposter = p.imposter_rating
					player.stats.ratingPeace = p.peace_rating
					player.stats.rating = p.rating
				end
			end

			player:NetTable()
		end

		GameMode.hasServerData = true
	end, 5 )
end

function Http:IsValidGame()
	if not PRODUCTION_MODE then
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

function Http:Request( url, data, success, att )
	if not self:IsValidGame() then
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