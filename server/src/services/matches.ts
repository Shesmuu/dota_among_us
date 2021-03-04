import { Request, Response } from "express"

//SELECT COUNT(`player_matches`.`id`) FROM `player_matches` INNER JOIN `matches` ON `matches`.`winner` = `player_matches`.`role` AND `matches`.`match_id` = player_matches.match_id WHERE `player_matches`.`steam_id` LIKE "%565101" LIMIT 0, 10

//select `hero_name`, count(`hero_name`) as `kekw` from `player_matches` WHERE steam_id in (76561199018565101) GROUP by `hero_name` order by `kekw` desc Limit 0, 40

//select `hero_name`, count(`hero_name`) as `kekw` from `player_matches` WHERE id > 500000 GROUP by `hero_name` order by `kekw`

//select `hero_name`, count(`hero_name`) as `kekw` from `player_matches` WHERE id > 500000 GROUP and role = 1 by `hero_name` order by `kekw`

//select `player_matches`.`hero_name`, count(`player_matches`.`hero_name`) as `kekw` from `player_matches` inner join `matches` on `matches`.`match_id` = `player_matches`.`match_id` and `matches`.`winner` = 1 WHERE `player_matches`.`id` > 500000 and `player_matches`.`role` = 1 GROUP by `player_matches`.`hero_name` order by `kekw`

const init = ( settings:ServiceSettings ) => {
	const reset_reports = ( data: KV ) => {
		data.toxic_reports = 0
		data.party_reports = 0
		data.cheat_reports = 0
		data.reports_remaining = Constants.start_reports
		data.reports_update_countdown = 0
	}

	const promise_query = ( promises: Promise<void>[], sql: string, arr: any[], callback: ( arr: any[] ) => void ) => {
		promises.push( new Promise( async ( resolve, eject ) => {
			try {
				const [data] = await settings.db.query( sql, arr )
				callback( data )
				resolve()
			} catch( error: unknown ) {
				eject( error )
			}
		} ) )
	}

	const insert_into = async ( table: string, kv: KV ) => {
		const values = []
		let columns = " ("
		let comma = ""

		for ( let key in kv ) {
			columns += comma + key
			values.push( kv[key] )
			comma = ", "
		}

		await settings.db.query( "insert into " + table + columns + ") values (?)", [values] )
	}

	const update_player = async ( table: string, kv: KV, steam_id: string ) => {
		const values = []
		let columns = ""
		let comma = ""

		for ( let key in kv ) {
			columns += comma + key + " = (?)"
			values.push( kv[key] )
			comma = ", "
		}

		values.push( steam_id )

		await settings.db.query( "update " + table + " set " + columns + " where `steam_id` = (?)", values )
	}

	const add_player = async ( steam_id: string ) => {
		await insert_into( "players", {
			steam_id: steam_id,
			peace_streak: 0,
			low_priority_: 0,
			imposter_rating: 1000,
			peace_rating: 1000,
			rating: 1000,
			ban: 0,
			reports_remaining: Constants.start_reports,
			toxic_reports: 0,
			party_reports: 0,
			cheat_reports: 0,
			reports_update_countdown: 0,
			admin: 0
		} )
	}

	settings.express.post( "/api/match/before", async ( req: Request, res: Response ) => {
		//const START_TIME = new Date().getTime()

		const [players_present] = await settings.db.query(
			"select `steam_id` from `players` where `steam_id` in (?)",
			[req.body]
		)

		for ( let steam_id of req.body ) {
			let has = false

			for ( let pp of players_present ) {
				if ( steam_id == pp.steam_id ) {
					has = true
					break
				}
			}

			if ( !has ) {
				await add_player( steam_id )
			}
		}

		const promises = []
		const send_data: KV = {
			favoriteHeroes: {},
			totalMatches: {},
			totalWins: {}
		}

		promises.push( settings.db.query( "select `winner`, COUNT(`winner`) as 'count' FROM `matches` where `id` > 57192 group by `winner`" ) )
		promises.push( settings.db.query( "select * from `players` where `steam_id` in (?)", [req.body] ) )

		for ( let steam_id of req.body ) {
			promise_query(
				promises,
				"select `hero_name`, count(`hero_name`) as 'count' from `player_matches` where `steam_id` = (?) group by `hero_name` order by `count` desc",
				[steam_id],
				( [favorite] ) => {
					if ( favorite ) {
						send_data.favoriteHeroes[steam_id] = favorite.hero_name
					}
				}
			)

			//promise_query(
			//	promises,
			//	"select `hero_name` from `player_matches` where `steam_id` = (?)",
			//	[steam_id],
			//	( heroes: any[] ) => {
			//		let fav_hero: string | undefined = undefined
			//		let fav_count = 0
			//		const counts: KV = {}

			//		for ( let row of heroes ) {
			//			counts[row.hero_name] = counts[row.hero_name] ? counts[row.hero_name] + 1 : 1
			//		}

			//		for ( let hero_name in counts ) {
			//			const count = counts[hero_name]

			//			if ( count > fav_count ) {
			//				fav_hero = hero_name
			//				fav_count = count
			//			}
			//		}

			//		send_data.favoriteHeroes[steam_id] = fav_hero
			//	}
			//)

			promise_query(
				promises,
				"select count(*) as 'count' from `player_matches` where `steam_id` = (?)",
				[steam_id],
				( [count] ) => {
					send_data.totalMatches[steam_id] = count.count
				}
			)

			//promise_query(
			//	promises,
			//	"select count(`id`) as 'count' from `player_matches` where `steam_id` = (?)",
			//	[steam_id],
			//	( [count] ) => {
			//		send_data.totalMatches[steam_id] = count.count
			//	}
			//)

			promise_query(
				promises,
				"select count(`player_matches`.`id`) as 'count' from `player_matches` inner join `matches` on `matches`.`winner` = `player_matches`.`role` and `player_matches`.`match_id` = `matches`.`match_id` where `steam_id` = (?)",
				[steam_id],
				( [count] ) => {
					send_data.totalWins[steam_id] = count.count
				}
			)
		}

		Promise.all( promises ).then( ( [[winrates], [players]]: any ) => {
			let imposter_wins = 0
			let peace_wins = 0

			for ( let o of winrates ) {
				if ( o.winner === 0 ) {
					peace_wins = o.count
				} else if ( o.winner === 1 ) {
					imposter_wins = o.count
				}
			}

			send_data.imposterWins = imposter_wins
			send_data.peaceWins = peace_wins

			send_data.players = players
			res.send( send_data )
			//console.log( "duration:", new Date().getTime() - START_TIME )
		} )
	} )

	settings.express.post( "/api/match/after", async ( req: Request, res: Response ) => {
		const steam_ids = []
		const match = {
			match_id: req.body.matchID,
			duration: req.body.duration,
			winner: req.body.role,
			win_reason: req.body.reason
		}

		insert_into( "matches", match )

		for ( let steam_id in req.body.players ) {
			const p = req.body.players[steam_id]

			steam_ids.push( steam_id )

			insert_into( "player_matches", {
				match_id: req.body.matchID,
				steam_id: steam_id,
				hero_name: p.hero_name,
				role: p.role,
				kills: p.kills,
				imposter_votes: p.imposter_votes,
				rank: p.rank,
				role_rank: p.role_rank,
				killed: p.killed ? 1 : 0,
				kicked: p.kicked ? 1 : 0,
				rating_changes: p.leave_before_death,
				leave_before_death: p.leave_before_death ? 1 : 0
			} )
		}

		const [players] = await settings.db.query( "select * from `players` where `steam_id` in (?)", [steam_ids] )

		for ( let player of players ) {
			const p = req.body.players[player.steam_id]
			const role_rating = p.role == 1 ? "imposter_rating" : "peace_rating"
			const data: KV = {
				rating: Math.max( player.rating + p.rating_changes, 0 )
			}

			data[role_rating] = Math.max( player[role_rating] + p.rating_changes, 0 )

			if ( !p.leave_before_death ) {
				if ( p.role == 0 && player.low_priority_ > 0 ) {
					data.low_priority_ = player.low_priority_ - 1
				}

				if ( player.ban > 0 ) {
					data.ban = player.ban - 1

					if ( data.ban <= 0 ) {
						reset_reports( data )
					}
				} else {
					if (
						player.toxic_reports >= Constants.reports_ban ||
						player.party_reports >= Constants.reports_ban ||
						player.cheat_reports >= Constants.reports_ban
					) {
						data.reports_remaining = 0
						data.ban = Constants.bans
						//data.low_priority_ = player.low_priority_ + this.banMatches
						data.toxic_reports = 0
						data.party_reports = 0
						data.cheat_reports = 0
					} else {
						const countdown = player.reports_update_countdown + 1
				
						if ( countdown >= Constants.update_reports ) {
							reset_reports( data )
						} else {
							data.reports_update_countdown = countdown
						}
					}
				}
			}

			await update_player( "players", data, player.steam_id )
		}

		res.send( {} )
	} )
}

export { init }