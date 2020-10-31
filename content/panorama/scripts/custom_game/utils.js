function SubscribeNetTable( tN, k, f, any ) {
	let t = CustomNetTables.GetTableValue( tN, k )

	if ( t ) {
		f( t, k )
	}

	CustomNetTables.SubscribeNetTableListener( tN, function( table, key, data ) {
		if ( k == key || any ){
			f( data, key )
		}
	} )
}

function RandomInt( min, max ) {
	let d = max - min + 1
	let i = Math.random() * d

	return min + Math.floor( i )
}

function DelayTime( time ) {
	return Game.GetGameTime() + time
}

function Countdown( now, endTime, fix ) {
	return Math.max( 0, endTime - now ).toFixed( fix )
}

function SetPosition( panel, x, y ) {
	panel.style.x = x + "px"
	panel.style.y = y + "px"
}

function UnmuteAll() {
	for ( let id = 0; id < 24; id++ ) {
		Game.SetPlayerMuted( id, false )
	}
}

function CreateLabel( parent, text, style ) {
	let label = $.CreatePanel( "Label", parent, "" )
	label.text = text

	if ( style ) {
		label.AddClass( style )
	}

	return label
}