customChatEnabled = !Game.IsInToolsMode()

AU_GAME_STATE_NONE = 0
AU_GAME_STATE_PROCESS = 2
AU_GAME_STATE_KICK_VOTING = 3
AU_GAME_STATE_SCREEN_NOTICE = 4

AU_NOTICE_TYPE_IMPOSTOR_KICKED = 0
AU_NOTICE_TYPE_PEACE_KICKED = 1
AU_NOTICE_TYPE_KICK_VOTING_CONVENE = 2
AU_NOTICE_TYPE_KICK_VOTING_REPORT = 3
AU_NOTICE_TYPE_IMPOSTORS_REMAINING = 4
AU_NOTICE_TYPE_NO_KICKED = 5
AU_NOTICE_TYPE_NONE = 6

noticeTexts = []
noticeTexts[AU_NOTICE_TYPE_IMPOSTOR_KICKED] = "#au_notice_impostor_kicked"
noticeTexts[AU_NOTICE_TYPE_PEACE_KICKED] = "#au_notice_peace_kicked"
noticeTexts[AU_NOTICE_TYPE_KICK_VOTING_CONVENE] = "#au_notice_kick_voting_convene"
noticeTexts[AU_NOTICE_TYPE_IMPOSTORS_REMAINING] = "#au_notice_impostors_remaining"
noticeTexts[AU_NOTICE_TYPE_NO_KICKED] = "#au_notice_no_kicked"
noticeTexts[AU_NOTICE_TYPE_NONE] = ""

AU_ROLE_PEACE = 0
AU_ROLE_IMPOSTOR = 1

currentState = AU_GAME_STATE_NONE
localDied = false
minimapBlocker = null

$( "#LowPriorityCount" ).text = $.Localize( "#au_low_priority_remaining" ) + 0

GameEvents.Subscribe( "dota_player_update_query_unit", () => {
	let id = Players.GetLocalPlayer()
	let unit = Players.GetLocalPlayerPortraitUnit()
	let hero = Players.GetPlayerHeroEntityIndex( id )

	if (
		Entities.GetUnitName( unit ) == "npc_dota_hero_meepo" &&
		Entities.GetPlayerOwnerID( unit ) == id ||
		unit == hero
	) {
		return
	}

	GameUI.SelectUnit( hero, false )
} )

TopBar_ = new TopBar()
Quests_ = new Quests()
Minigames_ = new Minigames()
KickVotingTimer_ = new KickVotingTimer()
HeroBarSystem_ = new HeroBarSystem()
Sounds_ = new Sounds()
Chat_ = new Chat()
Profile_ = new Profile()
Settings_ = new Settings()
AFKKillDelay = new ( class {
	constructor() {
		this.panel = $( "#AFKKillDelay" )

		GameEvents.Subscribe( "au_afk_kill_delay_close", () => this.Close() )
		GameEvents.Subscribe( "au_afk_kill_delay_start", data => this.Start( data ) )

		this.Close()
	}

	Update( now ) {
		if ( !this.started ) {
			return
		}

		let remaining = Math.max( this.killTime - now, 0 )

		this.panel.text = $.Localize( "#au_afk_kill_delay" ) + Math.abs( remaining ).toFixed( 0 )
	}

	Start( data ) {
		this.killTime = data.time

		this.started = true
		this.panel.visible = true
	}

	Close() {
		this.started = false
		this.panel.visible = false
	}
} )()

redMessageHideTime = 0

GameEvents.Subscribe( "au_set_camara_position", data => {
	GameUI.SetCameraTarget( data.unit )
	$.Schedule( 0.1, () => GameUI.SetCameraTarget( -1 ) )
} )

GameEvents.Subscribe( "au_emit_sound", data => {
	Sounds_.EmitSound( data.sound )
} )

GameEvents.Subscribe( "au_dedicated_server_key", data => {
	$( "#DedicatedKeyEntry" ).text = data.key
	$( "#DedicatedKey" ).visible = true
} )

function RedCenterMessage( data ) {
	$( "#RedCenterMessage" ).SetHasClass( "Visible", true )

	let label = $( "#RedCenterMessageText" )

	if ( data.text ) {
		label.text = $.Localize( data.text )
	} else if ( data.afk_killed != null ) {
		let heroName = Players.GetPlayerSelectedHero( data.afk_killed )
		let text = $.Localize( data.role_text ) + $.Localize( "#" + heroName ) + $.Localize( data.right_text )

		label.text = text
	}

	redMessageHideTime = Game.GetGameTime() + data.duration
}

function WhiteCenterMessage( text ) {
	$( "#RedCenterMessage" ).SetHasClass( "Visible", false )
	$( "#WhiteCenterMessage" ).SetHasClass( "Visible", true )

	$( "#WhiteCenterMessageText" ).text = $.Localize( text )
}

function NetTableDied( data ) {
	localDied = data[Players.GetLocalPlayer()] == 1

	Chat_.NetTableDied( data )
	TopBar_.NetTableDied( data )
	HeroBarSystem_.NetTableDied( data )
}

function NetTableImpostors( data ) {
	TopBar_.NetTableImpostors( data )
	HeroBarSystem_.NetTableImpostors( data )
}

function NetTableState( data ) {
	currentState = data.state

	if ( data.state == AU_GAME_STATE_SCREEN_NOTICE ) { 
		if (
			data.notice == AU_NOTICE_TYPE_PEACE_KICKED ||
			data.notice == AU_NOTICE_TYPE_IMPOSTOR_KICKED
		) {
			if ( data.visible_impostor_count ) {
				WhiteCenterMessage( noticeTexts[data.notice] )
			} else {
				let heroName = Players.GetPlayerSelectedHero( data.last_kicked )
				WhiteCenterMessage( $.Localize( "#" + heroName ) + $.Localize( "#au_notice_unknown_kicked" ) )
			}
		} else if ( noticeTexts[data.notice] ) {
			WhiteCenterMessage( noticeTexts[data.notice] )
		} else if ( data.notice == AU_NOTICE_TYPE_KICK_VOTING_REPORT ) {
			let heroName = Players.GetPlayerSelectedHero( data.found_corpse || 0 )
			WhiteCenterMessage(
				$.Localize( "#au_notice_kick_voting_report_first" ) +
				$.Localize( "#" + heroName ) +
				$.Localize( "#au_notice_kick_voting_report_second" )
			)
		}
	} else {
		$( "#WhiteCenterMessage" ).SetHasClass( "Visible", false )
	}

	if ( data.state == AU_GAME_STATE_KICK_VOTING ) {
		KickVotingTimer_.SetEndTime( data.kick_voting_end_time )
		KickVotingTimer_.SetEnabled( true )
		HeroBarSystem_.SetEnabled( true )
	} else {
		KickVotingTimer_.SetEnabled( false )
	}

	if ( data.state == AU_GAME_STATE_PROCESS ) {
		HeroBarSystem_.SetEnabled( false )
	}

	Quests_.SetState( data.state )
	Minigames_.NetTableState( data )
	TopBar_.NetTableState()
	TopBar_.SetImpostorsRemaining( data.impostor_remaining )
	TopBar_.SetImpostorsRemainingVisible( !!data.visible_impostor_count )
}

function NetTableQuests( data ) {
	Quests_.NetTableQuests( data )
}

function NetTablePlayer( data ) {
	Quests_.NetTablePlayer( data )
	Minigames_.NetTablePlayer( data )

	$( "#LowPriorityCount" ).text = $.Localize( "#au_low_priority_remaining" ) + data.low_priority
}

function Update() {
	let now = Game.GetGameTime()

	TopBar_.UpdatePlayers()
	Minigames_.Update( now )
	Quests_.Update( now )
	KickVotingTimer_.Update( now )
	HeroBarSystem_.Update()
	Settings_.Update( now )
	AFKKillDelay.Update( now )

	if ( now >= redMessageHideTime ) {
		$( "#RedCenterMessage" ).SetHasClass( "Visible", false )
	}

	if ( !Game.GameStateIs( DOTA_GameState.DOTA_GAMERULES_STATE_POST_GAME ) ) {
		$.Schedule( 0, Update )
	}

	let minimapBlockerSize = "0px"

	if ( currentState == AU_GAME_STATE_KICK_VOTING && localDied ) {
		minimapBlockerSize = "100%"
	}

	minimapBlocker.style.width = minimapBlockerSize
	minimapBlocker.style.height = minimapBlockerSize
}

function HideMorphTransform() {
	let panel = $( "#MorphHeroSelectPanel" )
	panel.SetHasClass( "Visible", false )
}

for ( let i = 0; i < DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ELEMENT_COUNT; i++ ) {
	if (
		i !== DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL &&
		i !== DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP &&
		i !== DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL &&
		i !== DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS &&
		i !== DotaDefaultUIElement_t.DOTA_DEFAULT_UI_CUSTOMUI_BEHIND_HUD_ELEMENTS
	) {
		GameUI.SetDefaultUIEnabled( i, false )
	} else {
		GameUI.SetDefaultUIEnabled( i, true )
	}
}

GameEvents.Subscribe( "au_red_center_message", RedCenterMessage )
GameEvents.Subscribe( "au_morph_transform_start", heroes => {
	let panel = $( "#MorphHeroSelectPanel" )
	panel.SetHasClass( "Visible", true )
	let container = panel.FindChildTraverse( "HeroesContainer" )
	container.RemoveAndDeleteChildren()

	for ( let id in heroes ) {
		let heroName = heroes[id]
		let hero = $.CreatePanel( "DOTAHeroImage", container, "" )
		hero.heroname = heroName

		hero.SetPanelEvent( "onactivate", () => {
			HideMorphTransform()

			GameEvents.SendCustomGameEventToServer( "au_morph_transform_select", {
				id: id
			} )
		} )
	}
} )

SubscribeNetTable( "game", "died", NetTableDied )
SubscribeNetTable( "game", "impostors", NetTableImpostors )
SubscribeNetTable( "game", "state", NetTableState )
SubscribeNetTable( "game", "quests", NetTableQuests )
SubscribeNetTable( "player", Players.GetLocalPlayer().toString(), NetTablePlayer )

GameUI.SetMouseCallback( ( event, button ) => {
	if ( GameUI.IsAltDown() ) {
		if ( currentState == AU_GAME_STATE_KICK_VOTING && localDied ) {
			return true
		}
	}

	return false
} )

;( function() {
	let hudElements = 
		$.GetContextPanel()
		.GetParent()
		.GetParent()
		.GetParent()
		.FindChildTraverse( "HUDElements" )

	if ( customChatEnabled ) {
		let hudChat = hudElements.FindChildTraverse( "HudChat" )
		hudChat.style.opacity = "0"
	
		let chatInput = hudChat.FindChildTraverse( "ChatInput" )
		chatInput.SetPanelEvent( "onfocus", () => {
			$.Schedule( 0, () => {
				Chat_.OpenChat()
				chatInput.text = ""
			} )
		} )
	}

	let minimapBlock = hudElements.FindChildTraverse( "minimap_block" )
	let minimap = minimapBlock.FindChildTraverse( "minimap" )
	minimap.BLoadLayout(
		"file://{resources}/layout/custom_game/minimap.xml",
		false,
		false
	)

	let queryUnit = hudElements.FindChildTraverse( "QueryUnit" )
	queryUnit.style.width = "0px"
	queryUnit.style.height = "0px"

	minimapBlocker = $.CreatePanel( "Button", minimapBlock, "" )
	minimapBlocker.style.width = "100%"
	minimapBlocker.style.height = "100%"
} )()

Update()