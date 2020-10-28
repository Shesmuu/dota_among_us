class KickVotingTimer {
	constructor() {
		this.panel = $( "#KickVotingTimer" )
		this.countdown = $( "#KickVotingCountdown" )
	}

	SetEnabled( bool ) {
		this.enabled = bool
		this.panel.SetHasClass( "Visible", bool )
	}

	SetEndTime( time ) {
		this.endTime = time
	}

	Update( now ) {
		if ( !this.enabled ) {
			return
		}

		this.countdown.text = Math.max( this.endTime - now, 0 ).toFixed( 0 )
	}
}