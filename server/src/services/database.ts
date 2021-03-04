import mysql from "mysql2/promise"

const server_settings = require( "../../server_settings.js" ) as ServerSettings

const init = ( settings: ServiceSettings ) => {
	settings.db = mysql.createPool( {
		host: server_settings.DB_HOST,
		user: server_settings.DB_USER,
		password: server_settings.DB_PASS,
		database: server_settings.DB_NAME
	} )
}

export { init }