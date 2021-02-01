class TimerDayNight {
	constructor() {
		this.container = $( "#Voting" )
		this.voting_count = this.container.FindChildTraverse( "VotingTimer" )
	}

	NetTableState( data ) {
		this.voting_count.text = data.kick_count
	}
}

function UpdateTimer( data )
{
    var timerText = "";
    timerText += data.timer_minute_10;
    timerText += data.timer_minute_01;
    timerText += ":";
    timerText += data.timer_second_10;
    timerText += data.timer_second_01;

    if ((data.time_full % 2) !== 0) {
    	$( "#TimerIcon" ).style.backgroundImage = 'url("s2r://panorama/images/hud/reborn/icon_moon_psd.vtex")'
    } else {
    	$( "#TimerIcon" ).style.backgroundImage = 'url("s2r://panorama/images/hud/reborn/icon_sun_psd.vtex")'
    }

    $( "#Timer" ).text = timerText;
}

function InfoTimers()
{
    var text_button_1 = $.Localize( "#timer_info" )
    var text_button_2 = $.Localize( "#voting_info" )
    $( "#TimerDayNight" ).SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', $( "#TimerDayNight" ), text_button_1); });
        
    $( "#TimerDayNight" ).SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', $( "#TimerDayNight" ));
    }); 

    $( "#Voting" ).SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTextTooltip', $( "#Voting" ), text_button_2); });
        
    $( "#Voting" ).SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', $( "#Voting" ));
    });      
}

( function() {
	GameEvents.Subscribe( 'countdown', UpdateTimer );
    InfoTimers()
} )()