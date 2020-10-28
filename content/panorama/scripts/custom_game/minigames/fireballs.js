class Fireball {
	constructor( parent, now, event ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.AddClass( "Fireball" )
		this.panel.SetPanelEvent( "onactivate", () => event( this ) )

		this.startY = RandomInt( 50, 450 )
		this.targetY = RandomInt( 50, 450 )
		this.creationTime = now

		this.SetPos( 550, this.startY )
	}

	SetPos( x, y ) {
		this.panel.style.position = ( x - 24 ) + "px " + ( y - 24 ) + "px 0px"
	}

	Update( now ) {
		if ( this.destroyTime && now >= this.destroyTime ) {
			this.Destroy()
			return
		} else if ( this.destroyed || this.stoped ) {
			return
		}

		let perc = ( now - this.creationTime ) / 4 || 0
		let x = 650 - perc * 600 - 50
		let y = this.startY + perc * ( this.targetY - this.startY )

		this.SetPos( x, y )

		if ( perc >= 1 ) {
			this.Destroy()
		}

		return false
	}

	Hide( bool ) {
		this.stoped = bool
		this.destroyTime = Game.GetGameTime() + 2
		this.hidden = true
		this.panel.AddClass( "Hidden" )
	}

	Destroy() {
		this.destroyed = true
		this.panel.DeleteAsync( 0 )
	}
}

class MinigameFireballs extends Minigame {
	constructor() {
		super( "#au_minigame_fireballs_title", "FireballsContainer" )

		this.type = AU_MINIGAME_FIREBALLS
		this.container.BLoadLayoutSnippet( "MinigameFireballs" )
		this.fireballs = this.container.FindChildTraverse( "FireballsContainer" )
		this.score = this.container.FindChildTraverse( "ScoreCount" )
		this.balls = []
		this.targetBalls = 6
		this.ballsKilled = 0
		this.score.text = this.ballsKilled

		this.RandomTime( Game.GetGameTime() )
	}

	RandomTime( now ) {
		this.nextBallTime = now + 0.2 + Math.random() * 1.6
	}

	Clicked( ball ) {
		if ( ball.hidden || ball.destroyed ) {
			return
		}

		ball.Hide( true )

		this.ballsKilled++
		this.score.text = this.ballsKilled

		Sounds_.EmitSound( "Minigame.EarthSpirit" )

		if ( this.ballsKilled >= this.targetBalls ) {
			this.Complete( 0.75, "#au_minigame_good_2" )
		}
	}

	Update( now ) {
		if ( this.finished ) {
			return
		}

		if ( now > this.nextBallTime ) {
			this.balls.push( new Fireball( this.fireballs, now, ball => this.Clicked( ball ) ) )
			this.RandomTime( now )
		}

		for ( let i = this.balls.length - 1; i >= 0; i-- ) {
			let ball = this.balls[i]

			if ( ball.destroyed ) {
				this.balls.splice( i, 1 )
			} else {
				ball.Update( now )
			}
		}
	}
}