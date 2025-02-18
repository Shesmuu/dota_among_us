AU_WIN_REASON_TASKS_COMPLETED = 0
AU_WIN_REASON_SABOTAGE = 1
AU_WIN_REASON_IMPOSTOR_COUNT = 2
AU_WIN_REASON_IMPOSTOR_KILLED = 3

cameraHeightStart = 400
cameraHeightEnd = 256
cameraPitchStart = 70
cameraPitchEnd = 1
cameraYawStart = 10
cameraYawEnd = 48
cameraDistanceStart = 1134
cameraDistanceEnd = 400
cameraChangeDuration = 2
cameraStartTime = Game.GetGameTime()
cameraEndTime = Game.GetGameTime() + cameraChangeDuration
player_parties = []

Mutes_ = new Mutes()

function PlayerRow( parent, id, data, stats, color, solo ) {
	let panel = $.CreatePanel( "Panel", parent, "" )
	panel.BLoadLayoutSnippet( "PlayerRow" )

	let playerInfo = Game.GetPlayerInfo( Number( id ) )
	let avatar = panel.FindChildTraverse( "AvatarImage" )
	avatar.style.width = "100%"
	avatar.style.height = "100%"

	const colors = []
		colors[0] = "red"
		colors[1] = "green"
		colors[2] = "blue"
		colors[3] = "yellow"
		colors[4] = "orange"
		colors[5] = "pink"
		colors[6] = "purple"
	const c = colors[color]

	if ( playerInfo ) {
		avatar.steamid = playerInfo.player_steamid
	}

	panel.FindChildTraverse( "HeroImage" ).heroname = Players.GetPlayerSelectedHero( Number( id ) )
	panel.FindChildTraverse( "Nickname" ).text = Players.GetPlayerName( Number( id ) )

	let statsContainer = panel.FindChildTraverse( "PlayerStats" )

	for ( let stat of stats ) {
		if ( stat.role != null && data.role != stat.role ) {
			continue
		}

		let statPanel = $.CreatePanel( "Panel", statsContainer, "" )
		statPanel.AddClass( stat.playerStyle != null ? stat.playerStyle : "DefaultStat" )

		if ( stat.playerFunc ) {
			stat.playerFunc( statPanel, data )
		} else {
			let statLabel = $.CreatePanel( "Label", statPanel, "" )
			statLabel.text = data[stat.param]
		}
	}

	if (Number(CustomNetTables.GetTableValue("player", Number( id )).partyid) !== 0 ){
		if (Number(solo) !== 0){
			panel.style.borderLeft = "5px solid "+c+")"
			panel.FindChildTraverse( "PlayerInfo" ).style.backgroundColor = "gradient( linear, 0% 0%, 100% 0%, from( "+c+" ), to( #000 ) )"
		}
	}
}

function RolePlayers( stats, data ) {

	$( "#Imposters" ).BLoadLayoutSnippet( "RolePlayersList" )
	$( "#Imposters" ).FindChildTraverse( "RoleName" ).text = $.Localize( "#au_imposters" )

	let statsContainer = $( "#Imposters" ).FindChildTraverse( "StatTitles" )

	for ( let stat of stats ) {
		if ( stat.role != null && 1 != stat.role ) {
			continue
		}

		let statPanel = $.CreatePanel( "Panel", statsContainer, "" )
		statPanel.AddClass( stat.titleStyle != null ? stat.titleStyle : "DefaultStat" )

		if ( stat.titleFunc ) {
			stat.titleFunc( statPanel, data )
		} else {
			let statLabel = $.CreatePanel( "Label", statPanel, "" )
			statLabel.text = $.Localize( stat.name )
		}
	}

	$( "#Peaces" ).BLoadLayoutSnippet( "RolePlayersList" )
	$( "#Peaces" ).FindChildTraverse( "RoleName" ).text = $.Localize( "#au_peaces" )

	let statsContainer_2 = $( "#Peaces" ).FindChildTraverse( "StatTitles" )

	for ( let stat of stats ) {
		if ( stat.role != null && 0 != stat.role ) {
			continue
		}

		let statPanel = $.CreatePanel( "Panel", statsContainer_2, "" )
		statPanel.AddClass( stat.titleStyle != null ? stat.titleStyle : "DefaultStat" )

		if ( stat.titleFunc ) {
			stat.titleFunc( statPanel, data )
		} else {
			let statLabel = $.CreatePanel( "Label", statPanel, "" )
			statLabel.text = $.Localize( stat.name )
		}
	}

	for ( let id in data ) {
		let player_party = CustomNetTables.GetTableValue("player", Number( id )).partyid
		player_parties[player_party] = player_parties[player_party] || []
		if (player_parties[player_party].indexOf( id ) == -1) {
			player_parties[player_party].push(id)
		}
	}

	let color = 0
	let solo = 1

	for ( let partyid in player_parties ) {
		for ( let party_count of player_parties[partyid] ) {
			if (player_parties[partyid].length < 2) { solo = 0 } else { solo = 1 }
			if ( Players.IsValidPlayerID( Number(party_count) ) ) {
				if ( data[Number(party_count)].role == 0 ) {
					PlayerRow( $( "#Peaces" ), party_count, data[party_count], stats, color, solo )
				} else if ( data[Number(party_count)].role == 1 ) {
					PlayerRow( $( "#Imposters" ), party_count, data[party_count], stats, color, solo )
				}
			}
		}
		color = color + 1
	}
}

function NetTableWinner( data ) {
	let impostersPanel = $( "#Imposters" )
	let peacesPanel = $( "#Peaces" )
	let reason = $( "#Reason" )
	let texts = []
	texts[AU_WIN_REASON_TASKS_COMPLETED] = "#au_win_reason_tasks_completed"
	texts[AU_WIN_REASON_SABOTAGE] = "#au_win_reason_impostor_sabotage"
	texts[AU_WIN_REASON_IMPOSTOR_COUNT] = "#au_win_reason_impostor_count"
	texts[AU_WIN_REASON_IMPOSTOR_KILLED] = "#au_win_reason_impostor_killed"

	impostersPanel.RemoveAndDeleteChildren()
	peacesPanel.RemoveAndDeleteChildren()

	if (
		data.reason === AU_WIN_REASON_IMPOSTOR_COUNT ||
		data.reason === AU_WIN_REASON_SABOTAGE
	) {
		reason.AddClass( "Red" )
	} else {
		$( "#RolesContainer" ).AddClass( "PeaceWin" )
	}

	reason.text = $.Localize( texts[data.reason] )

	let rankFunc = ( panel, value, d ) => {
		let values = $.CreatePanel( "Panel", panel, "" )
		values.AddClass( "RatingRow" )

		let preStr = ""
		let style = "Minus"

		if ( d.rating_change >= 0 ) {
			preStr = "+"
			style = "Plus"
		}

		CreateLabel( values, value )
		CreateLabel( values, "(" + preStr + d.rating_change + ")", style )
	}

	let statsForm = [
		{
			role: 0,
			titleStyle: "TitleVotes",
			playerStyle: "TitleVotes",
			titleFunc: ( panel ) => {
				CreateLabel( panel, $.Localize( "#au_end_screen_stats_votes" ), "TitleVotesHigh" )

				let names = $.CreatePanel( "Panel", panel, "" )
				names.AddClass( "VotesRow" )

				CreateLabel( names, "T" )
				CreateLabel( names, "F" )
				CreateLabel( names, "S" )
			},
			playerFunc: ( panel, d ) => {
				let values = $.CreatePanel( "Panel", panel, "" )
				values.AddClass( "VotesRow" )

				CreateLabel( values, d.imposter_votes )
				CreateLabel( values, d.wrong_votes )
				CreateLabel( values, d.skip_votes )
			}
		},
		{
			role: 1,
			name: "#au_end_screen_stats_name_kills",
			param: "kills"
		},
		{
			name: "#au_end_screen_stats_name_death",
			playerFunc: ( panel, d ) => {
				let pos = data.playerCount - d.rank + 1
				let text = ""

				if ( d.leave_before_death == 1 ) {
					text = "#au_end_screen_stats_afk"
				} else if ( d.killed == 1 ) {
					text = "#au_end_screen_stats_killed"
				} else if ( d.kicked == 1 ) {
					text = "#au_end_screen_stats_kicked"
				} else {
					return
				}

				CreateLabel( panel, $.Localize( text ) + pos )
			}
		},
		{
		//	role: 1,
			name: "#au_end_screen_stats_rating",
			titleStyle: "TitleRating",
			playerStyle: "ValueRating",
			playerFunc: ( panel, d ) => rankFunc( panel, d.rating, d )
		},
		//{
		//	role: 0,
		//	name: "#au_end_screen_stats_rating",
		//	titleStyle: "TitleRating",
		//	playerStyle: "ValueRating",
		//	playerFunc: ( panel, d ) => rankFunc( panel, d.ratingPeace, d )
		//}
	]

	RolePlayers( statsForm, data.players )
}

function Update() {
	let now = Game.GetGameTime()
	let elapsed = now - cameraStartTime
	let m = Math.min( elapsed / cameraChangeDuration || 0, 1 )

	let heightDiff = cameraHeightEnd - cameraHeightStart
	let pitchDiff = cameraPitchEnd - cameraPitchStart
	let yawDiff = cameraYawEnd - cameraYawStart
	let distanceDiff = cameraDistanceEnd - cameraDistanceStart

	GameUI.SetCameraPitchMin( cameraPitchStart + pitchDiff * m )
	GameUI.SetCameraPitchMax( cameraPitchStart + pitchDiff * m )
	GameUI.SetCameraYaw( cameraYawStart + yawDiff * m )
	GameUI.SetCameraLookAtPositionHeightOffset( cameraHeightStart + heightDiff * m )
	GameUI.SetCameraDistance( cameraDistanceStart + distanceDiff * m )

	if ( now >= cameraStartTime + 0.5 ) {
		$.GetContextPanel().SetHasClass( "Visible", true )
	}
	$.Schedule( 0, Update )
}

SubscribeNetTable( "game", "winner", NetTableWinner )


UnmuteAll()
Update()

SubscribeNetTable( "player", Players.GetLocalPlayer().toString(), NetTablePlayerUpdate )

function NetTablePlayerUpdate( data ) {
	Mutes_.NetTablePlayer( data )

	let warning = $( "#ReportsWarning" )
	let situation = $( "#ReportsSituation" )
	let warningText = "#au_reports_warning"
	let situationText = "#au_reports_situation"

	if ( data.ban > 0 ) {
		warningText += "_banned"
		situationText += "_banned"
		situation.text = $.Localize( situationText ) + data.ban
		situation.visible = true
	} else {
		if (situation) {
			situation.visible = false
		}
	}

	if (warning) {
		warning.text = $.Localize( warningText )
	}

	if ($( "#LowPriorityCount" )) {
		$( "#LowPriorityCount" ).text = $.Localize( "#au_low_priority_remaining" ) + data.low_priority
	}
}