import { Request, Response } from "express"
import { Server } from "../server"
import { DataBase } from "./database"

export class Players {
	private server: Server

	public startReports: number = 5
	public needMatchesToUpdateReports: number = 15
	public needReportsToBan: number = 8
	public banMatches: number = 10

	constructor( server: Server ) {
		this.server = server
	}

	AddPlayer( steamID: SteamID, callBack: SqlCallBack | undefined ) {
		this.server.database.Add( "players", {
			steam_id: steamID,
			peace_streak: 0,
			low_priority_: 0,
			imposter_rating: 1000,
			peace_rating: 1000,
			rating: 1000,
			ban: 0,
			reports_remaining: this.startReports,
			toxic_reports: 0,
			party_reports: 0,
			cheat_reports: 0,
			reports_update_countdown: 0,
			admin: 0
		}, callBack )
	}

	AddMissingPlayers( steamIDs: SteamID[], callBack: SqlCallBack ) {
		const missingPlayers: KV = {}

		for ( let k in steamIDs ) {
			missingPlayers[steamIDs[k]] = true
		}

		this.server.database.GetByArray( "players", "steam_id", "steam_id", steamIDs, ( data: SqlKV[] ) => {
			for ( let player of data ) {
				missingPlayers[player.steam_id] = false
			}

			const promises = []

			for ( let steamID in missingPlayers ) {
				if ( missingPlayers[steamID] ) {
					promises.push( new Promise( r => this.AddPlayer( steamID, () => r() ) ) )
				}
			}

			Promise.all( promises ).then( () => {
				callBack( [] )
			} )
		}, false )
	}

	AddLowPriority( steamID: SteamID, count: number ) {
		this.server.database.Get( "players", {
			steam_id: steamID
		}, "low_priority_", ( data ) => {
			this.SetLowPriority( steamID, data[0].low_priority_ + count )
		} )
	}

	SetPlayerCount( steamID: SteamID, count: number, name: string ) {
		const kv: KV = {}
		kv[name] = count
		
		this.server.database.Update( "players", kv, {
			steam_id: steamID
		}, undefined )
	}

	SetLowPriority( steamID: SteamID, count: number ) {
		this.server.database.Update( "players", {
			low_priority_: count
		}, {
			steam_id: steamID
		}, undefined )
	}

	SetPeaceStreak( steamID: SteamID, count: number ) {
		this.server.database.Update( "players", {
			peace_streak: count
		}, {
			steam_id: steamID
		}, undefined )
	}

	UpdatePeaceStreaks( roles: any[] ) {
		this.server.database.GetByArray( "players", "steam_id, peace_streak", "steam_id", roles, ( data ) => {
			for ( let player of data ) {
				const role = roles[player.steam_id]
				let peaceStreak = 0

				if ( role == 0 ) {
					peaceStreak = player.peace_streak + 1
				}

				this.server.database.Update( "players", {
					peace_streak: peaceStreak
				}, {
					steam_id: player.steam_id
				}, undefined )
			}
		}, true )
	}

	AfterMatch( players: any[] ) {
		this.server.database.GetByArray( "players", "*", "steam_id", players, ( data ) => {
			for ( let pData of data ) {
				const p = players[pData.steam_id]
				const roleRating = p.role == 1 ? "imposter_rating" : "peace_rating"
				const updateData: KV = {
					rating: Math.max( pData.rating + p.rating_changes, 0 )
				}

				updateData[roleRating] = Math.max( pData[roleRating] + p.rating_changes, 0 )

				if ( !p.leave_before_death ) {
					if ( p.role == 0 && pData.low_priority_ > 0 ) {
						updateData.low_priority_ = pData.low_priority_ - 1
					}

					if ( pData.ban > 0 ) {
						updateData.ban = pData.ban - 1

						if ( updateData.ban <= 0 ) {
							this.ResetReports( updateData )
						}
					} else {
						if (
							pData.toxic_reports >= this.needReportsToBan ||
							pData.party_reports >= this.needReportsToBan ||
							pData.cheat_reports >= this.needReportsToBan
						) {
							updateData.reports_remaining = 0
							updateData.ban = this.banMatches
							updateData.low_priority_ = pData.low_priority_ + this.banMatches
							updateData.toxic_reports = 0
							updateData.party_reports = 0
							updateData.cheat_reports = 0
						} else {
							const reportUpdateCoundown = pData.reports_update_countdown + 1
					
							if ( reportUpdateCoundown >= this.needMatchesToUpdateReports ) {
								this.ResetReports( updateData )
							} else {
								updateData.reports_update_countdown = reportUpdateCoundown
							}
						}
					}
				}

				this.server.database.Update( "players", updateData, {
					steam_id: pData.steam_id
				}, undefined )
			}
		}, true )
	}

	Report( report: KV, res: Response ) {
		this.server.database.Get( "players", {
			steam_id: report.reporter
		}, "reports_remaining", ( reporterData ) => {
			if ( reporterData[0].reports_remaining > 0 ) {
				this.server.database.Get( "players", {
					steam_id: report.to
				}, report.reason, ( toData ) => {
					const reportsRemaining = reporterData[0].reports_remaining - 1
					const sqlKV: KV = {}
					sqlKV[report.reason] = toData[0][report.reason] + 1

					this.server.database.Update( "players", sqlKV, {
						steam_id: report.to
					}, undefined )

					this.server.database.Update( "players", {
						reports_remaining: reportsRemaining
					}, {
						steam_id: report.reporter
					}, undefined )

					res.send( JSON.stringify( {
						reports_remaining: reportsRemaining
					} ) )
				} )
			} else {
				res.send( JSON.stringify( {
					reports_remaining: 0
				} ) )
			}
		} )
	}

	private ResetReports( data: KV ) {
		data.toxic_reports = 0
		data.party_reports = 0
		data.cheat_reports = 0
		data.reports_remaining = this.startReports
		data.reports_update_countdown = 0
	}
}