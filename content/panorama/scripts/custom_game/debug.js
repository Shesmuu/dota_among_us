errorLabels = []

function NetTableDebugErrors( data ) {
	$( "#DebugPanel" ).visible = true

	let i = 0

	for ( let k in data ) {
		if ( !errorLabels[i] ) {
			errorLabels[i] = $.CreatePanel( "Label", $( "#ErrorContainer" ), "" )
		}
			
		errorLabels[i].visible = true
		errorLabels[i].text = data[k]

		i++
	}

	while ( true ) {
		let err = errorLabels[i]

		if ( err ) {
			err.visible = false
		} else {
			break
		}

		i++
	}
}

$( "#DedicatedKey" ).visible = false
$( "#DebugPanel" ).visible = false

SubscribeNetTable( "debug", "errors", NetTableDebugErrors )