var dotahud = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent();

function PickInit(){
    GameEvents.Subscribe( 'pick_start', PickStart );
    GameEvents.Subscribe( 'pick_load_heroes', LoadHeroes );
    GameEvents.Subscribe( 'pick_timer_upd', TimerUpd );
    GameEvents.Subscribe( 'pick_start_selection', StartSelection );
    GameEvents.Subscribe( 'pick_preend_start', StartPreEnd );
    GameEvents.Subscribe( 'pick_select_hero', HeroSelected );
    GameEvents.Subscribe( 'pick_end', HeroSelectionEnd );
    GameEvents.Subscribe( 'hero_is_picked', HeroesIsPicked );
    GameEvents.Subscribe( 'pick_filter_reconnect', ShowFiltList );

    $.Schedule( 0.1, function(){
        GameEvents.SendCustomGameEventToServer( 'among_us_pick_player_registred', {} );
    })
}

function HeroSelectionLoad(){
    StealButtonsAndChat();
    $.Schedule( 0.1, function(){
        GameEvents.SendCustomGameEventToServer( 'among_us_pick_player_loaded', {} );
    });
}

function HeroSelectionEnd(){
    RestoreButtonsAndChat();
    $.GetContextPanel().AddClass('Deletion');
    $.GetContextPanel().DeleteAsync( 0.1 );
}

function PickStart( kv ){
    $.GetContextPanel().SetFocus();
}

var buttons;
var buttons_parent;
var chat;
var chat_parent;

function StealButtonsAndChat(){
    if( $.GetContextPanel().BHasClass('Deletion') ) return;
    buttons = dotahud.FindChildTraverse('MenuButtons');
    buttons_parent = buttons.GetParent();
    if( buttons ){
        buttons.SetParent( $.GetContextPanel() );
        buttons.FindChildTraverse('ToggleScoreboardButton').visible = false;
    }
    
    chat = dotahud.FindChildTraverse('HudChat');
    chat_parent = chat.GetParent();
    if( chat ){
        chat.SetParent( $.GetContextPanel() );
        chat.style.horizontalAlign = 'right';
        chat.style.y = '0px';
    }
}

function RestoreButtonsAndChat(){
    var HudElements = dotahud.FindChildTraverse('HUDElements');
    var button = dotahud.FindChildTraverse('MenuButtons');
    var chating = dotahud.FindChildTraverse('HudChat');

   if ( button && HudElements ){
        button.SetParent( HudElements );
        button.FindChildTraverse('ToggleScoreboardButton').visible = true;
    }
    
    if ( chating && HudElements ){
        chating.SetParent( HudElements );
        chating.style.horizontalAlign = 'center';
        chating.style.y = '-220px';
    }
}

function LoadHeroes( kv ){
    var hero_list = CustomNetTables.GetTableValue("among_us_pick", "hero_list");
    if (hero_list)
    {
        if (hero_list.all_heroes !== null)
        {
            if( $("#PanelSelector").FindChild("HeroesForGame") ) return;
            var heroes_row = $.CreatePanel("Panel", $("#PanelSelector"), "HeroesForGame" );
            heroes_row.BLoadLayoutSnippet('HeroPickRow');
            if( $("#PanelSelector_2").FindChild("HeroesForRating") ) return;
            var heroes_rating_row = $.CreatePanel("Panel", $("#PanelSelector_2"), "HeroesForRating" );
            var heroes_rating_text = $.CreatePanel('Label', $("#PanelSelector_2"), 'heroes_rating_text');
            heroes_rating_text.AddClass('RatingInfoLabel');
            heroes_rating_text.text = $.Localize("#ratingheroes")
            heroes_rating_row.BLoadLayoutSnippet('HeroPickRow');
            for (var i = 1; i <= hero_list.all_heroes_length; i++) 
            {
                panel = heroes_row
                if  (IsRating(hero_list.all_heroes[i])) {panel = heroes_rating_row;}
                var hero_creating = panel.FindChild(hero_list.all_heroes[i])
                if (hero_creating) { return };
                var panel = $.CreatePanel("Panel", panel, hero_list.all_heroes[i] );
                panel.AddClass("hero_select_panel");
                SetPSelectEvent(panel, hero_list.all_heroes[i]);
                var hero_avatar = $.CreatePanel("Panel", panel, "HeroAvatar" );
                hero_avatar.AddClass("HeroAvatar");
                var str = '<DOTAHeroImage id="hero_portrait" heroname="'+hero_list.all_heroes[i]+'" heroimagestyle="portrait" scaling="stretch-to-cover-preserve-aspect" />'
                hero_avatar.BCreateChildren(str)
                ShowHero(hero_avatar, hero_list.all_heroes[i]);
                if  (IsRating(hero_list.all_heroes[i]))
                {
                    panel.style.height = '153px'; 
                    var rating_panel = $.CreatePanel("Panel", panel, "rating_panel" );
                    rating_panel.AddClass("rating_panel");
                    var rating_panel_text = $.CreatePanel('Label', rating_panel, 'rating_panel_text');
                    rating_panel_text.AddClass('RatingPanelLabel');
                    rating_panel_text.text = $.Localize( "#rating" ) + GetRatingHero(hero_list.all_heroes[i])

                    if (GetRating(GetRatingHero(hero_list.all_heroes[i]))) {
                        rating_panel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #307663 ), to( #245a4b ) )'
                    }else{
                        rating_panel.style.backgroundColor = 'gradient( linear, 0% 0%, 0% 100%, from( #763030 ), to( #5a2424 ) )'
                        hero_avatar.AddClass('RatingLow');
                        panel.SetPanelEvent("onactivate", function() {} );  
                        var hero_avatar_blocked = $.CreatePanel("Panel", hero_avatar, "hero_avatar_blocked" );
                        hero_avatar_blocked.AddClass("RatingLowLogo");
                    }
                }
                panel.BLoadLayoutSnippet('HeroCard');
            }
        }
           $("#ButtonRandomHero").SetPanelEvent("onactivate", function() {
            GameEvents.SendCustomGameEventToServer( "among_us_pick_select_hero", {random : true,} );    
            Game.EmitSound("General.ButtonClick");
        }
        ); 
    }
}

function ShowHero(panel, hero)
{
    panel.SetPanelEvent('onmouseover', function() {
        var new_portrait = '<MoviePanel id="portrait_'+hero+'" class="hero_portrait" src="file://{resources}/videos/heroes/'+hero+'.webm" repeat="true" autoplay="onload"/>'
        panel.BCreateChildren(new_portrait) 
    });
        
    panel.SetPanelEvent('onmouseout', function() {
        var movie = panel.FindChild('portrait_'+hero+'')
        if (movie) {
            movie.DeleteAsync( 0.1 );
        }
    });       
}

function SetPSelectEvent(panel, hero)
{
    panel.SetPanelEvent("onactivate", function() { ChangeHeroInfo(hero);} );        
}

function ChangeHeroInfo(hero_name) 
{
    var str = '<MoviePanel id="hero_portrait" class="hero_portrait" src="file://{resources}/videos/heroes/'+hero_name+'.webm" repeat="true" autoplay="onload"/>'
    $("#HeroModel").BCreateChildren(str)
    $("#hero_name_info").text = $.Localize(hero_name);  
    var abilities = GetHeroAbility(hero_name);
    $('#AbilitiesInfo').RemoveAndDeleteChildren(); 
    var ab = 0;
    while(true)
    {
        ab++;     
        if (!abilities[ab]) {break;}
        var ability_panel = $.CreatePanel('DOTAAbilityImage', $('#AbilitiesInfo'), 'ability_' + ab);
        ability_panel.abilityname = abilities[ab];
        ability_panel.AddClass('HeroInfoAbilty');
        SetShowAbDesc(ability_panel, abilities[ab]);
    }
    $("#PickButton").SetPanelEvent("onactivate", function() {
            GameEvents.SendCustomGameEventToServer( "among_us_pick_select_hero", {hero : hero_name,} );    
            Game.EmitSound("General.ButtonClick");
        }
    );
}

function SetShowAbDesc(panel, ability)
{
    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltip', panel, ability); });
        
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });       
}

function GetHeroAbility(hero_name) {
    var abilities = CustomNetTables.GetTableValue("among_us_pick", hero_name);
    if (abilities)
    {
        return abilities;
    } 
    return [];
}

function TimerUpd( kv ){
    var timer_panel = $('#PickTimer');
    if( !timer_panel ) return;
    timer_panel.text = kv.timer;
}

function StartSelection( kv ){
    $("#PickState").text = $.Localize("AMONG_US_PICK_STATE_SELECT");
    $("#ButtonSelectHeroLabel").text = $.Localize("#DOTA_SELECT_Button");
    Game.EmitSound("announcer_announcer_choose_hero");
}

function StartPreEnd( kv ){
    $("#PickState").text = $.Localize("AMONG_US_PICK_STATE_PRE_END");
    $("#PickButton").style.visibility = "collapse";
    $("#ButtonRandomHero").style.visibility = "collapse";
}

function HeroSelected(kv)
{    
    var child = $("#" + kv.hero).FindChild("HeroAvatar");
    if (child) {
        child.AddClass('Picked');
    }
}

function HeroesIsPicked(kv) {
    $("#PickButton").style.visibility = "collapse";
    $("#ButtonRandomHero").style.visibility = "collapse";
    $("#hero_selection_main").style.visibility = "collapse";
    $("#hero_selection_your_hero").style.visibility = "visible";
    var hero =  '<DOTAScenePanel id="hero_selected" style="width:600px;height:500px;margin-top:20px;" drawbackground="1" unit="'+kv.hero+'" particleonly="false" />'
    $("#HeroPickedContainer").BCreateChildren(hero)
    $("#HeroPickedName").text = $.Localize(kv.hero);
    $("#HeroInformationPanel").style.width = "600px";  
}

function BacktoHeroes() {
    $("#hero_selection_main").style.visibility = "visible";
    $("#hero_selection_your_hero").style.visibility = "collapse";
}

function BacktoHero() {
    $("#hero_selection_main").style.visibility = "collapse";
    $("#hero_selection_your_hero").style.visibility = "visible";
}

function ShowFiltList(kv) 
{   
    for (var i = 1; i <= kv.picked_length; i++) {
        var panel = $("#" + kv.picked[i]).FindChild("HeroAvatar");
        if (panel)
        {
            panel.AddClass('Picked');                   
        }
    }  
}

function IsRating(h) {
    var hero_list = CustomNetTables.GetTableValue("among_us_pick", "hero_list");
    if (hero_list.rating_heroes === undefined) {return false;}
    for (var i = 1; i <= hero_list.rating_heroes_lenght; i++) {
        if (hero_list.rating_heroes[i].hero === h) {
            return true;
        }
    }
    return false;
}

function GetRatingHero(h) {
    var hero_list = CustomNetTables.GetTableValue("among_us_pick", "hero_list");
    if (hero_list.rating_heroes === undefined) {return false;}
    for (var i = 1; i <= hero_list.rating_heroes_lenght; i++) {
        if (hero_list.rating_heroes[i].hero === h) {
            return hero_list.rating_heroes[i].ratingneed;
        }
    }
    return false;
}

function GetRating(rating) {
    // Подключи таблицу рейтинга игрока сюда
    if (table_rating >= rating) {
        return true;
    }
    return false;
}

PickInit();

