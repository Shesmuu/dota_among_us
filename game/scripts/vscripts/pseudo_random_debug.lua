while true do

local players = {}
local mafcounts = {}
local maxStreaks = {}
local playerStreaks = {}

for i = 0, 9 do
    players[i] = 0
    mafcounts[i] = 0
    maxStreaks[i] = 0
    playerStreaks[i] = {}
end

local gameCount = 18

for piz = 1, gameCount do
        local count = 10
		local playerCount = count
		local needImpostor = 1
		local impostorCount = 0
        local imposters = {}

		if count > 5 then
			needImpostor = 2
		end

		local avgStreak = 0 

		for id, streak in pairs( players ) do
			avgStreak = avgStreak + streak + 1
		end

		avgStreak = avgStreak / count

			for _ = 1, needImpostor do
				local i = 0
				local candidates = {}

				for id, streak in pairs( players ) do
					if streak > maxStreaks[id] then
						maxStreaks[id] = streak
					end
					if not imposters[id] then
						local chance = math.floor((streak + 1 / avgStreak)^5*10)

						--if chance == 5 then
						--	chance = 10
						--elseif chance > 5 then
						--	chance = chance % 4 * 10
						--end

						--chance = math.min( chance, 200 )

						for __ = 1, chance do
							i = i + 1
							candidates[i] = id
						end
					end
				end

				if i > 0 then
                    local id = candidates[RandomInt( 1, i )]

                    table.insert( playerStreaks[id], players[id] )

					players[id] = 0
            mafcounts[id] = mafcounts[id] + 1
                    imposters[id] = true

					impostorCount = impostorCount + 1
                else
          			  error( "i <= 0" )
				end
			end


			for id, streak in pairs( players ) do

				if not imposters[id] then
					players[id] = streak + 1
				end
			end

			if impostorCount < needImpostor then
				error( "impostorCount < needImpostor" ) 
			end
end
			local avgMaxStreak = 0
    
    for id, mafcount in pairs( mafcounts ) do
    	avgMaxStreak = avgMaxStreak + maxStreaks[id]
		local avgStreak = 0

		for _, s in pairs( playerStreaks[id] ) do
			avgStreak = avgStreak + s
		end

		avgStreak = avgStreak / #playerStreaks[id]
           print( id, mafcount, maxStreaks[id], avgStreak, #playerStreaks[id] )
   end

   avgMaxStreak = avgMaxStreak / 10

   print( "avg max streak", avgMaxStreak )

	break
end