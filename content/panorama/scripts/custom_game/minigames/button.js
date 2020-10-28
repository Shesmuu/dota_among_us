class MinigameButton extends Minigame {
	constructor() {
		super( "#au_minigame_button_title", "ButtonContainer" )

		this.type = AU_MINIGAME_REACTOR
		this.container.BLoadLayoutSnippet( "MinigameButton" )
		this.progress = this.container.FindChildTraverse( "Progress" )
		this.button = this.container.FindChildTraverse( "Button" )

		this.duration = 1.5

		this.button.SetPanelEvent( "onactivate", () => {
			this.Clicked()
		} )
	}

	Clicked() {
		if ( !this.clicked ) {
			this.clicked = true
			this.startTime = Game.GetGameTime()
		}
	}

	Update( now ) {
		if ( this.clicked && !this.finished_ ) {
			let progress = ( now - this.startTime ) / this.duration || 0

			this.progress.style.width = progress * 90 + "px"

			if ( progress >= 1 ) {
				this.finished_ = true

				GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
					completed: true
				} )
			}
		}
	}
}