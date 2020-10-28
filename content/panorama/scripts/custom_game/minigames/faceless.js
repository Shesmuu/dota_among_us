class MinigameFaceless extends Minigame {
	constructor() {
		super( "#au_minigame_faceless_title", "FacelessContainer" )

		this.type = AU_MINIGAME_FACELESS
		this.mouseOver = false

		let line = $.CreatePanel( "Panel", this.container, "" )

		this.image = $.CreatePanel( "Image", this.container, "" )
		this.image.SetImage( "file://{images}/heroes/icons/npc_dota_hero_faceless_void.png" )
		this.image.SetPanelEvent( "onmouseover", () => this.MouseOver() )
		this.image.SetPanelEvent( "onmouseout", () => this.MouseOut() )

		let label = $.CreatePanel( "Label", this.container, "" )
		label.text = $.Localize( "#au_minigame_faceless_description" )
	}

	MouseOver() {
		if ( this.failTime || this.completeTime ) {
			return
		}

		this.started = true
		this.startTime = Game.GetGameTime()
	}

	MouseOut() {
		if ( !this.started || this.failTime || this.completeTime ) {
			return
		}

		this.started = false

		this.FailDelay( 1.2, "#au_minigame_failure_1" )
	}

	SetProgress( progress ) {
		let x = 360 * progress

		this.image.style.position = x + "px 0px 0px"
	}

	Update( now ) {
		if ( this.started ) {
			let progress = ( now - this.startTime ) / 7 || 0

			this.SetProgress( progress )

			if ( progress >= 1 ) {
				this.started = false

				this.Complete( 0.9, "#au_minigame_good_1" )
			}
		}

		this.CheckFinish( now )
	}
}