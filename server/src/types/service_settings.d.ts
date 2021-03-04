import { Application } from "express"
import { Pool } from "mysql2"

interface ServiceSettings {
	express: Application
	db: Pool
}