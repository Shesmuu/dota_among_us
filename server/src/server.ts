import { init as express } from "./services/express"
import { init as database } from "./services/database"
import { init as matches } from "./services/matches"
import { init as players } from "./services/players"
import { init as server } from "./services/server"

import { init_services as init } from "./util/init_services"

init( [
	express,
	database,
	matches,
	players,
	server
] )