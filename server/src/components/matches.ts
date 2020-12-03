import { Request, Response } from "express"
import { Server } from "../server"
import { DataBase } from "./database"

export class Matches {
	private server: Server

	constructor( server: Server ) {
		this.server = server
	}

	Before( req: Request, res: Response ) {
		this.server.players.AddMissingPlayers( req.body, () => {
			const sendData: KV = {
				favoriteHeroes: {},
				totalMatches: {}
			}
			const promises = []

			promises.push( new Promise( r => this.server.database.GetByArray( "players", "*", "steam_id", req.body, ( data ) => {
				sendData.players = data

				r()
			}, false ) ) )

			promises.push( new Promise( r => this.server.database.Query( "select count(*) from `matches` where winner=1 and id>29684", [], ( data ) => {
				sendData.imposterWins = data[0] ? data[0]["count(*)"] : 0

				r()
			} ) ) )

			promises.push( new Promise( r => this.server.database.Query( "select count(*) from `matches` where winner=0 and id>29684", [], ( data ) => {
				sendData.peaceWins = data[0] ? data[0]["count(*)"] : 0

				r()
			} ) ) )

			for ( let k in req.body ) {
				let steamID = req.body[k]

				promises.push( new Promise( r => this.server.database.Get( "player_matches", {
					steam_id: steamID
				}, "hero_name", ( data ) => {
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

					r()
				} ) ) )

				promises.push( new Promise( r => this.server.database.Get( "player_matches", {
					steam_id: steamID
				}, "count( * )", ( data ) => {
					sendData.totalMatches[steamID] = data[0]["count( * )"]

					r()
				} ) ) )
			}

			Promise.all( promises ).then( ( _ ) => {
				res.send( JSON.stringify( sendData ) )
			} )
		} )
	}

	After( req: Request, res: Response ) {
		let matchData = {
			match_id: req.body.matchID,
			duration: req.body.duration,
			winner: req.body.role,
			win_reason: req.body.reason
		}

		this.server.database.Add( "matches", matchData, undefined )

		for ( let steamID in req.body.players ) {
			let p = req.body.players[steamID]

			this.server.database.Add( "player_matches", {
				match_id: req.body.matchID,
				steam_id: steamID,
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
			}, undefined )
		}

		this.server.players.AfterMatch( req.body.players )

		res.send( "" )
	}
}