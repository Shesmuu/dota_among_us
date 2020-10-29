/// <reference path="../types/mysql2.d.ts" />

import mySql from "mysql2"

export class DataBase {
	private connection: mySql.Connection

	constructor() {
		this.connection = mySql.createPool( {
			host: "localhost",
			user: "root",
			password: "",
			database: "shsm_among_us"
		} )

		console.log( "DataBase created" )
	}

	Add( tN: SqlTableName, row: SqlKV ): void {
		let a: any[] = []
		let str: string = "insert into " + tN + " ( "
		let vStr: string = " values ( "
		let preStr: string = ""

		for ( let k in row ) {
			vStr += preStr + "?"
			str += preStr + k
			preStr = ", "
			a.push( row[k] )
		}

		str += " )" + vStr + " )"

		this.Query( str, a )
	}

	Update( tN: SqlTableName, where: SqlKV, row: SqlKV ): void {
		this.Get( tN, where, ( data: any[] ) => {
			if ( data[0] && data[0]["count(*)"] > 0 ) {
				let str: string = "update " + tN + " set "
				let preStr: string = ""

				for ( let k in row ) {
					str += preStr + k + "=" + row[k]
					preStr = ", "
				}

				str += this.WhereString( where )

				this.Query( str, [] )
			} else {
				this.Add( tN, row )
			}
		}, "count(*)" )
	}

	Get( tN: SqlTableName, where: SqlKV, func?: SqlCallBack, what?: string ): void {
		this.Query( "select " + ( what || "*" ) + " from " + tN + this.WhereString( where ), [], func )
	}

	private Query( str: string, a: any[], func?: SqlCallBack ): void {
		this.connection.query( str, a, ( err: string, data: any[] ) => {
			if ( err ) {
				console.log( err )
			} else if ( func && data ) {
				func( data )
			}
		} )
	}

	private WhereString( where: SqlKV ): string {
		let str: string = " where "
		let preStr: string = ""

		for ( let k in where ) {
			str += preStr + k + "=" + where[k]
			preStr = " and "
		}

		return str
	}
}