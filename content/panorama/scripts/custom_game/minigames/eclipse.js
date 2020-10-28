class MinigameEclipse extends Minigame {
	constructor() {
		super( "#au_minigame_eclipse_title", "EclipseContainer" )

		this.type = AU_MINIGAME_ECLIPSE
		this.clickedButtons = []
		this.clickedCount = 0

		for ( let i = 0; i < 6; i++ ) {
			let button = $.CreatePanel( "Button", this.container, "" )

			button.SetPanelEvent( "onactivate", () => {
				if ( !this.clickedButtons[i] ) {
					this.clickedButtons[i] = true
					this.clickedCount = this.clickedCount + 1

					button.AddClass( "Clicked" )

					if ( this.clickedCount >= 6 ) {
						this.Complete()
					}
				}
			} )
		}
	}
}