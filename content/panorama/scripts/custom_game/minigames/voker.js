class VokerSphere {
	constructor( parent, now ) {
		let spheres = [ "quas", "wex", "exort" ]

		this.name = spheres[Math.floor( Math.random() * 4 )]
		this.panel = $.CreatePanel( "Image", parent, "" )
		this.panel.SetImage( "file://{images}/spellicons/invoker_" + this.name + ".png" )
		this.creationTime = now
	}

	Update( now ) {
		if ( this.destroyed ) {
			return
		} else if ( this.destroyTime && now >= this.destroyTime ) {
			this.Destroy()

			return
		} else if ( this.stoped ) {
			return
		}

		let maxPos = 550
		let fullTime = 3

		this.pos = maxPos - ( ( now - this.creationTime ) / 2.4 || 0 ) * maxPos
		this.pos = Math.max( this.pos, -50 )
		this.panel.style.position = ( this.pos - 24 ) + "px 0px 0px"
	}

	Hide( stoped ) {
		this.stoped = stoped
		this.destroyTime = Game.GetGameTime() + 3
		this.hidden = true
		this.panel.AddClass( "Hidden" )
	}

	Destroy() {
		this.destroyed = true
		this.panel.DeleteAsync( 0 )
	}
}

class MinigameVoker extends Minigame {
	constructor() {
		super( "#au_minigame_voker_title", "MinigameVoker" )

		this.type = AU_MINIGAME_VOKER
		this.spheres = []
		this.container.BLoadLayoutSnippet( "MinigameVoker" )
		this.spheresLine = this.container.FindChildTraverse( "SpheresLine" )
		this.score = this.container.FindChildTraverse( "ScoreCount" )

		this.container.FindChildTraverse( "Quas" ).SetPanelEvent( "onactivate", () => this.CheckSphere( "quas" ) )
		this.container.FindChildTraverse( "Wex" ).SetPanelEvent( "onactivate", () => this.CheckSphere( "wex" ) )
		this.container.FindChildTraverse( "Exort" ).SetPanelEvent( "onactivate", () => this.CheckSphere( "exort" ) )

		this.nextSphereTime = Game.GetGameTime()
		this.streak = 0
		this.score.text = this.streak
	}

	CheckSphere( name ) {
		if ( this.finished ) {
			return
		}

		for ( let i = this.spheres.length - 1; i >= 0; i-- ) {
			let sphere = this.spheres[i]

			if (
				!sphere.destroyed &&
				!sphere.hidden &&
				sphere.name == name &&
				Math.abs( sphere.pos - 250 ) < 24
			) {
				sphere.Hide( true )

				Game.EmitSound( "Minigame.Invoke" )

				this.streak = this.streak + 1
				this.score.text = this.streak

				if ( this.streak >= 5 ) {
					this.Complete( 0.4, "#au_minigame_good_1" )

					return
				}
			}
		}
	}

	Update( now ) {
		if ( !this.finished && now >= this.nextSphereTime ) {
			this.spheres.unshift( new VokerSphere( this.spheresLine, now ) )

			this.nextSphereTime = now + 0.6 + Math.random() * 0.9
		}

		for ( let i = this.spheres.length - 1; i >= 0; i-- ) {
			let sphere = this.spheres[i]

			if ( sphere.destroyed ) {
				this.spheres.splice( i, 1 )
			} else if ( !sphere.destroyed ) {
				sphere.Update( now )

				if ( !sphere.hidden && sphere.pos < 250 - 20 ) {
					sphere.Hide( false )
				}
			}
		}
	}
}