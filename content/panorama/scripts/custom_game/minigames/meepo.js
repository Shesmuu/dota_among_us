class MinigameMeepo extends Minigame {
	constructor() {
		super( "#au_minigame_meepo_title", "MeepoContainer" )

		this.type = AU_MINIGAME_MEEPO
		this.container.BLoadLayoutSnippet( "MinigameMeepo" )
		this.score = this.container.FindChildTraverse( "ScoreCount" )
		this.meepo = this.container.FindChildTraverse( "Meepo" )
		this.meepo.SetImage( "file://{images}/heroes/icons/npc_dota_hero_meepo.png" )
		this.meepo.visible = false

		this.needCount = 6
		this.meepoCount = 0
		this.score.text = this.meepoCount

		this.meepo.SetPanelEvent( "onactivate", () => {
			this.MeepoClicked()
		} )

		this.ShowMeepo( Game.GetGameTime() )
	}

	ShowMeepo( now ) {
		let containerSize = 400
		let s = 45
		let x = Math.random() * ( containerSize - s )
		let y = Math.random() * ( containerSize - s )

		this.meepo.style.position = x + "px " + y + "px 0px"
		this.meepo.visible = true
		this.hideTime = now + 0.9
		this.showTime = null
	}

	HideMeepo( now, showTime ) {
		this.meepo.visible = false
		this.hideTime = null

		if ( showTime ) {
			this.showTime = now + 0.7
		} else {
			this.showTime = null
		}
	}

	MeepoClicked() {
		if ( this.finished ) {
			return
		}

		this.meepoCount = this.meepoCount + 1
		this.score.text = this.meepoCount

		Sounds_.EmitSound( "Minigame.Meepo" )

		if ( this.meepoCount >= this.needCount ) {
			this.HideMeepo( false )

			this.Complete( 0.75, "#au_minigame_good_2" )
		} else {
			this.HideMeepo( Game.GetGameTime(), true )
		}
	}

	Update( now ) {
		if ( this.showTime && now >= this.showTime  ) {
			this.ShowMeepo( now )
		} else if ( this.hideTime && now >= this.hideTime  ) {
			this.HideMeepo( now, true )
		} 
	}
}