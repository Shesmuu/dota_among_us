class MinigameOxygen extends Minigame {
	constructor() {
		super( "#au_minigame_oxygen_title", "OxygenContainer" )

		this.type = AU_MINIGAME_OXYGEN
		this.container.BLoadLayoutSnippet( "MinigameOxygen" )
		this.entry = this.container.FindChildTraverse( "Entry" )
		this.symbolCount = 6
		this.code = ""
		this.entryCode = ""

		let codePanel = this.container.FindChildTraverse( "CodeText" )

		for ( let i = 0; i < this.symbolCount; i++ ) {
			let r = RandomInt( 1, 9 )

			this.code = this.code + r
		}

		codePanel.text = this.code

		let buttons = this.container.FindChildTraverse( "Buttons" )
		let row = null

		for ( let i = 0; i < 9; i++ ) {
			if ( i % 3 == 0 ) {
				row = $.CreatePanel( "Panel", buttons, "" )
				row.AddClass( "Row" )
			}

			let button = $.CreatePanel( "Label", row, "" )
			button.text = i + 1
			button.SetPanelEvent( "onactivate", () => {
				this.Pressed( i + 1 )
			} )
		}
	}

	Pressed( num ) {
		if ( this.entryCode.length >= this.symbolCount ) {
			return
		}

		this.entryCode = this.entryCode + num
		this.entry.text = this.entryCode

		if ( this.entryCode.length >= this.symbolCount ) {
			if ( this.entryCode == this.code ) {
				this.Complete( 0.4, "#au_minigame_good_1" )
			} else {
				this.FailDelay( 1.3, "#au_minigame_failure_1" )
			}
		}
	}
}