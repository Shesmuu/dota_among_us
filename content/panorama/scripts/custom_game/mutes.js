AU_REPORT_REASON_TOXIC = 0
AU_REPORT_REASON_PARTY = 1
AU_REPORT_REASON_CHEATS = 2

class MutesPlayer {
	constructor( id, parent ) {
		const colors = []
		colors[0] = [255, 255, 0]
		colors[1] = [0, 255, 255]
		colors[2] = [255, 0, 255]
		colors[3] = [255, 0, 0]
		colors[4] = [0, 255, 0]
		colors[5] = [0, 0, 255]
		colors[6] = [111, 255, 0]
		colors[7] = [0, 255, 111]
		colors[8] = [111, 0, 255]
		colors[9] = [0, 111, 255]
		const c = colors[id]

		this.id = id
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.BLoadLayoutSnippet( "MutesPlayerRow" )

		this.panel.FindChildTraverse( "HeroImage" ).heroname = Players.GetPlayerSelectedHero( id )
		this.panel.FindChildTraverse( "Color" ).style["background-color"] = "rgb( " + c[0] + ", " + c[1] + ", " + c[2] + " )"
		this.button = this.panel.FindChildTraverse( "Mute" )
		this.button.SetPanelEvent( "onactivate", () => {
			this.TogglePermanentMute()
		} )

		this.reportButtons = this.panel.FindChildTraverse( "ReportButtons" )

		this.ReportButton( AU_REPORT_REASON_TOXIC, "toxic", this.reportButtons )
		this.ReportButton( AU_REPORT_REASON_CHEATS, "cheater",this.reportButtons )
		this.ReportButton( AU_REPORT_REASON_PARTY, "party", this.reportButtons )
		
		this.SetMute( false )
		this.SetPermanentMute( false )
	}

	SetMute( b ) {
		this.mute = b

		this.Update()
	}

	TogglePermanentMute() {
		this.SetPermanentMute( !this.permanentMute )
	}

	SetPermanentMute( b ) {
		this.permanentMute = b

		this.button.SetHasClass( "Muted", b )

		this.Update()
	}

	ReportButton( reason, name, parent ) {
		let button = $.CreatePanel( "Image", parent, "" )
		button.SetImage( "file://{images}/custom_game/report_button_" + name + ".png" )
		button.SetPanelEvent( "onactivate", () => {
			GameEvents.SendCustomGameEventToServer( "au_report_player", {
				player: this.id,
				reason, reason
			} )
		} )
		button.SetPanelEvent( "onmouseover", () => {
			$.DispatchEvent( "UIShowTextTooltip", button, $.Localize( "au_report_description_" + name ) )
		} )
		button.SetPanelEvent( "onmouseout", () => {
			$.DispatchEvent( "UIHideTextTooltip", button )
		} )
	}

	SetReportButtons( b ) {
		this.reportButtons.visible = b
	}

	Update() {
		Game.SetPlayerMuted( this.id, this.permanentMute || this.mute )
	}
}

class Mutes {
	constructor() {
		this.panel = $( "#Mutes" )
		this.reportsRemaining = $( "#ReportsRemaining" )
		this.muteList = this.panel.FindChildTraverse( "MuteList" )
		this.muteList.RemoveAndDeleteChildren()
		this.players = []
		this.muteButtons = []
		this.permanentMutes = []
		this.mutes = []
		this.banned = false

		this.Update()

		UnmuteAll()
	}

	Toggle() {
		this.panel.ToggleClass( "Visible" )
	}

	SetMute( id, b ) {
		this.mutes[id] = b

		this.UpdateMute( id )
	}

	NetTableState( data ) {

	}

	NetTableDied( data ) {
		for ( let id in this.players ) {
			if ( localDied ) {
				this.players[id].SetMute( false )
			} else if ( data[id] == 1 ) {
				this.players[id].SetMute( true )
			}
		}
	}

	NetTablePlayer( data ) {
		this.banned = data.ban > 0

		$( "#Banned" ).visible = this.banned
		$( "#Unbanned" ).visible = !this.banned

		for ( let id in this.players ) {
			this.players[id].SetReportButtons( this.banned ? false : !data.reported_players[id] )
		}

		//const updateIn = 15

		//$( "#ReportsUpdateCountdown" ).text = (
		//	$.Localize( "#au_your_reports_1" ) +
		//	updateIn +
		//	$.Localize( "#au_your_reports_2" ) + "(" +
		//	( data.reports_update_countdown + 1 ) +
		//	"/" + updateIn + ")"
		//)

		$( "#ToxicReports" ).text = data.toxic_reports
		$( "#CheatReports" ).text = data.cheat_reports
		$( "#PartyReports" ).text = data.party_reports

		this.reportsRemaining.text = $.Localize( "#au_reports_remaining" ) + data.reports_remaining

		$( "#BanRemainings" ).text = $.Localize( "#au_reports_situation_banned" ) + data.ban
	}

	Update() {
		for ( let id = 0; id < 24; id++ ) {
			if ( Players.IsValidPlayerID( id ) && id !== Players.GetLocalPlayer() ) {
				if ( !this.players[id] ) {
					this.players[id] = new MutesPlayer( id, this.muteList )
				}
			}
		}
	}
}