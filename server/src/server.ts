import express, { Application, Request, Response } from "express"
import http from "http"
import bodyParser from "body-parser"

import { DataBase } from "./components/database"
import { Matches } from "./components/matches"
import { Players } from "./components/players"

const serverSettings = require( "../server_settings" ) as KV

export class Server {
	private expressApp: express.Application
	private server: http.Server
	public database: DataBase
	public matches: Matches
	public players: Players

	constructor() {
		this.expressApp = express()
		this.expressApp.use( bodyParser() )
		this.database = new DataBase( this )
		this.matches = new Matches( this )
		this.players = new Players( this )

		this.expressApp.post( "/api/leaderboard", ( req: Request, res: Response ) => {
			this.database.Query( "select steam_id, rating from players order by rating desc limit 0, 50", [], ( data ) => {
				res.send( JSON.stringify( data ) )
			} )
		} )

		this.DedicatedRequest( "/api/match/after", ( req: Request, res: Response ) => {
			this.matches.After( req, res )
		} )

		this.DedicatedRequest( "/api/match/before", ( req: Request, res: Response ) => {
			this.matches.Before( req, res )
		} )

		this.DedicatedRequest( "/api/players/set_admin", ( req: Request, res: Response ) => {
			let admin = req.body.count > 0 ? 1 : 0

			this.players.SetPlayerCount( req.body.steam_id, admin, "admin" )
			res.send( "" )
		} )

		this.DedicatedRequest( "/api/players/set_ban", ( req: Request, res: Response ) => {
			this.players.SetPlayerCount( req.body.steam_id, req.body.count, "ban" )
			res.send( "" )
		} )

		this.DedicatedRequest( "/api/players/set_peace_streak", ( req: Request, res: Response ) => {
			this.players.SetPlayerCount( req.body.steam_id, req.body.count, "peace_streak" )
			res.send( "" )
		} )

		this.DedicatedRequest( "/api/players/set_low_priority", ( req: Request, res: Response ) => {
			this.players.SetPlayerCount( req.body.steam_id, req.body.count, "low_priority_" )
			res.send( "" )
		} )

		this.DedicatedRequest( "/api/players/add_low_priority", ( req: Request, res: Response ) => {
			this.players.AddLowPriority( req.body.steam_id, req.body.count )
			res.send( "" )
		} )

		this.DedicatedRequest( "/api/players/peace_streaks", ( req: Request, res: Response ) => {
			this.players.UpdatePeaceStreaks( req.body )
			res.send( "" )
		} )

		this.DedicatedRequest( "/api/players/report", ( req: Request, res: Response ) => {
			this.players.Report( req.body, res )
		} )

		this.server = http.createServer( this.expressApp )
		this.server.listen( serverSettings.PORT, () => {
			console.log( "Server is running on " + serverSettings.PORT + " port" )
		} )
	}

	CheckDedicatedKey( req: Request ): boolean {
		return req.headers.dedicated_server_key === serverSettings.DEDICATED_SERVER_KEY
	}

	DedicatedRequest( url: Url, func: ( req: Request, res: Response ) => any ): void {
		this.expressApp.post( url, ( req: Request, res: Response ) => {
			if ( this.CheckDedicatedKey( req ) ) {
				func( req, res )
			}	
		} )
	}
}

const server = new Server()