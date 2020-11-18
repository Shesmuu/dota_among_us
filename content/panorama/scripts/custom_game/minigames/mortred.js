class MinigameMortred extends Minigame {
	constructor() {
		super( "#MortredGame", "MortredContainer" )
		this.container.BLoadLayoutSnippet( "MinigameMortred" )
		this.knifes = []
		this.rows = []
		this.rowCount = 7
		this.currentMortredPosY = 0
		this.currentMortredPosX = 0
		this.time = Game.GetGameTime() + 8
		this.nextKnifeTime = Game.GetGameTime() + 0.5
		this.mortred = this.container.FindChildTraverse( "Mortred" )
		this.timeTimer= this.container.FindChildTraverse( "Time" )
		this.timeTimer.text = $.Localize( "#au_minigame_Mortred_score" ) + 0

		this.container.FindChildTraverse( "Up" ).SetPanelEvent( "onactivate", () => this.UpMortred() )
		this.container.FindChildTraverse( "Down" ).SetPanelEvent( "onactivate", () => this.DownMortred() )
		this.container.FindChildTraverse( "Left" ).SetPanelEvent( "onactivate", () => this.LeftMortred() )
		this.container.FindChildTraverse( "Right" ).SetPanelEvent( "onactivate", () => this.RightMortred() )

		const rowsContainer = this.container.FindChildTraverse( "Rows" )

		for ( let i = 0; i < this.rowCount; i++ ) {
			const row = $.CreatePanel( "Panel", rowsContainer, "" )
			row.AddClass( "KnifesRow" )

			this.rows.push( row )
		}

		this.SetMortredPosX( 3 )
		this.SetMortredPosY( 3 )
	}

	UpMortred() {
		if ( this.currentMortredPosY > 0 ) {
			this.SetMortredPosY( this.currentMortredPosY - 1 )
		}
	}

	DownMortred() {
		if ( this.currentMortredPosY < this.rowCount - 1 ) {
			this.SetMortredPosY( this.currentMortredPosY + 1 )
		}
	}

	LeftMortred() {
		if ( this.currentMortredPosX > 0) {
			this.SetMortredPosX( this.currentMortredPosX - 1 )
		}
	}

	RightMortred() {
		if ( this.currentMortredPosX < this.rowCount - 1 ) {
			this.SetMortredPosX( this.currentMortredPosX + 1 )
		}
	}

	SetMortredPosY( y ) {
		this.currentMortredPosY = y
		this.mortred.style.y = y * 50 + "px"
	}

	SetMortredPosX( x ) {
		this.currentMortredPosX = x
		this.mortred.style.x = x * 50 + "px"
	}

	MacroCollision(knife)
	{
		this.knife_x = knife.panel.GetPositionWithinWindow().x
		this.knife_y = knife.panel.GetPositionWithinWindow().y
		this.mortred_x = this.mortred.GetPositionWithinWindow().x
		this.mortred_y = this.mortred.GetPositionWithinWindow().y
		let res = Game.GetScreenWidth()

		let mortred_w = 0
		let mortred_h = 0
		let knife_h = 0
		let knife_w = 0

		if (knife.random == 0 ){
			mortred_w = 0
			mortred_h = 45
			knife_h = 30
			knife_w = 23			
		}
		if (knife.random == 1 ){
			mortred_w = 0
			mortred_h = 45
			knife_h = 30
			knife_w = 23
		}
		if (knife.random == 2 ){
			mortred_w = 30
			mortred_h = 0
			knife_h = 30
			knife_w = 0
		}
		if (knife.random == 3 ){
			mortred_w = 50
			mortred_h = 0
			knife_h = 30
			knife_w = 30
		}

		if (Game.GetScreenWidth() == 640) {
			if (knife.random == 0 ){
				mortred_w = 0
				mortred_h = 23
				knife_h = 15
				knife_w = 12			
			}
			if (knife.random == 1 ){
				mortred_w = 0
				mortred_h = 23
				knife_h = 15
				knife_w = 12
			}
			if (knife.random == 2 ){
				mortred_w = 15
				mortred_h = 0
				knife_h = 15
				knife_w = 0
			}
			if (knife.random == 3 ){
				mortred_w = 25
				mortred_h = 0
				knife_h = 15
				knife_w = 15
			}
		}

		if (Game.GetScreenWidth() == 720) {
			if (knife.random == 0 ){
				mortred_w = 0
				mortred_h = 23
				knife_h = 15
				knife_w = 12			
			}
			if (knife.random == 1 ){
				mortred_w = 0
				mortred_h = 23
				knife_h = 15
				knife_w = 12
			}
			if (knife.random == 2 ){
				mortred_w = 15
				mortred_h = 0
				knife_h = 15
				knife_w = 0
			}
			if (knife.random == 3 ){
				mortred_w = 25
				mortred_h = 0
				knife_h = 15
				knife_w = 15
			}
		}

		var XColl=false;
	  	var YColl=false;
	  	if ((this.knife_x + knife_w >= this.mortred_x ) && (this.knife_x <= this.mortred_x + mortred_w)) XColl = true;
	  	if ((this.knife_y + knife_h >= this.mortred_y) && (this.knife_y <= this.mortred_y + mortred_h)) YColl = true;
	  	if (XColl&YColl){return true;}
		return false;
	}

	Update( now ) {
		if ( now >= this.nextKnifeTime ) {
			const r = RandomInt( 0, this.rows.length - 1 )
			this.knifes.unshift( new MortredKnife( this.container.FindChildTraverse( "Container" ), now, r ) )
			this.nextKnifeTime = now + 0.6
		}
		for ( let i = this.knifes.length - 1; i >= 0; i-- ) {
			const knife = this.knifes[i]
			let destroy = false
			knife.Update( now )
			if ( knife.pos <= 0 ) {
				destroy = true
			}

			if ( this.MacroCollision(knife) ) {
				GameEvents.SendCustomGameEventToServer( "au_minigame_result", {
					failure: true
				} )
				Sounds_.EmitSound( "Minigame.Mortred" )
			}

			if ( destroy ) {
				knife.Destroy()
				this.knifes.splice( i, 1 )
			}
		}
		this.time_preview = parseInt(this.time - Game.GetGameTime())
		this.timeTimer.text = $.Localize( "#au_minigame_mortred_time" ) + " " + this.time_preview

		if ( Game.GetGameTime() >= this.time ) {
			this.Complete( 0.4, "#au_minigame_good_1" )
		}
	}
}

class MortredKnife {
	constructor( parent, now, row ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.AddClass( "Knife" )
		this.row = row
		this.random = RandomInt( 0, 3 )
		if (this.random == 0 ){
			this.panel.style.x = row * 50 + "px"
			this.panel.style.y = -150 + "px"	
			this.panel.style.width = '25px';	
			this.panel.style.height = '50px';	
			this.panel.style.backgroundImage = 'url("file://{images}/custom_game/knife3.png")';		
		}
		if (this.random == 1 ){
			this.panel.style.x = row * 50 + "px"
			this.panel.style.y = 400 + "px"
			this.panel.style.width = '25px';	
			this.panel.style.height = '50px';	
			this.panel.style.backgroundImage = 'url("file://{images}/custom_game/knife4.png")';	
		}
		if (this.random == 2 ){
			this.panel.style.y = row * 50 + "px"
			this.panel.style.x = -50 + "px"
			this.panel.style.width = '50px';	
			this.panel.style.height = '25px';
			this.panel.style.backgroundImage = 'url("file://{images}/custom_game/knife2.png")';		
		}
		if (this.random == 3 ){
			this.panel.style.y = row * 50 + "px"
			this.panel.style.x = 350 + "px"
			this.panel.style.width = '50px';	
			this.panel.style.height = '25px';	
			this.panel.style.backgroundImage = 'url("file://{images}/custom_game/knife.png")';	
		}
		this.creationTime = now
	}

	Update( now ) {
		if (this.random == 0 ){
			let maxPos = 600
			this.pos = maxPos - ( ( now - this.creationTime ) / 3.3 || 0 ) * maxPos
			this.pos = Math.max( this.pos, 0 )
			this.panel.style.y = ( this.pos - 100 ) + "px"
		}
		if (this.random == 1 ){
			let maxPos = 600
			this.pos = maxPos + ( ( now - this.creationTime ) / 4 || 0 ) * maxPos
			this.pos = Math.max( this.pos, 0 )
			this.panel.style.y = ( this.pos - 600 ) + "px"
		}
		if (this.random == 2 ){
			let maxPos = 600
			this.pos = maxPos - ( ( now - this.creationTime ) / 3.3 || 0 ) * maxPos
			this.pos = Math.max( this.pos, 0 )
			this.panel.style.x = ( this.pos - 100 ) + "px"
		}
		if (this.random == 3 ){
			let maxPos = 600
			this.pos = maxPos + ( ( now - this.creationTime ) / 4 || 0 ) * maxPos
			this.pos = Math.max( this.pos, 0 )
			this.panel.style.x = ( this.pos - 600 ) + "px"
		}
	}

	Destroy() {
		this.panel.DeleteAsync( 0 )
	}
}