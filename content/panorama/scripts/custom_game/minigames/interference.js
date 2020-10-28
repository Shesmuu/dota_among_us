class MinigameInterference extends Minigame {
	constructor() {
		super( "#au_minigame_interference_title", "InterferenceContainer" )

		this.type = AU_MINIGAME_INTERFERENCE
		this.button = $.CreatePanel( "Label", this.container, "" )
		this.button.AddClass( "Button" )
		this.button.text = $.Localize( "#au_minigame_interference_reboot" )

		this.button.SetPanelEvent( "onactivate", () => {
			this.Start()
		} )
	}

	Start() {
		this.button.visible = false
		this.started = true

		this.percentage = $.CreatePanel( "Label", this.container, "" )
		this.percentage.AddClass( "Percentage" )
		this.percentage.text = "0%"

		this.progressContainer = $.CreatePanel( "Panel", this.container, "" )
		this.progressContainer.AddClass( "ProgressContainer" )

		this.progressBar = $.CreatePanel( "Panel", this.progressContainer, "" )
		this.progressBar.AddClass( "ProgressBar" )

		this.startTime = Game.GetGameTime()
	}

	SetProgress( progress ) {
		let x = this.progressContainer.actuallayoutwidth * progress

		this.percentage.text = Math.min( Math.floor( progress * 100 ), 100 ) + "%"
		this.progressBar.style.width = x + "px"
	}

	Update( now ) {
		if ( this.startTime ) {
			let progress = ( now - this.startTime ) / 7 || 0

			this.SetProgress( progress )

			if ( progress >= 1 ) {
				this.startTime = null

				this.Complete( 0.8 )
			}
		}
	}
}