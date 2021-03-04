import { Request, Response } from "express"

const init = ( settings:ServiceSettings ) => {
	settings.express.post( "/api/leaderboard", async ( req: Request, res: Response ) => {
		const [data] = await settings.db.query( "select `steam_id`, `rating` from `players` order by `rating` desc limit 0, 50" )
		res.send( JSON.stringify( data ) )
	} )
	
	settings.express.post( "/api/players/report", async ( req: Request, res: Response ) => {
		const [reporter] = await settings.db.query(
			"select `reports_remaining` from `players` where `steam_id`=(?)",
			[req.body.reporter]
		)

		const [reported] = await settings.db.query(
			"select (?) from `players` where `steam_id`=(?)",
			[req.body.reason, req.body.to]
		)

		const reports_remaining = reporter[0].reports_remaining
	
		if ( reports_remaining > 0 ) {
			settings.db.query(
				"update `players` set `reports_remaining`=(?) where `steam_id`=(?)",
				[reports_remaining - 1, req.body.reporter]
			)

			settings.db.query(
				"update `players` set " + req.body.reason + " = " + req.body.reason + " + 1 where `steam_id` = (?)",
				[req.body.to]
			)
	
			res.send( JSON.stringify( {
				reports_remaining: reports_remaining - 1
			} ) )
		} else {
			res.send( JSON.stringify( {
				reports_remaining: 0
			} ) )
		}
	} )

	settings.express.post( "/api/players/add_low_priority", ( req: Request, res: Response ) => {
		settings.db.query(
			"update `players` set `low_priority_` = `low_priority_` + (?) where `steam_id` = (?)",
			[req.body.count, req.body.steam_id]
		)

		res.send( {} )
	} )

	settings.express.post( "/api/players/set_low_priority", ( req: Request, res: Response ) => {
		settings.db.query(
			"update `players` set `low_priority_` = (?) where `steam_id` = (?)",
			[req.body.count, req.body.steam_id]
		)

		res.send( {} )
	} )

	settings.express.post( "/api/players/set_ban", ( req: Request, res: Response ) => {
		settings.db.query(
			"update `players` set `ban` = (?) where `steam_id`=(?)",
			[req.body.count, req.body.steam_id]
		)

		res.send( {} )
	} )

	settings.express.post( "/api/players/set_peace_streak", ( req: Request, res: Response ) => {
		settings.db.query(
			"update `players` set `peace_streak` = (?) where `steam_id`=(?)",
			[req.body.count, req.body.steam_id]
		)

		res.send( {} )
	} )

	settings.express.post( "/api/players/peace_streaks", ( req: Request, res: Response ) => {
		const nulify = []
		const increase = []

		for ( let steam_id in req.body ) {
			if ( req.body[steam_id] === 1 ) {
				nulify.push( steam_id )
			} else {
				increase.push( steam_id )
			}
		}

		if ( increase.length > 0 ) {
			settings.db.query( "update `players` set `peace_streak` = (`peace_streak` + 1) where `steam_id` in (?)", [increase] )
		}

		if ( increase.length > 0 ) {
			settings.db.query( "update `players` set `peace_streak` = 0 where `steam_id` in (?)", [nulify] )
		}

		res.send( {} )
	} )
}

export { init }