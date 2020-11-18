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
				if (a !== hole && a !== (hole + 1) && a !== (hole + 2) && a !== (hole + 3) && a !== (hole + 4) )  {
					this.truba = $.CreatePanel( "Panel", this.container, "" )
					this.truba.AddClass( "Truba" )
					this.truba.style.position = ( 22 * (i+1) ) + "% " + ( -7.15*a ) + "% 0px"
					this.trubs.push( this.truba )
				}
			}
		}
		this.lastTime = Game.GetGameTime()
		Sounds_.EmitSound( "Minigame.BatriderFly" )

		this.container.SetPanelEvent( "onactivate", () => {
			this.Clicked()
		} )
	}

	Clicked() {
		if (!this.start_game) {
			this.start_game = true
		}
		Sounds_.EmitSound( "Minigame.BatriderWings" )
		this.FlyTime = Game.GetGameTime() + 0.3
	}

	MacroCollision()
	{
		for ( let i = 35; i >= 0; i-- ) {
			this.truba_x = this.trubs[i].GetPositionWithinWindow().x
			this.truba_y = this.trubs[i].GetPositionWithinWindow().y
			this.bird_x = this.bird.GetPositionWithinWindow().x
			this.bird_y = this.bird.GetPositionWithinWindow().y
			let res = Game.GetScreenWidth()
			let check_w = 45

			if (Game.GetScreenWidth() == 640) {
				check_w = 22.5
			}

			if (Game.GetScreenWidth() == 720) {
				check_w = 22.5
			}

		  	var XColl=false;
		  	var YColl=false;
		  	if ((this.truba_x + check_w >= this.bird_x ) && (this.truba_x <= this.bird_x + check_w)) XColl = true;
		  	if ((this.truba_y + check_w >= this.bird_y) && (this.truba_y <= this.bird_y + check_w)) YColl = true;
		  	if (XColl&YColl){return true;}
		}
		return false;
	}

	Update( now ) {

		let frameTime = now - this.lastTime
		this.lastTime = now

		if (!this.start_game) {
			return
		}

		if ( this.lastTime < this.FlyTime ) {
			this.Y = this.Y - 45 * frameTime
			this.X = this.X + 10 * frameTime
			this.bird.style.position = ( this.X ) + "% " + ( this.Y ) + "% 0px"
		} else {
			this.bird.style.position = ( this.X ) + "% " + ( this.Y ) + "% 0px"
			this.Y = this.Y + 45 * frameTime
			this.X = this.X + 10 * frameTime
		}

		if ( this.X >= 91 ) {
			this.Complete( 0.75, "#au_minigame_good_2" )
		}

		if ( this.Y > 50 || this.MacroCollision() || this.Y < -50 ) {
			GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
				failure: true
			} )
		}

	}
}