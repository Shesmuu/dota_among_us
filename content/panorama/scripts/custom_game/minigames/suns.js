class MinigameSuns extends Minigame {
	constructor() {
		super( "au_minigame_suns_title", "SunsContainer" )

		this.type = AU_MINIGAME_SUNS
		this.images = []
		this.sunCount = 3
		this.imageCount = 16
		this.hiddenImage = "file://{images}/spellicons/empty.png"
		this.sunImage = "file://{images}/spellicons/phoenix_supernova.png"
		this.eclipseImage = "file://{images}/spellicons/luna_eclipse.png"

		let row = null

		for ( let i = 0; i < this.imageCount; i++ ) {
			if ( i % 4 == 0 ) {
				row = $.CreatePanel( "Panel", this.container, "" )
				row.AddClass( "Row" )
			}

			let image = $.CreatePanel( "Image", row, "" ) 
			image.AddClass( "SunsImage" )
			image.SetImage( this.hiddenImage )

			image.SetPanelEvent( "onactivate", () => {
				this.ImageClicked( i )
			} )
 
			this.images.push( image )
		}

		this.Start()
	}

	Start() {
		this.listening = false
		this.groupShowNow = 0
		this.sunsFound = 0
		this.sunImages = []
		this.clickedImages = []
		this.groups = []

		let groupCandidates = []
		let sunCandidates = []
		let groupCount = 3

		for ( let i = 0; i < this.imageCount; i++ ) { groupCandidates.push( i ) }
		for ( let i = 0; i < this.imageCount; i++ ) { sunCandidates.push( i ) }

		for ( let i = 0; i < this.sunCount; i++ ) {
			let r = RandomInt( 0, sunCandidates.length - 1 )
			let index = sunCandidates.splice( r, 1 )[0]

			this.sunImages[index] = true
		}

		for ( let i = 0; i < groupCount - 1; i++ ) {
			let max = this.imageCount / groupCount
			let group = []

			for ( let i = 0; i < max; i++ ) {
				let r = RandomInt( 0, groupCandidates.length - 1 )
				let index = groupCandidates.splice( r, 1 )[0]

				group.push( index )
			}

			this.groups.push( group )
		}

		this.groups.push( groupCandidates )

		this.ShowNextGroup( Game.GetGameTime() )
	}

	ShowNextGroup( now ) {
		let group = this.groups[this.groupShowNow]

		if ( !group ) {
			this.listening = true
			this.showTime = null
			this.hideTime = null

			return
		}

		for ( let index of group ) {
			this.ShowImage( index )
		}


		this.groupShowNow = this.groupShowNow + 1

		this.showTime = now + 2
		this.hideTime = now + 1
	}

	HideAll() {
		if ( !this.groups[this.groupShowNow] ) {
			this.listening = true
			this.showTime = null
			this.hideTime = null
		}

		for ( let image of this.images ) {
			image.SetImage( this.hiddenImage )
		}
	}

	ImageClicked( index ) {
		if ( !this.listening ) {
			return
		}

		this.ShowImage( index )

		if ( !this.sunImages[index] ) {
			this.listening = false

			this.ShowMessage( "#au_minigame_failure_2" )
			this.SetMessageRed( true )

			this.failTime = Game.GetGameTime() + 2
		} else if ( !this.clickedImages[index] ) {
			this.sunsFound = this.sunsFound + 1

			this.clickedImages[index] = true

			if ( this.sunsFound >= this.sunCount ) {
				this.listening = false

				this.Complete( 2, "#au_minigame_good_2" )
			}
		}
	}

	ShowImage( index ) {
		let image = this.images[index]

		if ( this.sunImages[index] ) {
			image.SetImage( this.sunImage )
		} else {
			image.SetImage( this.eclipseImage )
		}
	}

	Update() {
		let now = Game.GetGameTime()

		if ( this.showTime && now >= this.showTime ) {
			this.ShowNextGroup( now )
		} else if ( this.hideTime && now >= this.hideTime ) {
			this.HideAll()
		}

		if ( this.completeTime && now >= this.completeTime ) {
			this.completeTime = null

			GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
				completed: true
			} )
		} else if ( this.failTime && now >= this.failTime ) {
			this.failTime = null

			GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
				failure: true
			} )
		}
	}
}