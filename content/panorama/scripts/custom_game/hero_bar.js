class HeroBar {
	constructor( parent, id ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.AddClass( "HeroBar" )
		this.nickname = $.CreatePanel( "Label", this.panel, "" )
		this.nickname.AddClass( "HeroBarNickname" )
		this.nickname.text = $.Localize( "#" + Players.GetPlayerSelectedHero( id ) )
		this.id = id
	}

	SetEnabled( bool ) {
		this.panel.visible = bool
	}

	SetDied() {
		this.died = true
		this.SetEnabled( false )
	}

	SetImpostor( bool ) {
		this.nickname.SetHasClass( "Impostor", bool )
	}

	Update() {
		let hero = Players.GetPlayerHeroEntityIndex( this.id )

		if ( hero == -1 || !Entities.IsAlive( hero ) || this.died ) {
			this.SetEnabled( false )
			return
		}

		this.SetEnabled( true )

		let heroPos = Entities.GetAbsOrigin( hero )
		let offset = Entities.GetHealthBarOffset( hero )
		let screenM = Game.GetScreenHeight() / 1080
		let x = ( Game.WorldToScreenX( heroPos[0], heroPos[1], heroPos[2] + offset + 30 ) - 150 ) / screenM
		let y = ( Game.WorldToScreenY( heroPos[0], heroPos[1], heroPos[2] + offset + 30 ) - 7 ) / screenM

		this.panel.style.x = x + "px"
		this.panel.style.y = y + "px"
	}
}

class HeroBarSystem {
	constructor() {
		this.panel = $( "#HeroBarsContainer" )
		this.heroBars = []
		this.SetEnabled( false )

		for ( let id = 0; id < 24; id++ ) {
			if ( Players.IsValidPlayerID( id ) ) {
				this.heroBars[id] = new HeroBar( this.panel, id )
			}
		}
	}

	SetEnabled( bool ) {
		this.enabled = bool
		this.panel.visible = bool
	}

	NetTableImpostors( data ) {
		if ( !data[Players.GetLocalPlayer()] ) {
			for ( let id in this.heroBars ) {
				this.heroBars[id].SetImpostor( false )
			}

			return
		}

		for ( let id in this.heroBars ) {
			this.heroBars[id].SetImpostor( !!data[id] )
		}
	}

	NetTableDied( data ) {
		for ( let id in data ) {
			this.heroBars[id].SetDied( true )
		}
	}

	Update() {
		if ( !this.enabled ) {
			return
		}

		for ( let id in this.heroBars ) {
			this.heroBars[id].Update()
		}
	}
}