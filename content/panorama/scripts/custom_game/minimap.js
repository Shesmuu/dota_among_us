contextPanel = $.GetContextPanel()
heroContainer = $( "#HeroContainer" )
questsContainer = $( "#QuestContainer" )
sabotageContainer = $( "#SabotageContainer" )
minimapHero = null
hero = -1
worldSize = 18944
worldMin = -worldSize / 2
questsList = []
sabotageList = []

function NetTablePlayer( data ) {
	if ( data.quests ) {
		MinimapQuests(
			data.quests,
			questsList,
			12,
			() => {
				let label = $.CreatePanel( "Label", questsContainer, "" )
				label.text = "!"

				return label
			},
			false
		)
	}
}

function NetTableQuests( data ) {
	questsContainer.visible = data.interferenced !== 1

	MinimapQuests(
		data.quests,
		sabotageList,
		12,
		() => $.CreatePanel( "Panel", sabotageContainer, "" ),
		true
	)
}

function MinimapQuests( data, list, offset, panelFunc, m ) {
	let i = 0
	let setPanel = unit => {
		if ( unit ) {
			if ( !list[i] ) {
				list[i] = panelFunc()
			}

			UnitMinimap( list[i], unit, offset, offset )
				
			list[i].SetHasClass( "Visible", true )

			i++
		}
	}

	for ( let k in data ) {
		if ( m ) {
			for ( let i in data[k].units ) {
				setPanel( data[k].units[i] )
			}
		} else { 
			setPanel( data[k].target )
		}
	}

	while ( true ) {
		let panel = list[i]

		if ( panel ) {
			panel.SetHasClass( "Visible", false )
		} else {
			break
		}

		i++
	}
}

function WorldToMinimapPosition( v ) {
	let miniMapWidth = contextPanel.actuallayoutwidth
	let miniMapHeight = contextPanel.actuallayoutheight
	let screenM = Game.GetScreenHeight() / 1080
	let x = ( ( v[0] - worldMin ) / worldSize ) * miniMapWidth / screenM
	let y = ( 1 - ( v[1] - worldMin ) / worldSize ) * miniMapHeight / screenM

	return {
		x: x,
		y: y
	}
}

function UnitMinimap( panel, unit, offsetX, offsetY ) {
	let pos = Entities.GetAbsOrigin( unit )
	let minimapPos = WorldToMinimapPosition( pos )

	SetPosition( panel, minimapPos.x - offsetX, minimapPos.y - offsetY )
}

function Update() {
	let id = Players.GetLocalPlayer()

	if ( hero === -1 ) {
		hero = Players.GetPlayerHeroEntityIndex( id )
	}

	if ( !minimapHero ) {
		let selectedHero = Players.GetPlayerSelectedHero( id )

		if ( selectedHero && hero !== -1 ) {
			minimapHero = $.CreatePanel( "Image", heroContainer, "" )
			minimapHero.AddClass( "MinimapHero" )
			minimapHero.SetImage( "file://{images}/heroes/icons/" + selectedHero + ".png" )
		}
	} else if ( hero !== -1 ) {
		UnitMinimap( minimapHero, hero, 16, 16 )
	}

	$.Schedule( 0, Update )
}


$.Schedule( 1, () => {
	SubscribeNetTable( "game", "quests", NetTableQuests )
	SubscribeNetTable( "player", Players.GetLocalPlayer().toString(), NetTablePlayer )

	Update()
} )
