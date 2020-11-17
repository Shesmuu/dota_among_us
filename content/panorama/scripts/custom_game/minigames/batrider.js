class MinigameBatrider extends Minigame {
	constructor() {
		super( "#BatriderGame", "BatriderContainer" )
		this.type = AU_MINIGAME_BATRIDER
		this.X = 0
		this.Y = 0
		this.trubs = []
		this.start_game = false
		this.bird = $.CreatePanel( "Panel", this.container, "Batrider" )
		this.bird_model =  '<DOTAScenePanel style="width:100px;height:100px;" drawbackground="1" unit="npc_dota_hero_batrider" particleonly="false" />'
		this.finish = $.CreatePanel( "Panel", this.container, "Finish" )
    	$("#Batrider").BCreateChildren(this.bird_model)
		for ( let i = 3; i >= 0; i-- ) {
			var hole = Math.floor(Math.random()*6) + 1;
			for ( let a = 13; a >= 0; a-- ) {
				if (a !== hole && a !== (hole + 1) && a !== (hole + 2) && a !== (hole + 3)) {
					this.truba = $.CreatePanel( "Panel", this.container, "" )
					this.truba.AddClass( "Truba" )
					this.truba.style.position = ( 220 * (i+1) ) + "px " + ( -45*a ) + "px 0px"
					this.trubs.push( this.truba )
				}
			}
		}


		this.container.SetPanelEvent( "onactivate", () => {
			this.Clicked()
		} )
	}

	Clicked() {
		if (!this.start_game) {
			this.start_game = true
		}
		this.FlyTime = Game.GetGameTime() + 0.3
	}

	MacroCollision()
	{
		for ( let i = 38; i >= 0; i-- ) {
			this.truba_x = this.trubs[i].GetPositionWithinWindow().x
			this.truba_y = this.trubs[i].GetPositionWithinWindow().y
			this.bird_x = this.bird.GetPositionWithinWindow().x
			this.bird_y = this.bird.GetPositionWithinWindow().y
		  	var XColl=false;
		  	var YColl=false;
		  	if ((this.truba_x + 45 >= this.bird_x ) && (this.truba_x <= this.bird_x + 45)) XColl = true;
		  	if ((this.truba_y + 45 >= this.bird_y) && (this.truba_y <= this.bird_y + 45)) YColl = true;
		  	if (XColl&YColl){return true;}
		}
		return false;
	}

	Update( now ) {
		if (!this.start_game) {
			return
		}

		if ( now < this.FlyTime ) {
			this.Y = this.Y - 5
			this.X = this.X + 1
			this.bird.style.position = ( this.X ) + "px " + ( this.Y ) + "px 0px"
		} else {
			this.bird.style.position = ( this.X ) + "px " + ( this.Y ) + "px 0px"
			this.Y = this.Y + 5
			this.X = this.X + 1
		}

		if ( this.bird.GetPositionWithinWindow().x >= 1385 ) {
			this.Complete( 0.75, "#au_minigame_good_2" )
		}

		if ( this.Y > 300 || this.MacroCollision() || this.Y < -300 ) {
			GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
				failure: true
			} )
		}

	}
}