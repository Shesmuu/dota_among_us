class AlchemistGold {
	constructor( parent, now, row ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.AddClass( "Gold" )
		this.creationTime = now
		this.row = row
	}

	Update( now ) {
		let maxPos = 500

		this.pos = maxPos - ( ( now - this.creationTime ) / 3.3 || 0 ) * maxPos
		this.pos = Math.max( this.pos, 0 )
		this.panel.style.position = ( this.pos - 20 ) + "px 0px 0px"
	}

	Destroy() {
		this.panel.DeleteAsync( 0 )
	}
}

class MinigameAlchemist extends Minigame {
	constructor() {
		super( "#au_minigame_alchemist_title", "AlchemistContainer" )

		this.container.BLoadLayoutSnippet( "MinigameAlchemist" )
		this.golds = []
		this.rows = []
		this.rowCount = 5
		this.currentAlchPos = 0
		this.score = 0
		this.nextGoldTime = Game.GetGameTime()
		this.alchemist = this.container.FindChildTraverse( "Alchemist" )
		this.scoreCount = this.container.FindChildTraverse( "ScoreCount" )
		this.scoreCount.text = $.Localize( "#au_minigame_alchemist_score" ) + 0

		this.container.FindChildTraverse( "Up" ).SetPanelEvent( "onactivate", () => this.UpAlchemist() )
		this.container.FindChildTraverse( "Down" ).SetPanelEvent( "onactivate", () => this.DownAlchemist() )

		const rowsContainer = this.container.FindChildTraverse( "Rows" )

		for ( let i = 0; i < this.rowCount; i++ ) {
			const row = $.CreatePanel( "Panel", rowsContainer, "" )
			row.AddClass( "GoldRow" )

			this.rows.push( row )
		}

		this.SetAlchemistPos( 2 )
	}

	UpAlchemist() {
		if ( this.currentAlchPos > 0 ) {
			this.SetAlchemistPos( this.currentAlchPos - 1 )
		}
	}

	DownAlchemist() {
		if ( this.currentAlchPos < this.rowCount - 1 ) {
			this.SetAlchemistPos( this.currentAlchPos + 1 )
		}
	}

	SetAlchemistPos( y ) {
		this.currentAlchPos = y
		this.alchemist.style.y = y * 50 + "px"
	}

	Update( now ) {
		if ( !this.finished && now >= this.nextGoldTime ) {
			const r = RandomInt( 0, this.rows.length - 1 )

			this.golds.unshift( new AlchemistGold( this.rows[r], now, r ) )

			this.nextGoldTime = now + 0.6 + Math.random() * 0.9
		}

		for ( let i = this.golds.length - 1; i >= 0; i-- ) {
			const gold = this.golds[i]
			let destroy = false

			gold.Update( now )

			if ( gold.pos > 50 ) {
				continue
			}

			if ( gold.pos <= 50 && gold.row == this.currentAlchPos ) {
				destroy = true

				this.score = this.score + 1

				this.scoreCount.text = $.Localize( "#au_minigame_alchemist_score" ) + this.score
				Sounds_.EmitSound( "Minigame.Alchemist" )

				if ( this.score >= 7 ) {
					this.Complete( 0.4, "#au_minigame_good_1" )
				}
			}

			if ( gold.pos <= 0 ) {
				destroy = true
			}

			if ( destroy ) {
				gold.Destroy()
				this.golds.splice( i, 1 )
			}
		}
	}
}