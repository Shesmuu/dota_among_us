import express, { Request, Response } from "express"
import bodyParser from "body-parser"

const init = ( settings: ServiceSettings ) => {
	const { DEDICATED_KEY } = require( "../../server_settings" )

	settings.express = express()
	settings.express.use( bodyParser() )
	//settings.express.use( bodyParser.json() )
	//settings.express.use( bodyParser.urlencoded( { extended: false } ) )
	settings.express.use( ( req: Request, res: Response, next: any ) => {
		if (
			req.headers.dedicated_server_key === DEDICATED_KEY ||
			req.method === "GET" ||
			req.url === "/api/leaderboard"
		) {
			next()
		}
	} )
}

export { init }