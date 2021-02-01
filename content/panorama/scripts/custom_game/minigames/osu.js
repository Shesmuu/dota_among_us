class MinigameOsu extends Minigame {
	constructor() {
		super( "#OsuGame", "OsuContainer" )
		this.type = AU_MINIGAME_OSU
		this.circles = []
		this.delay = Game.GetGameTime() + 0.8
		let Circles = [
			{ CircleRadius: 150, ClickRadius: { max: 150, min: 112, }},
			{ CircleRadius: 190, ClickRadius:  { max: 190,  min:  152, } },
			{ CircleRadius: 225, ClickRadius: { max: 225, min: 184, }}
		]
		let positions = 
		[
			[ [150,0], [-150,200], [-150, -200] ],
			[ [-150,300], [125, 100], [-150, -300] ],
			[ [100,300], [100,-310], [-200, -300] ],
			[ [200,-300], [0,0], [-200, 301] ],
			[ [-200,300], [150, -300], [0, 0] ]

		]
		let position = positions[RandomInt( 0, 4)]
		for ( let i = 2; i >= 0; i-- ) {
			let random = RandomInt( 0, Circles.length - 1 )
			let type_circle = Circles[random]
			let radius_circle = type_circle.CircleRadius
			let radius_circle_min = type_circle.ClickRadius.min
			let radius_circle_max = type_circle.ClickRadius.max
			this.circles.push( new OsuCircle( this.container, circle => this.Clicked( circle ), this.circles.length, radius_circle, radius_circle_min, radius_circle_max, position ) )
			Circles.splice(random, 1);
		}
		this.current_circle = 0
	}

	Clicked( circle ) {
		if ( circle.hidden ) {
			return
		}
		$.Msg(circle.red_radius)
		if (circle.red_radius <= circle.radius_circle_max+2 && circle.red_radius > circle.radius_circle_min)
		{
			circle.Hide( true )
			if (this.current_circle < 2) {
				this.current_circle = this.current_circle + 1
				this.circles[this.current_circle].lastTime = Game.GetGameTime();
				Sounds_.EmitSound( "Minigame.Coil" )
			} else {
				this.Complete( 0.75, "#au_minigame_good_2" )
			}
		} else {
			GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
				failure: true
			} )
		}
	}

	Update( now ) {
		if (Game.GetGameTime() <= this.delay) { this.circles[this.current_circle].lastTime = Game.GetGameTime(); return }
		this.circles[this.current_circle].Update( now, this.container )
	}
}

class OsuCircle {
	constructor( parent, event, icon, radius_circle, radius_circle_min, radius_circle_max, positions ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.AddClass( "Circle" )
		this.panel.SetPanelEvent( "onactivate", () => event( this ) )
		this.startY = positions[icon][0]
		this.startX = positions[icon][1]
		this.startRadius = radius_circle
		this.radius_circle_min = radius_circle_min
		this.radius_circle_max = radius_circle_max
		this.red_radius = this.startRadius * 2
		this.panel.style.width = (this.startRadius) + "px"
		this.panel.style.height = (this.startRadius) + "px"
		this.panel.style.position = ( this.startX ) + "px " + ( this.startY  ) + "px 0px"
		this.panel.style.width = (this.startRadius) + "px"
		this.panel.style.zIndex = (icon * -1)
		let icons = ["file://{images}/spellicons/nevermore_shadowraze1.png", "file://{images}/spellicons/nevermore_shadowraze2.png", "file://{images}/spellicons/nevermore_shadowraze3.png"];
		let image = $.CreatePanel( "Image", this.panel, "" ) 
		image.AddClass( "CircleAbility" )
		image.SetImage( icons[icon] )

	}

	Update( now, parent ) {
		let frameTime = now - this.lastTime
		this.lastTime = now

		if ( this.hidden ) {
			return
		}

		if (!this.panel_check) {
			this.panel_check = $.CreatePanel( "Panel", parent, "" )
			this.panel_check.AddClass( "CircleCheck" )
			this.panel_check.style.width = (this.red_radius) + "px"
			this.panel_check.style.height = (this.red_radius) + "px"
			this.panel_check.style.position = ( this.startX ) + "px " + ( this.startY ) + "px 0px"
		}

		if (this.red_radius >= this.radius_circle_min  )
		{
			this.panel_check.style.width = (this.red_radius) + "px"
			this.panel_check.style.height = (this.red_radius) + "px"
			this.red_radius = this.red_radius - 200 * frameTime
		} else {
			GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
				failure: true
			} )
		}

		return false
	}

	Hide( bool ) {
		this.hidden = true
		this.panel.AddClass( "Hidden" )
		this.panel_check.AddClass( "Hidden" )
	}
}