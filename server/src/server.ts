import express, { Application, Request, Response } from "express"
import http from "http"
import bodyParser from "body-parser"

import { DataBase } from "./components/database"

const Server = new ( class {
	private expressApp: express.Application
	private server: http.Server
	private database: DataBase

	constructor() {
		const port = process.env.PORT || 1337

		this.expressApp = express()
		this.expressApp.use( bodyParser() )
		this.database = new DataBase()

		this.Request( "/api/match/after", ( req: Request, res: Response ) => {
			let matchData = {
				match_id: req.body.matchID,
				duration: req.body.duration,
				winner: req.body.role,
				win_reason: req.body.reason
			}

			this.database.Add( "matches", matchData )

			for ( let localID in req.body.players ) {
				let p = req.body.players[localID]

				this.database.Update( "players", {
					steam_id: p.steamID
				}, {
					steam_id: p.steamID,
					low_priority_: p.low_priority,
					peace_streak: p.peace_streak,
					rating: p.rating
				} )

				this.database.Add( "player_matches", {
					match_id: req.body.matchID,
					steam_id: p.steamID,
					hero_name: p.heroName,
					role: p.role,
					kills: p.kills,
					imposter_votes: p.imposterVotes,
					rank: p.rank,
					role_rank: p.roleRank,
					killed: p.killed ? 1 : 0,
					kicked: p.kicked ? 1 : 0,
					rating_changes: 0,
					leave_before_death: p.leaveBeforeDeath ? 1 : 0
				} )
			}

			res.send( "" )
		} )

		this.Request( "/api/match/before", ( req: Request, res: Response ) => {
			const promises = []

			for ( let k in req.body ) {
				const p = req.body[k]

				promises.push( new Promise( r => this.database.Get( "players", {
					steam_id: p
				}, ( data: any[] ) => {
					r( data[0] )
				} ) ) )
			}

			Promise.all( promises ).then( ( data ) => {
				res.send( JSON.stringify( data ) )
			} )
		} )

		this.server = http.createServer( this.expressApp )
		this.server.listen( port, () => {
			console.log( "Server is running on " + port + " port" )
		} )
	}

	CheckDedicatedKey( req: Request ): boolean {
		return req.headers.dedicated_server_key === "AllHailLelouch"
	}

	Request( url: Url, func: ( req: Request, res: Response ) => any ): void {
		this.expressApp.post( url, ( req: Request, res: Response ) => {
			if ( this.CheckDedicatedKey( req ) ) {
				func( req, res )
			}	
		} )
	}
} )()