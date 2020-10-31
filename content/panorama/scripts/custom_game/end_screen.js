AU_WIN_REASON_TASKS_COMPLETED = 0
AU_WIN_REASON_SABOTAGE = 1
AU_WIN_REASON_IMPOSTOR_COUNT = 2
AU_WIN_REASON_IMPOSTOR_KILLED = 3

cameraHeightStart = 400
cameraHeightEnd = 256
cameraPitchStart = 70
cameraPitchEnd = 1
cameraYawStart = 10
cameraYawEnd = 70
cameraDistanceStart = 1134
cameraDistanceEnd = 400
cameraChangeDuration = 2
cameraStartTime = Game.GetGameTime()
cameraEndTime = Game.GetGameTime() + cameraChangeDuration

function PlayerRow( parent, id, data, stats ) {
	let panel = $.CreatePanel( "Panel", parent, "" )
	panel.BLoadLayoutSnippet( "PlayerRow" )

	let avatar = panel.FindChildTraverse( "AvatarImage" )
	avatar.steamid = Game.GetPlayerInfo( Number( id ) ).player_steamid
	avatar.style.width = "100%"
	avatar.style.height = "100%"

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
}

function RolePlayers( parent, title, role, stats, data ) {
	parent.BLoadLayoutSnippet( "RolePlayersList" )
	parent.FindChildTraverse( "RoleName" ).text = $.Localize( title )

	let statsContainer = parent.FindChildTraverse( "StatTitles" )

	for ( let stat of stats ) {
		if ( stat.role != null && role != stat.role ) {
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

	let playersContainer = parent.FindChildTraverse( "PlayerRow" )

	for ( let id in data ) {
		if ( data[id].role == role ) {
			PlayerRow( parent, id, data[id], stats )
		}
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
	}

	reason.text = $.Localize( texts[data.reason] )

	let rankFunc = ( panel, value, data ) => {
		let values = $.CreatePanel( "Panel", panel, "" )
		values.AddClass( "RatingRow" )

		CreateLabel( values, value )
		CreateLabel( values, "" + data.ratingChange, data.ratingChange < 0 ? "Minus" : "Plus" )
	}

	let statsForm = [
		{
			name: "#au_end_screen_stats_name_rank",
			param: "rank"
		},
		{
			role: 0,
			titleStyle: "TitleVotes",
			playerStyle: "TitleVotes",
			titleFunc: ( panel ) => {
				CreateLabel( panel, $.Localize( "#au_end_screen_stats_votes" ), "TitleVotesHigh" )

				let names = $.CreatePanel( "Panel", panel, "" )
				names.AddClass( "VotesRow" )

				CreateLabel( names, "T" )
				CreateLabel( names, "W" )
				CreateLabel( names, "S" )
			},
			playerFunc: ( panel, data ) => {
				let values = $.CreatePanel( "Panel", panel, "" )
				values.AddClass( "VotesRow" )

				CreateLabel( values, data.imposterVotes )
				CreateLabel( values, data.skipVotes )
				CreateLabel( values, data.wrongVotes )
			}
		},
		{
			role: 1,
			name: "#au_end_screen_stats_name_kills",
			param: "kills"
		},
		{
			role: 1,
			name: "#au_end_screen_stats_rating",
			titleStyle: "TitleRating",
			playerStyle: "ValueRating",
			playerFunc: ( panel, data ) => rankFunc( panel, data.ratingImposter, data )
		},
		{
			role: 0,
			name: "#au_end_screen_stats_rating",
			titleStyle: "TitleRating",
			playerStyle: "ValueRating",
			playerFunc: ( panel, data ) => rankFunc( panel, data.ratingPeace, data )
		}
	]

	RolePlayers( impostersPanel, "#au_imposters", 1, statsForm, data.players )
	RolePlayers( peacesPanel, "#au_peaces", 0, statsForm, data.players )
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