class MinigameEclipse extends Minigame {
	constructor() {
		super( "#au_minigame_eclipse_title", "EclipseContainer" )

		this.type = AU_MINIGAME_ECLIPSE
		this.clickedButtons = []
		this.clickedCount = 0

		this.answer_timer = $.CreatePanel( "Label", this.container, "TimerCooldown" )
		this.answer_timer.text = "00:00"
		this.time = Game.GetGameTime() + 6
		this.bomb_panel = $.CreatePanel( "Panel", this.container, "BombPanel" )

		for ( let i = 0; i < 6; i++ ) {
			let button = $.CreatePanel( "Button", this.bomb_panel, "" )

			button.SetPanelEvent( "onactivate", () => {
				if ( Game.GetGameTime() >= this.time - 1 ) {
					if ( !this.clickedButtons[i] ) {
						this.clickedButtons[i] = true
						this.clickedCount = this.clickedCount + 1

						button.AddClass( "Clicked" )

						if ( this.clickedCount >= 6 ) {
							this.Complete()
						}
					}
				}
			} )
		}
	}
	Update(now) {
		if ( Game.GetGameTime() < this.time ) {
			this.time_preview = parseInt(this.time - Game.GetGameTime())
			this.answer_timer.text = "00:0"+this.time_preview
		}
	}
}