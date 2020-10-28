class TopBarPlayer {
	constructor( id, parent ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.BLoadLayoutSnippet( "TopBarPlayer" )
		this.heroImage = this.panel.FindChildTraverse( "HeroImage" )
		this.impostorPanel = this.panel.FindChildTraverse( "Impostor" )
		this.impostorPanel.visible = false
		this.disconnected = this.panel.FindChildTraverse( "Disconnected" )
		this.id = id
	}

	SetDied( bool ) {
		this.panel.SetHasClass( "Died", bool )
	}

	SetImpostor( bool ) {
		this.impostorPanel.visible = bool
	}

	Update() {
		let heroName = Players.GetPlayerSelectedHero( this.id )
		this.heroImage.heroname = heroName

		let cs = Game.GetPlayerInfo( this.id ).player_connection_state

		this.disconnected.visible = (
			cs == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED ||
			cs == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED
		)
	}
}

class TopBar {
	constructor() {
		this.container = $( "#PlayersContainer" )
		this.impostorsRemaining = $( "#ImpostorsRemaining" )
		this.container.RemoveAndDeleteChildren()
		this.players = []

		this.UpdatePlayers()
	}

	UpdatePlayers() {
		for ( let id = 0; id < 24; id++ ) {
			if ( Players.IsValidPlayerID( id ) ) {
				if ( !this.players[id] ) {
					this.players[id] = new TopBarPlayer( id, this.container )
				}

				this.players[id].Update()
			}
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

	SetImpostorsRemainingVisible( bool ) {
		this.impostorsRemaining.visible = bool
	}

	SetImpostorsRemaining( count ) {
		this.impostorsRemaining.text = $.Localize( "au_impostor_remaining" ) + count
	}
}