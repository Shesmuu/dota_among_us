class WispBase {
	constructor( panel ) {
		this.panel = panel
		this.panel.AddClass( "WispBase" ) 
	}

	GetPos() {
		return [this.x, this.y, 0]
	}

	Destroy() {
		this.destroyed = true
		this.panel.AddClass( "Destoyed" )
	}
}

class Wisp extends WispBase {
	constructor( parent, center, angleOffset, panelOffset ) {
		let panel = $.CreatePanel( "Panel", parent, "" )

		super( panel )

		this.panel.AddClass( "Wisp" )
		this.center = center
		this.angleOffset = angleOffset
		this.panelOffset = panelOffset
	}

	SetAngle( angle, radius ) {
		this.x = this.center.x + Math.cos( angle + this.angleOffset ) * radius
		this.y = this.center.y + Math.sin( angle + this.angleOffset ) * radius

		this.SetPos(
			this.x - this.panelOffset,
			this.y - this.panelOffset
		)
	}

	SetPos( x, y ) {
		this.panel.style.position = x + "px " + y + "px 0px"
	}
}

class WispTarget extends WispBase {
	constructor( parent, name, x, y ) {
		let panel = $.CreatePanel( "Image", parent, "" )

		super( panel )

		this.panel.SetImage( "file://{images}/heroes/icons/npc_dota_hero_" + name + ".png" )
		this.panel.AddClass( "WispTarget" )
		this.panel.style.position = ( x - 16 ) + "px " + ( y - 16 ) + "px 0px"
		this.x = x
		this.y = y
		this.name = name
	}
}

class MinigameWisp extends Minigame {
	constructor() {
		super( "#au_minigame_wisp_title", "WispContainer" )

		this.type = AU_MINIGAME_WISP
		this.button = $.CreatePanel( "Button", this.container, "Wisp" )
		this.button.SetPanelEvent( "onactivate", () => {
			this.Clicked()
		} )
		this.size = 600
		this.radius = 40
		this.wisps = []
		this.wispTargets = []
		this.wispCount = 5
		this.wispRemaining = this.wispCount
		this.startTime = Game.GetGameTime()
		this.lastTime = this.startTime
		this.angle = 0

		let center = { x: this.size / 2, y: this.size / 2 }

		for ( var i = 0; i < this.wispCount; i++ ) {
			this.wisps.push( new Wisp(
				this.container,
				center,
				Math.PI * 2 / this.wispCount * i,
				12
			) )
		}

		let targets = [
			{ name: "chaos_knight", x: 300, y: 120 },
			{ name: "doom_bringer", x: 440, y: 200 },
			{ name: "skeleton_king", x: 460, y: 400 },
			{ name: "undying", x: 250, y: 200 },
			{ name: "life_stealer", x: 200, y: 280 }
		]

		for ( let o of targets ) {
			this.wispTargets.push( new WispTarget(
				this.container,
				o.name,
				o.x,
				o.y
			) )
		}
	}

	Clicked() {
		this.clicked = !this.clicked

		this.button.SetHasClass( "Clicked", this.clicked )
	}

	Update( now ) {
		let frameTime = now - this.lastTime
		let circleTime = 5
		let angle = ( ( now - this.startTime ) % circleTime ) / circleTime * Math.PI * 2
		let change = frameTime * 100

		if ( !this.clicked ) {
			change = -change
		}

		let radius = this.radius + change

		radius = Math.min( radius, 225 )
		radius = Math.max( radius, 40 )

		for ( let wisp of this.wisps ) {
			if ( wisp.destroyed ){
				continue
			}

			wisp.SetAngle( angle, radius )

			for ( let target of this.wispTargets ) {
				if ( target.destroyed ) {
					continue
				}

				let d = Game.Length2D( target.GetPos(), wisp.GetPos() )

				if ( d < 28 ) {
					wisp.Destroy()
					target.Destroy()

					Sounds_.EmitSound( "Minigame.Wisp" )

					this.wispRemaining = this.wispRemaining - 1

					if ( this.wispRemaining <= 0 ) {
						this.Complete( 0.95, "#au_minigame_good_1" )

						return
					}
				}
			}
		}

		this.radius = radius
		this.lastTime = now
		this.anime = true
	}
}