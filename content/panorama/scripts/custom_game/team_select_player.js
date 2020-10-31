"use strict";

const RATING_PANEL = $("#RatingPanel")
const PANELS = 
[
	$("#Rating1"),
	$("#Rating2"),
	$("#TotalGames"),
	$("#FavHero")
]

//--------------------------------------------------------------------------------------------------
// Handeler for when the unssigned players panel is clicked that causes the player to be reassigned
// to the unssigned players team
//--------------------------------------------------------------------------------------------------
function OnLeaveTeamPressed()
{
	Game.PlayerJoinTeam( 5 ); // 5 == unassigned ( DOTA_TEAM_NOTEAM )
}


//--------------------------------------------------------------------------------------------------
// Update the contents of the player panel when the player information has been modified.
//--------------------------------------------------------------------------------------------------
function OnPlayerDetailsChanged()
{
    var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
	var playerInfo = Game.GetPlayerInfo( playerId );
	
	if ( !playerInfo )
		return;

	$( "#PlayerName" ).text = playerInfo.player_name;
	$( "#PlayerAvatar" ).steamid = playerInfo.player_steamid;

	$.GetContextPanel().SetHasClass( "player_is_local", playerInfo.player_is_local );
	$.GetContextPanel().SetHasClass( "player_has_host_privileges", playerInfo.player_has_host_privileges );
}

function OnPlayerDataChanged(table_name, key, data)
{	
	var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);

	if (key == playerId.toString())
	{
		try {
			var player = CustomNetTables.GetTableValue("player", playerId.toString())
	
			if (player != undefined)
			{
				RATING_PANEL.SetHasClass("Hidden", false)
				PANELS[3].SetHasClass("Hidden", false)
				
				PANELS[0].text = player.stats.ratingPeace
				PANELS[1].text = player.stats.ratingImposter
				PANELS[2].text = Number(player.stats.totalWins) + Number(player.stats.totalLoses)
				PANELS[3].heroname = player.stats.favoriteHero
			}
		} catch (error) {
			$.Msg(error)	
		}
	}
}

//--------------------------------------------------------------------------------------------------
// Entry point, update a player panel on creation and register for callbacks when the player details
// are changed.
//--------------------------------------------------------------------------------------------------
(function()
{
	OnPlayerDetailsChanged();
	$.RegisterForUnhandledEvent( "DOTAGame_PlayerDetailsChanged", OnPlayerDetailsChanged );

	RATING_PANEL.SetHasClass("Hidden", true)
	PANELS[3].SetHasClass("Hidden", true)

	CustomNetTables.SubscribeNetTableListener("player", OnPlayerDataChanged);

	try {
		var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
		var player = CustomNetTables.GetTableValue("player", playerId.toString())

		if (player != undefined)
		{
			RATING_PANEL.SetHasClass("Hidden", false)
			PANELS[3].SetHasClass("Hidden", false)

			PANELS[0].text = player.stats.ratingPeace
			PANELS[1].text = player.stats.ratingImposter
			PANELS[2].text = Number(player.stats.totalWins) + Number(player.stats.totalLoses)

			PANELS[3].heroname = player.stats.favoriteHero
		}
	} catch (error) {
		$.Msg(error)	
	}
})();
