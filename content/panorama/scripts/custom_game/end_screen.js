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

function NetTableWinner( data ) {
	let reason = $( "#Reason" )
	let texts = []
	texts[AU_WIN_REASON_TASKS_COMPLETED] = "#au_win_reason_tasks_completed"
	texts[AU_WIN_REASON_SABOTAGE] = "#au_win_reason_impostor_sabotage"
	texts[AU_WIN_REASON_IMPOSTOR_COUNT] = "#au_win_reason_impostor_count"
	texts[AU_WIN_REASON_IMPOSTOR_KILLED] = "#au_win_reason_impostor_killed"

	if (
		data.reason === AU_WIN_REASON_IMPOSTOR_COUNT ||
		data.reason === AU_WIN_REASON_SABOTAGE
	) {
		reason.AddClass( "Red" )
	}

	reason.text = $.Localize( texts[data.reason] )
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

	if ( now >= cameraStartTime + 2 ) {
		$.GetContextPanel().SetHasClass( "Visible", true )
	}

	$.Schedule( 0, Update )
}

SubscribeNetTable( "game", "winner", NetTableWinner )

UnmuteAll()

Update()