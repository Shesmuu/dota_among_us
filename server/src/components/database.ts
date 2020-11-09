/// <reference path="../types/mysql2.d.ts" />

import mySql from "mysql2"
import { Server } from "../server"

const serverSettings = require( "../../server_settings" ) as KV

export class DataBase {
	private connection: mySql.Connection
	private server: Server

	constructor( server: Server ) {
		this.server = server

		this.connection = mySql.createPool( {
			host: serverSettings.DB_HOST,
			user: serverSettings.DB_USER,
			password: serverSettings.DB_PASS,
			database: serverSettings.DB_NAME
		} )

		console.log( "DataBase created" )
	}

	Add( tN: SqlTableName, row: SqlKV, func: SqlCallBack | undefined ): void {
		const a: any[] = []
		let str: string = "insert into " + this.KQuotes( tN ) + " ( "
		let vStr: string = " values ( "
		let preStr: string = ""

		for ( let k in row ) {
			vStr += preStr + "?"
			str += preStr + this.KQuotes( k )
			preStr = ", "
			a.push( row[k] )
		}

		str += " )" + vStr + " )"

		this.Query( str, a, func )
	}

	Update( tN: SqlTableName, row: SqlKV, where: SqlKV, func: SqlCallBack | undefined ): void {
		const a: any[] = []
		let str: string = "update " + this.KQuotes( tN ) + " set "
		let preStr: string = ""

		for ( let k in row ) {
			str += preStr + this.KQuotes( k ) + "=?"
			preStr = ", "
			a.push( row[k] )
		}

		str += this.WhereString( where, a )

		this.Query( str, a, func )
	}

	Get( tN: SqlTableName, where: SqlKV, what: string, func: SqlCallBack ): void {
		const a: any[] = []
		this.Query( "select " + what + " from " + this.KQuotes( tN ) + this.WhereString( where, a ), a, func )
	}

	GetByArray( tN: SqlTableName, what: string, value: string, arr: any[], func: SqlCallBack, ofKey: boolean ): void {
		const a: any[] = []
		let str = "select " + what + " from " + tN + " where "
		let preStr = ""

		for ( let k in arr ) {
			let steamID = arr[k]
			str += preStr + value + "=?"
			preStr = " or "
			a.push( ofKey ? k : steamID )
		}

		this.Query( str, a, func )
	}

	Query( str: string, a: any[], func: SqlCallBack | undefined ): void {
		this.connection.query( str, a, ( err: string, data: any[] ) => {
			if ( err ) {
				console.log( err )
			} else if ( func && data ) {
				func( data )
			}
		} )
	}

	private KQuotes( s: string ) : string {
		return s
	}

	private WhereString( where: SqlKV, arr: any[] ): string {
		let str: string = " where "
		let preStr: string = ""

		for ( let k in where ) {
			str += preStr + this.KQuotes( k ) + "=?"
			preStr = " and "
			arr.push( where[k] )
		}

		return str
	}
}