class MinigameXMark extends Minigame {
	constructor() {
		let types = [
			{ title: 1, startPos: { x: 60, y: 350 }, targetPos: { x: 240, y: -20 } },
			{ title: 2, startPos: { x: 400, y: 350 }, targetPos: { x: -50, y: 220 } },
			{ title: 3, startPos: { x: 250, y: 450 }, targetPos: { x: 100, y: -50 } },
			{ title: 4, startPos: { x: 350, y: 350 }, targetPos: { x: -40, y: -40 } }
		]
		let r = RandomInt( 0, types.length - 1 )
		let type = types[r]

		super( "#au_minigame_x_mark_title", "XMarkContainer" )

		this.type = AU_MINIGAME_X_MARK
		this.container.BLoadLayoutSnippet( "MinigameXMark" )
		this.container.SetPanelEvent( "onmouseout", () => this.ContainerOut() )
		this.line = this.container.FindChildTraverse( "XMarkLine" )
		this.mark = this.container.FindChildTraverse( "XMark" )
		this.button = this.container.FindChildTraverse( "XMarkButton" )
		this.button.SetPanelEvent( "onmouseover", () => this.markOver = true )
		this.button.SetPanelEvent( "onmouseout", () => this.markOver = false )
		this.target = this.container.FindChildTraverse( "Target" )
		this.target.SetPanelEvent( "onmouseover", () => this.targetOver = true )
		this.target.SetPanelEvent( "onmouseout", () => this.targetOver = false )

		this.startPos = type.startPos

		let sPosX = this.startPos.x
		let sPosY = this.startPos.y
		let tPos = type.targetPos

		this.SetPos( sPosX, sPosY )

		this.line.style.position = sPosX + "px " + ( sPosY - 4 ) + "px 0px"
		this.target.style.position = tPos.x + "px " + tPos.y + "px 0px"
	}

	ContainerOut() {
		if ( this.started ) {
			this.Fail()
		}
	}

	GetAngle( p1, p2 ) {
		let v1 = [1, 0, 0]
		let v2 = Game.Normalized( [p2[0] - p1[0], p2[1] - p1[1], 0] )
		let a = v1[0] * v2[0] + v1[1] * v2[1]

		return Math.acos( a )
	}

	SetPos( x, y ) {
		let pos = ( x - 32 ) + "px " + ( y - 32 ) + "px 0px"

		this.button.style.position = pos
		this.mark.style.position = pos
	}

	Update( now ) {
		if ( !this.started && GameUI.IsMouseDown( 0 ) && this.markOver ) {
			this.started = true
		} else if ( this.started && !GameUI.IsMouseDown( 0 ) ) {
			this.started = false

			if ( this.targetOver ) {
				this.Complete( 0.27 )
			}
		}

		if ( this.started ) {
			let containerPos = this.container.GetPositionWithinWindow()
			let cursorPos = GameUI.GetCursorPosition()
			let x = cursorPos[0] - containerPos.x
			let y = cursorPos[1] - containerPos.y

			this.SetPos( x, y )

			let p1 = [this.startPos.x, this.startPos.y, 0]
			let p2 = [x, y, 0]
			let lineWidth = Game.Length2D( p1, p2 )
			let cx = ( this.startPos.x + x ) / 2
			let cy = ( this.startPos.y + y ) / 2

			let deg = this.GetAngle( p1, p2 )
			let perc = 1 - Math.cos( deg )

			this.line.style.position = ( this.startPos.x - lineWidth / 2 * perc ) + "px " + cy + "px 0px"
			this.line.style.width = lineWidth + "px"

			if ( y < this.startPos.y ) {
				deg = -deg
			}

			this.line.style.transform = "rotateZ( " + ( deg / Math.PI * 180 ) + "deg )" 
		}
	}

	Destroy() {
		this.container.SetPanelEvent( "onmouseout", () => false )

		super.Destroy()
	}
}