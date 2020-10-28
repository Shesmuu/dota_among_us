class MinigameFamiliar extends Minigame {
	constructor() {
		super( "#au_minigame_familiar_title", "FamiliarContainer" )

		this.type = AU_MINIGAME_STONE
		this.button = $.CreatePanel( "Button", this.container, "Familiar" )

		this.button.SetPanelEvent( "onactivate", () => {
			this.Clicked()
		} )
	}

	Clicked() {
		if ( !this.clicked ) {
			Sounds_.EmitSound( "Minigame.Familiar" )

			this.button.AddClass( "Animation" )
			this.completeTime_ = Game.GetGameTime() + 1.2
			this.clicked = true
		}
	}

	Update( now ) {
		if ( now >= this.completeTime_ ) {
			this.Complete( 0.6, "#au_minigame_good_1" )
		}
	}
}