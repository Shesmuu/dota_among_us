import express, { Application, Request, Response } from "express"
import http from "http"
import bodyParser from "body-parser"
import serverSettings from "../server_settings"

import { DataBase } from "./components/database"

const Server = new ( class {
	private expressApp: express.Application
	private server: http.Server
	private database: DataBase

	constructor() {
		const port = serverSettings.PORT || 1337

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
					imposter_rating: p.ratingImposter,
					peace_rating: p.ratingPeace,
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
			const heroNames = [
				"npc_dota_hero_zuus",
				"npc_dota_hero_monkey_king",
				"npc_dota_hero_meepo",
				"npc_dota_hero_invoker",
				"npc_dota_hero_rubick",
				"npc_dota_hero_pudge",
				"npc_dota_hero_ember_spirit",
				"npc_dota_hero_morphling",
				"npc_dota_hero_nevermore",
				"npc_dota_hero_storm_spirit",
				"npc_dota_hero_tinker"
			] 
			const sendData: KV = {
				favoriteHeroes: {},
				totalMatches: {}
			}
			const promises = []

			promises.push( new Promise( r => this.database.GetByPlayers( "players", "*", req.body, ( data ) => {
				sendData.players = data
				r( 1 )
			} ) ) )

			promises.push( new Promise( r => this.database.Get( "matches", {
				winner: 0
			}, ( data ) => {
				sendData.peaceWins = data[0] ? data[0]["count( * )"] : 0
				r( 2 )
			}, "count( * )" ) ) )

			promises.push( new Promise( r => this.database.Get( "matches", {
				winner: 1
			}, ( data ) => {
				sendData.imposterWins = data[0] ? data[0]["count( * )"] : 0
				r( 3 )
			}, "count( * )" ) ) )

			let i = 4

			for ( let k in req.body ) {
				let steamID = req.body[k]

				promises.push( new Promise( r => this.database.Get( "player_matches", {
					steam_id: steamID
				}, ( data ) => {
					let favoriteHeroes: KV = {}

					for ( let k in data ) {
						let heroName = data[k].hero_name

						if ( !favoriteHeroes[heroName] ) {
							favoriteHeroes[heroName] = 0
						}

						favoriteHeroes[heroName]++
					}

					let favoriteHero = ""
					let heroMatches = 0

					for ( let heroName in favoriteHeroes ) {
						let c = favoriteHeroes[heroName]

						if ( c > heroMatches ) {
							heroMatches = c

							favoriteHero = heroName
						}
					}

					sendData.favoriteHeroes[steamID] = favoriteHero

					r( i )
				}, "hero_name" ) ) )

				i++

				promises.push( new Promise( r => this.database.Get( "player_matches", {
					steam_id: steamID
				}, ( data ) => {
					sendData.totalMatches[steamID] = data[0]["count( * )"]

					r( i )
				}, "count( * )" ) ) )

				i++

				if ( i > 150 ) {
					break
				}
			}

			Promise.all( promises ).then( ( _ ) => {
				res.send( JSON.stringify( sendData ) )
			} )
		} )

		this.server = http.createServer( this.expressApp )
		this.server.listen( port, () => {
			console.log( "Server is running on " + port + " port" )
		} )
	}

	CheckDedicatedKey( req: Request ): boolean {
		return req.headers.dedicated_server_key === serverSettings.DEDICATED_SERVER_KEY
	}

	Request( url: Url, func: ( req: Request, res: Response ) => any ): void {
		this.expressApp.post( url, ( req: Request, res: Response ) => {
			if ( this.CheckDedicatedKey( req ) ) {
				func( req, res )
			}	
		} )
	}
} )()