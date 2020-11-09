class Leaderboard {
	constructor() {
		
	}
}

class Profile {
	constructor() {
		let id = Players.GetLocalPlayer()
		let name = Players.GetPlayerName( id )

		this.panel = $( "#Profile" )
		this.playerStats = this.panel.FindChildTraverse( "PlayerStats" )
		this.playerStats.FindChildTraverse( "Nickname" ).text = name

		let avatar = this.playerStats.FindChildTraverse( "Avatar" )
		avatar.style.width = "100%"
		avatar.style.height = "100%"
		avatar.steamid = Game.GetPlayerInfo( id ).player_steamid

		this.leaderboardPlayers = this.panel.FindChildTraverse( "LeaderboardPlayers" )

		let table = CustomNetTables.GetTableValue( "player", id.toString() )

		if ( table ) {
			this.playerStats.FindChildTraverse( "Rating" ).text = table.rating
			this.playerStats.FindChildTraverse( "TotalMatches" ).text = table.total_matches
			this.playerStats.FindChildTraverse( "FavoriteHero" ).heroname = table.favorite_hero
		}

		this.UpdateLeaderboard()
	}

	Toggle() {
		this.panel.ToggleClass( "Visible" )
	}

	LeaderboardPlayerRow( place, steamID, rating ) {
		let panel = $.CreatePanel( "Panel", this.leaderboardPlayers, "" )
		panel.BLoadLayoutSnippet( "LeaderboardPlayerRow" )
	
		let placeLabel = panel.FindChildTraverse( "Place" )
		placeLabel.text = Number( place ) + 1
	
		let avatar = panel.FindChildTraverse( "Avatar" )
		avatar.steamid = steamID
		avatar.style.width = "100%"
		avatar.style.height = "100%"
	
		let nickname = panel.FindChildTraverse( "Nickname" )
		nickname.steamid = steamID
	
		let ratingPanel = panel.FindChildTraverse( "Rating" )
		ratingPanel.text = rating
	}

	UpdateLeaderboard() {
		$.AsyncWebRequest( "http://91.228.152.171:1337/api/leaderboard", { type: "POST", 
			success: ( jsonData ) => {
				let data = JSON.parse( jsonData )
		
				this.leaderboardPlayers.RemoveAndDeleteChildren()
		
				for ( let place in data ) {
					let player = data[place]
		
					this.LeaderboardPlayerRow( place, player.steam_id, player.rating )
				}
			}
		} )
	}
}