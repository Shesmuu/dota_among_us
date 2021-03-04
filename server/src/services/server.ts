//import { ServiceSettings } from "../types/service_settings"
import http from "http"

const server_settings = require( "../../server_settings.js" ) as ServerSettings

const init = ( settings: ServiceSettings ) => {
	const server = http.createServer( settings.express )
	server.listen( server_settings.PORT, () => console.log( "Server is running" ) )
}

export { init }