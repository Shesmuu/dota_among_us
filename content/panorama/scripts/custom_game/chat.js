class ChatMessage {
	constructor( parent, data ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.BLoadLayoutSnippet( "ChatMessage" )

		let heroName = Players.GetPlayerSelectedHero( data.PlayerID )
		let heroImage = this.panel.FindChildTraverse( "HeroImage" )
		heroImage.SetImage( "file://{images}/heroes/icons/" + heroName + ".png" )

		if ( data.alive != 1 ) {
			heroImage.AddClass( "Died" )
		}

		if ( data.PlayerID == Players.GetLocalPlayer() ) {
			this.panel.AddClass( "LocalPlayer" )
		}

		let message = this.panel.FindChildTraverse( "Message" )
		let text = data.text

		message.text = data.text
	}

	Delete() {
		this.panel.DeleteAsync( 0 )
	}
}

class Chat {
	constructor() {
		this.panel = $( "#Chat" )
		this.newMessage = $( "#NewMessage" )
		this.newMessage.visible = false
		this.messagesContainer = $( "#MessagesContainer" )
		this.messagesContainer.RemoveAndDeleteChildren()
		this.chatBoard = $( "#ChatBoard" )
		this.entry = $( "#ChatEntry" )
		this.messages = []
		this.enabled = false

		this.entry.SetPanelEvent( "oninputsubmit", () => this.InputSubmit() )
		this.entry.SetPanelEvent( "oncancel", () => this.CloseChat() )

		GameEvents.Subscribe( "au_chat_message", data => this.Message( data ) )
	}

	Message( data ) {
		if ( Game.IsPlayerMuted( data.PlayerID ) ) {
			return
		}

		this.messages.push( new ChatMessage( this.messagesContainer, data ) )

		$.Schedule( 0.1, () => this.messagesContainer.ScrollToBottom() )

		let maxMessages = 150

		if ( this.messages.length > maxMessages ) {
			let deleted = this.messages.splice( 0, this.messages.length - maxMessages )

			for ( let m of deleted ) {
				m.Delete()
			}
		}

		if ( !this.enabled ) {
			this.newMessage.RemoveClass( "Animation" )
			this.newMessage.AddClass( "Animation" )
			this.newMessage.visible = true
		}
	}

	InputSubmit() {
		if ( this.entry.text != "" ) {
			GameEvents.SendCustomGameEventToServer( "au_chat_send", {
				text: this.entry.text
			} )

			this.entry.text = ""
		}
	}

	ToggleMuteList() {
		this.mutePanel.ToggleClass( "Visible" )
	}

	Toggle() {
		if ( this.enabled ) {
			this.CloseChat()
		} else {
			this.OpenChat()
		}
	}

	Clean() {
		let deleted = this.messages.splice( 0, this.messages.length )
		for ( let m of deleted ) {
			m.Delete()
		}
	}

	OpenChat() {
		if ($( "#ChatButton" ).visible == false) { return }
		this.enabled = true
		this.panel.AddClass( "Visible" )
		this.entry.SetFocus()
		this.newMessage.visible = false
	}

	CloseChat() {
		this.enabled = false
		this.panel.RemoveClass( "Visible" )
		$.DispatchEvent( "DropInputFocus", this.entry )
	}
}