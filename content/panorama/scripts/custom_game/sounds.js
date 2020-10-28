class Sounds {
	constructor() {
		this.soundHandlers = {}
	}

	EmitSound( name ) {
		this.StopSound( name )

		let handler = Game.EmitSound( name )
		
		if ( handler ) {
			this.soundHandlers[name] = handler
		}
	}

	StopSound( name ) {
		if ( this.soundHandlers[name] ) {
			Game.StopSound( this.soundHandlers[name] )
			this.soundHandlers[name] = null
		}
	}
}