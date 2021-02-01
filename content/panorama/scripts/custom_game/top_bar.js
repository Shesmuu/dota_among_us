class TopBarPlayer {
	constructor( id, parent, color, solo ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.BLoadLayoutSnippet( "TopBarPlayer" )
		this.heroImage = this.panel.FindChildTraverse( "HeroImage" )
		this.impostorPanel = this.panel.FindChildTraverse( "Impostor" )
		this.impostorPanel.visible = false
		this.disconnected = this.panel.FindChildTraverse( "Disconnected" )
		this.disconnected.visible = false
		this.id = id
		this.solo = solo
		const colors = []
		colors[0] = "red"
		colors[1] = "green"
		colors[2] = "blue"
		colors[3] = "yellow"
		colors[4] = "orange"
		colors[5] = "pink"
		colors[6] = "purple"
		this.color = colors[color]
	}

	SetDied( bool ) {
		this.panel.SetHasClass( "Died", bool )
	}

	SetImpostor( bool ) {
		this.impostorPanel.visible = bool
	}

	UpdateConnection() {
		let cs = Game.GetPlayerInfo( Number(this.id) ).player_connection_state

		this.disconnected.visible = (
			cs == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED ||
			cs == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED
		)
	}

	Update() {
		let heroName = Players.GetPlayerSelectedHero( Number(this.id) )
		this.heroImage.heroname = heroName
		if (CustomNetTables.GetTableValue("player", Number( this.id ))) {
			if (Number(CustomNetTables.GetTableValue("player", Number( this.id )).partyid) !== 0 ){
				if (this.solo !== 0){
					this.panel.style.borderBottom = "5px solid "+this.color+" "
				}
			}
		}

		let cs = Game.GetPlayerInfo( Number(this.id) ).player_connection_state

		if (
			cs != DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED &&
			cs != DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED
		) {
			this.disconnected.visible = false
		}
	}
}

class TopBar {
	constructor() {
		let panel = $( "#TopBar" )

		this.container = panel.FindChildTraverse( "TopBarPlayers" )
		this.impostorsRemaining = panel.FindChildTraverse( "ImpostorsRemaining" )
		this.container.RemoveAndDeleteChildren()
		this.players = []
		this.parties = []
		this.UpdatePlayersParty()
		this.UpdatePlayers()
	}

	UpdatePlayersParty() {
		for ( let id = 0; id < 24; id++ ) {
			if ( Players.IsValidPlayerID( id ) )
			{
				if (CustomNetTables.GetTableValue("player", Number( id ))) {
					let player_party = CustomNetTables.GetTableValue("player", Number( id )).partyid
					this.parties[Number(player_party)] = this.parties[Number(player_party)] || []
					if (this.parties[Number(player_party)].indexOf( Number(id) ) == -1) {
						this.parties[Number(player_party)].push(Number(id))
					}
				}
			}
		}
	}

	UpdatePlayers() {
		let color = 0
		let solo = 1
		for ( let partyid in this.parties ) {
			for ( let party_count of this.parties[partyid] ) {
				if (this.parties[partyid].length < 2) { solo = 0 } else { solo = 1 }
				if ( Players.IsValidPlayerID( Number(party_count) ) ) {
					if ( !this.players[party_count] ) {
						this.players[party_count] = new TopBarPlayer( party_count, this.container, color, solo)
					}
					this.players[party_count].Update()
				}
			}
			color = color + 1
		}
	}

	NetTableImpostors( data ) {
		if ( !data[Players.GetLocalPlayer()] ) {
			for ( let id in this.players ) {
				this.players[id].SetImpostor( false )
			}

			return
		}

		for ( let id in this.players ) {
			this.players[id].SetImpostor( !!data[id] )
		}
	}

	NetTableDied( data ) {
		for ( let id in this.players ) {
			this.players[id].SetDied( !!data[id] )
		}
	}

	NetTableState( data ) {
		for ( let id in this.players ) {
			this.players[id].UpdateConnection()
		}
	}

	SetImpostorsRemainingVisible( bool ) {
		this.impostorsRemaining.visible = bool
	}

	SetImpostorsRemaining( count ) {
		this.impostorsRemaining.text = $.Localize( "au_impostor_remaining" ) + count
	}
}