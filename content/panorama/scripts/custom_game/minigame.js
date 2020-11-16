AU_MINIGAME_STONE = 0
AU_MINIGAME_VOKER = 3
AU_MINIGAME_FIREBALLS = 4
AU_MINIGAME_X_MARK = 5
AU_MINIGAME_BOTTLE_1 = 6
AU_MINIGAME_BOTTLE_2 = 7
AU_MINIGAME_BOTTLE_3 = 8
AU_MINIGAME_BOTTLE_4 = 9
AU_MINIGAME_METEORITES = 10
AU_MINIGAME_MEEPO = 11
AU_MINIGAME_SEARCH = 12
AU_MINIGAME_FACELESS = 13
AU_MINIGAME_WISP = 14
AU_MINIGAME_SUNS = 15
AU_MINIGAME_COLLECT = 16
AU_MINIGAME_ALCHEMIST = 17
AU_MINIGAME_INTERFERENCE = 101
AU_MINIGAME_ECLIPSE = 102
AU_MINIGAME_OXYGEN = 103
AU_MINIGAME_REACTOR = 104
AU_MINIGAME_KICK_VOTING = 228

class Minigame {
	constructor( text, className ) {
		this.container = $.CreatePanel( "Panel", $( "#MinigameContainer" ), "" )
		this.container.AddClass( className )
		this.message = $( "#MinigameMessage" )
		this.message.SetHasClass( "Visible", false )
		this.message.visible = false

		this.SetMessageRed( false )

		this.className = className
		this.hideTime = 0

		$( "#MinigameTitle" ).text = $.Localize( text )
	}

	Update() {}

	Destroy() {
		$( "#MinigameContainer" ).RemoveAndDeleteChildren()

		this.HideMessage()
	}

	HideDelay( time ) {
		this.hideTime = Game.GetGameTime() + time
	}

	ShowMessage( text ) {
		this.message.visible = true
		this.message.text = $.Localize( text )

		this.message.SetHasClass( "Visible", true )
	}

	SetMessageRed( bool ) {
		this.message.SetHasClass( "Red", bool )
	}

	HideMessage() {
		this.message.SetHasClass( "Visible", false )
	}

	Complete( time, msg ) {
		this.finished = true
		this.completeTime = null
		this.failTime = null

		if ( time ) {
			this.HideDelay( time )
		}

		if ( msg ) {
			this.ShowMessage( msg )
		}

		GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
			completed: true
		} )
	}

	FailDelay( time, msg ) {
		this.failTime = Game.GetGameTime() + time

		this.SetMessageRed( true )

		if ( msg ) {
			this.ShowMessage( msg )
		}
	}

	Fail() {
		this.finished = true
		this.completeTime = null
		this.failTime = null

		GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
			failure: true
		} )
	}

	CheckFinish( now ) {
		if ( this.completeTime && now >= this.completeTime ) {
			this.Complete()
		} else if ( this.failTime && now >= this.failTime ) {
			this.Fail()
		}
	}
}

class Minigames {
	constructor() {
		this.panel = $( "#Minigame" )
		this.minigame = null

		$( "#MinigameContainer" ).RemoveAndDeleteChildren()
	}

	NetTableState( data ) {
		if ( data.kick_voting_cooldown ) {
			this.kickVotingCooldown = data.kick_voting_cooldown
		}

		this.sabotageActive = data.sabotage_active == 1

		if ( this.minigame && this.minigame.type == AU_MINIGAME_KICK_VOTING ) {
			this.minigame.SetSabotage( this.sabotageActive )
		}
	}

	NetTablePlayer( data ) {
		let m = data.minigame
		let count = data.kick_count

		if ( this.minigame && m != null ) {
			this.minigame.Destroy()
			this.minigame = null
		} else if ( this.minigame && this.minigame.type == AU_MINIGAME_KICK_VOTING ) {
			this.minigame.SetKickCount( count )
		}

		let minigames = []
		minigames[AU_MINIGAME_STONE] = MinigameFamiliar
		minigames[AU_MINIGAME_VOKER] = MinigameVoker
		minigames[AU_MINIGAME_FIREBALLS] = MinigameFireballs
		minigames[AU_MINIGAME_MEEPO] = MinigameMeepo
		minigames[AU_MINIGAME_FACELESS] = MinigameFaceless
		minigames[AU_MINIGAME_SEARCH] = MinigameSearch
		minigames[AU_MINIGAME_WISP] = MinigameWisp
		minigames[AU_MINIGAME_INTERFERENCE] = MinigameInterference
		minigames[AU_MINIGAME_ECLIPSE] = MinigameEclipse
		minigames[AU_MINIGAME_REACTOR] = MinigameButton
		minigames[AU_MINIGAME_OXYGEN] = MinigameOxygen
		minigames[AU_MINIGAME_X_MARK] = MinigameXMark
		minigames[AU_MINIGAME_SUNS] = MinigameSuns
		minigames[AU_MINIGAME_COLLECT] = MinigameCollect
		minigames[AU_MINIGAME_ALCHEMIST] = MinigameAlchemist

		if ( m != null ) {
			if ( minigames[m] != null ) {
				this.minigame = new minigames[m]
			} else if (
				m == AU_MINIGAME_BOTTLE_1 ||
				m == AU_MINIGAME_BOTTLE_2 ||
				m == AU_MINIGAME_BOTTLE_3 ||
				m == AU_MINIGAME_BOTTLE_4
			) {
				this.minigame = new MinigameBottle( m )
			} else if ( m == AU_MINIGAME_KICK_VOTING ) {
				this.minigame = new MinigameKickVoting( this.kickVotingCooldown, this.sabotageActive, count )
			}

			this.panel.SetHasClass( "Visible", true )
		} else if ( !this.minigame ) {
			this.panel.SetHasClass( "Visible", false )
		} else {
			this.minigame.finished = true
		}
	}

	Update( now ) {
		if ( this.minigame ) {
			this.minigame.CheckFinish( now )

			if ( !this.minigame.finished ) {
				this.minigame.Update( now )
			} else if ( now >= this.minigame.hideTime ) {
				this.panel.SetHasClass( "Visible", false )
			}
		} else {
			this.panel.SetHasClass( "Visible", false )
		}
	}
}