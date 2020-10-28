class MinigameBottle extends Minigame {
	constructor( minigameType ) {
		let images = []
		images[AU_MINIGAME_BOTTLE_1] = ["bottle", "bottle_empty", "Bottle.Cork"]
		images[AU_MINIGAME_BOTTLE_2] = ["bottle_empty", "bottle_arcane", "Rune.Arcane"]
		images[AU_MINIGAME_BOTTLE_3] = ["bottle_arcane", "bottle_empty", "Bottle.Cork"]
		images[AU_MINIGAME_BOTTLE_4] = ["bottle_empty", "bottle_invisibility", "Rune.Invis"]
		let image = images[minigameType]

		super( "#au_minigame_bottle_title_" + minigameType, "BottleContainer" )

		this.type = minigameType
		this.image = $.CreatePanel( "Image", this.container, "" )
		this.image.SetImage( "file://{images}/items/" + image[0] + ".png" )
		this.secondImage = "file://{images}/items/" + image[1] + ".png"
		this.sound = image[2]

		this.image.SetPanelEvent( "onactivate", () => {
			this.Clicked()
		} )
	}

	Clicked() {
		if ( !this.clicked ) {
			this.clicked = true

			this.image.SetImage( this.secondImage )

			Game.EmitSound( this.sound )

			this.Complete( 0.7 )
		}
	}
}