class Quest {
	constructor( parent ) {
		this.panel = $.CreatePanel( "Label", parent, "" )
		this.stoped = false
		this.isCountdown = false
	}

	SetText( text ) {
		this.text = text

		if ( this.countdown ) {
			this.panel.text = text + " - " + this.CalcTime( Game.GetGameTime() )
		} else {
			this.panel.text = text
		}
	}

	SetCoundown( bool ) {
		this.isCountdown = bool
	}

	Countdown( time ) {
		this.countdown = time

		if ( time != null ) {
			this.panel.text = this.text + " - " + time
		} else {
			this.panel.text = this.text
		}
	}

	SetStoped( time ) {
		this.stoped = true
		this.Countdown( time )
	}

	SetEndTime( time ) {
		this.endTime = time
	}

	SetVisible( bool ) {
		this.panel.SetHasClass( "Visible", bool )
	}

	SetCompleted( bool ) {
		this.panel.SetHasClass( "Completed", bool )
	}

	CalcTime( now ){
		return Math.max( this.endTime - now, 0 ).toFixed( 0 )
	}

	Update( now ) {
		if ( this.isCountdown && this.endTime != null ) {
			this.Countdown( this.CalcTime( now ) )
		}
	}
}

class Quests {
	constructor() {
		this.panel = $( "#Quests" )
		this.totalTasksCompleted = $( "#TotalTasksCompleted" )
		this.progress = $( "#TasksProgress" )
		this.questsContainer = $( "#QuestsList" )
		this.globalQuestsContainer = $( "#GlobalQuestsList" )
		this.alertPanel = $( "#SabotageDurning" )
		this.alertQuest = false
		this.alertEnabled = false
		this.questsList = []
		this.globalQuestsList = []
		this.state = AU_GAME_STATE_NONE
	}

	SetState( state ) {
		this.state = state

		this.UpdateAlert()
	}

	NetTablePlayer( data ) {
		this.SetQuests( data.quests, this.questsList, this.questsContainer )
	}

	NetTableQuests( data ) {
		this.alertQuest = data.alert

		this.SetInterferenced( data.interferenced === 1 )
		this.SetQuests( data.quests, this.globalQuestsList, this.globalQuestsContainer )
		this.UpdateAlert()

		let m = data.points / data.points_to_win || 0

		this.progress.style.width = 500 * m + "px"
	}

	UpdateAlert() {
		if ( this.state === AU_GAME_STATE_PROCESS && this.alertQuest ) {
			this.SetAlert( true )
		} else {
			this.SetAlert( false )
		}
	}

	SetAlert( bool ) {
		this.alertEnabled = bool
		this.alertPanel.SetHasClass( "Visible", bool )

		let now = Game.GetGameTime()

		if ( !this.nextAlertSound || now >= this.nextAlertSound ) {
			this.nextAlertSound = now
		}
	}

	SetInterferenced( bool ) {
		this.questsContainer.visible = !bool
		this.totalTasksCompleted.visible = !bool
	}

	SetQuests( quests, list, container ) {
		let i = 0

		for ( let k in quests ) {
			let quest = quests[k]
			let text = $.Localize( "au_quest_" + quest.name )

			if ( quest.progress != null ) {
				text = text + " (" + quest.progress + "/" + quest.step_count + ")"
			}

			if ( !list[i] ) {
				list[i] = new Quest( container )
			}

			if ( quest.completed ) {
				list[i].SetCompleted( true )

				text = text + " - " + $.Localize( "au_quest_completed" )
			} else {
				list[i].SetCompleted( false )
			}

			if ( quest.sabotage && quest.sabotage.duration != null ) {
				let remaining = 0

				if ( quest.sabotage.stoped == 1 ) {
					list[i].Countdown( quest.sabotage.remaining )
					list[i].SetCoundown( false )
				} else {
					list[i].SetEndTime( quest.sabotage.end_time )
					list[i].SetCoundown( true )
				}
			} else {
				list[i].Countdown( null )
				list[i].SetCoundown( false )
			}
				
			list[i].SetVisible( true )
			list[i].SetText( text )

			i++
		}

		while ( true ) {
			let quest = list[i]

			if ( quest ) {
				quest.SetVisible( false )
			} else {
				break
			}

			i++
		}
	}

	Update( now ) {
		for ( let quest of this.globalQuestsList ) {
			quest.Update( now )
		}

		if ( this.alertEnabled && now >= this.nextAlertSound ) {
			Sounds_.EmitSound( "Game.Alert" )
			this.nextAlertSound = now + 1
		}
	}
}