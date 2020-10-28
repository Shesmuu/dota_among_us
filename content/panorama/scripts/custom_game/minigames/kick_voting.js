class MinigameKickVoting extends Minigame {
	constructor( cooldownEndTime, sabotageActive, kickCount ) {
		super( "#au_minigame_kick_voting_title", "KickVotingContainer" )

		this.type = AU_MINIGAME_KICK_VOTING
		this.cooldownEndTime = cooldownEndTime
		this.container.BLoadLayoutSnippet( "MinigameKickVoting" )
		this.sabotage = this.container.FindChildTraverse( "IsSabotage" )
		this.ready = this.container.FindChildTraverse( "IsReady" )
		this.fullReady = this.container.FindChildTraverse( "FullReady" )
		this.nonReady = this.container.FindChildTraverse( "NonReady" )
		this.cooldown = this.container.FindChildTraverse( "IsCooldown" )
		this.countdown = this.container.FindChildTraverse( "Countdown" )
		this.kickCountPanel = this.container.FindChildTraverse( "KickCount" ) 

		this.container.FindChildTraverse( "Button" ).SetPanelEvent( "onactivate", () => {
			if ( this.isReady ) {
				this.Complete()
			}
		} )

		this.SetSabotage( sabotageActive )
		this.SetKickCount( kickCount )
	}

	SetKickCount( kickCount ) {
		this.kickCount = kickCount
		this.kickCountPanel.text = ( $.Localize( "#kick_voting_count" ) + kickCount ).toUpperCase()
	}

	SetSabotage( bool ) {
		this.isSabotage = bool
		this.sabotage.visible = bool

		if ( !bool ) {
			this.SetReady( true )
		} else {
			this.isReady = false
			this.ready.visible = false
			this.cooldown.visible = false
		}
	}

	SetReady( bool ) {
		this.isReady = bool
		this.ready.visible = bool
		this.cooldown.visible = !bool

		let count = ( this.kickCount > 0 )

		if ( bool ) {
			this.isReady = count
		}

		this.fullReady.visible = count
		this.nonReady.visible = !count
	}

	Update( now ) {
		if ( this.isSabotage ){
			return
		}

		if ( this.cooldownEndTime && now >= this.cooldownEndTime ) {
			this.SetReady( true )
		} else {
			this.SetReady( false )

			this.countdown.text = ( this.cooldownEndTime - now ).toFixed( 0 )
		}
	}
}