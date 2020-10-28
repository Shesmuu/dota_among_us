class MinigameSuns extends Minigame {
	constructor() {
		super( "#au_minigame_suns_title", "SunsContainer" )

		this.type = AU_MINIGAME_SUNS
		this.button = $.CreatePanel( "Image", this.container, "" )
		this.button.SetImage( "file://{images}/spellicons/phoenix_supernova.png" )

		this.button.SetPanelEvent( "onmouseover", () => {
			this.mouseOvered = true
		} )

		this.button.SetPanelEvent( "onmouseout", () => {
			this.MouseOut()
		} )
	}

	MouseOut() {
		if ( this.started ) {
			this.Failure()
		}
	}

	Failure() {
		this.failure = true

		GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
			failure: true
		} )
	}

	Update() {
		if ( !this.failure && this.started && !GameUI.IsMouseDown( 0 ) ) {
			this.Failure()
		}

		if ( !this.started && this.mouseOvered && GameUI.IsMouseDown( 0 ) ) {
			this.started = true

			GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
				completed: true
			} )
		}
	}
}