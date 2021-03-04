interface ServerSettings {
	PORT: number
	DB_HOST: string
	DB_PORT: number
	DB_USER: string
	DB_PASS: string
	DB_NAME: string
	DEDICATED_KEY: string
}

type KV = { [key: string]: any }

declare const enum Constants {
	start_reports = 10,
	reports_ban = 8,
	update_reports = 20,
	bans = 10
}

interface ServiceSettings {
	express: Application
	db: PromisePool
}