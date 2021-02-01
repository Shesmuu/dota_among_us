class MinigameCamera extends Minigame {
	constructor(sabotageActive) {
		super( "", "CameraContainer" )
		this.type = AU_MINIGAME_CAMERA
		this.container.BLoadLayoutSnippet( "MinigameCamera" )
		this.ready = this.container.FindChildTraverse( "CameraError" )
		this.camera = 1
		this.SetSabotage( sabotageActive )
		$("#Minigame").style.backgroundImage = 'url("file://{images}/custom_game/camera.png")';	
		this.container.FindChildTraverse( "LeftArrow" ).SetPanelEvent( "onactivate", () => {
			if ( this.isReady ) {
				this.camera = this.camera - 1
				if (this.camera < 1) {
					this.camera = 4
				}
				GameEvents.SendCustomGameEventToServer( "au_setcamera", {count : String(this.camera)} )
			}
		} )
		this.container.FindChildTraverse( "RightArrow" ).SetPanelEvent( "onactivate", () => {
			if ( this.isReady ) {
				this.camera = this.camera + 1
				if (this.camera > 4) {
					this.camera = 1
				}
				GameEvents.SendCustomGameEventToServer( "au_setcamera", {count : String(this.camera)} )
			}
		} )
		if ( this.isReady ) {
			GameEvents.SendCustomGameEventToServer( "au_setcamera", {count : String(this.camera)} )
		}
	}

	SetSabotage( bool ) {
		this.isSabotage = bool

		if ( !bool ) {
			this.isReady = true
			this.ready.visible = false
		} else {
			this.isReady = false
			this.ready.visible = true
		}
	}

	Update( now ) {
		GameEvents.SendCustomGameEventToServer( "camera_start", {team : Players.GetTeam( Game.GetLocalPlayerID() ), count : String(this.camera), id : Game.GetLocalPlayerID()} );   
	}
}