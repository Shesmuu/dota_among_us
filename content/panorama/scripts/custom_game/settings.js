class Setting {
	constructor( parent, data ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.AddClass( "Setting" )
		this.options = []

		let title = $.CreatePanel( "Label", this.panel, "" )
		title.text = $.Localize( "au_settings_" + data.name )

		let buttons = $.CreatePanel( "Panel", this.panel, "" )
		buttons.AddClass( "Buttons" )

		for ( let i in data.options ) {
			let button = $.CreatePanel( "Button", buttons, "" )
			let label = $.CreatePanel( "Label", button, "" )
			label.text = $.Localize( data.options[i] )

			this.options[Number( i )] = {
				name: data.options[i],
				button: button,
				label: label
			}

			button.SetPanelEvent( "onactivate", () => {
				GameEvents.SendCustomGameEventToServer( "au_settings_vote", {
					name: data.name,
					option: Number( i )
				} )
			} )
		}

		let desc = $.CreatePanel( "Label", this.panel, "" )
		desc.AddClass( "Description" )
		desc.text = $.Localize( "au_settings_" + data.name + "_description" )
	}

	SetVoted( v ) {
		for ( let i in this.options ) {
			this.options[i].button.SetHasClass( "Voted", i == v )
			this.options[i].button.SetHasClass( "Unselectable", i != v )
		}
	}

	SetFinalVoted( v ) {
		for ( let i in this.options ) {
			this.options[i].button.SetHasClass( "FinalVoted", i == v )
		}
	}

	SetVoteCount( a ) {
		for ( let i in a ) {
			let v = a[i]
			let o = this.options[i]

			if ( v > 0 ) {
				o.label.text = $.Localize( o.name ) + "(" + v + ")"
			}
		}
	}
}

class Settings {
	constructor() {
		this.panel = $( "#Settings" )
		this.countdown = this.panel.FindChildTraverse( "Countdown" )
		this.customContainer = this.panel.FindChildTraverse( "CustomSettingsContainer" )
		this.settings = {}

		SubscribeNetTable( "settings", "available", data => this.NetTableAvailable( data ) )
		SubscribeNetTable( "settings", "votes", data => this.NetTableVotes( data ) )
		SubscribeNetTable( "settings", "players", data => this.NetTablePlayers( data ) )
		SubscribeNetTable( "settings", "state", data => this.NetTableState( data ) )
		SubscribeNetTable( "settings", "voted", data => this.NetTableVoted( data ) )
	}

	NetTableAvailable( data ) {
		this.customContainer.RemoveAndDeleteChildren()

		for ( let i in data.custom ) {
			let v = data.custom[i]

			this.settings[v.name] = new Setting( this.customContainer, v )
		}
	}

	NetTableVotes( data ) {
		for ( let name in data ) {
			this.settings[name].SetVoteCount( data[name] )
		}
	}

	NetTablePlayers( data ) {
		let o = data[Players.GetLocalPlayer()]

		for ( let name in o ) {
			this.settings[name].SetVoted( o[name] )
		}
	}

	NetTableState( data ) {
		this.endTime = data.end_time

		if ( data.ended == 1 ) {
			this.ended = true
			this.panel.visible = false
		}
	}

	NetTableVoted( data ) {
		for ( let name in data ) {
			this.settings[name].SetFinalVoted( data[name] )
		}
	}

	Update( now ) {
		if ( this.ended || !this.endTime ) {
			return
		}

		let remaining = Math.max( this.endTime - Game.GetGameTime(), 0 )

		this.countdown.text = Math.abs( remaining ).toFixed( 0 )
	}
}