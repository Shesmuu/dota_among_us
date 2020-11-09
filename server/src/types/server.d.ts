declare type Url = 
	"/api/match/before" |
	"/api/match/after" |
	"/api/players/peace_streaks" |
	"/api/players/report" |
	"/api/players/set_admin" |
	"/api/players/set_peace_streak" |
	"/api/players/set_ban" |
	"/api/players/set_low_priority" |
	"/api/players/add_low_priority"


declare type SqlTableName = 
	"players" |
	"matches" |
	"player_matches"


declare type KV = { [key: string]: any }

declare type SqlKV = { [key: string]: number | string }
declare type SqlCallBack = ( data: any[] ) => void

declare type SteamID = string
declare type SteamIDs = { [key: string]: SteamID }
declare type SteamIDValues = { [key: SteamID]: any }

declare const enum RequestTypes {
	REQUEST_TYPE_GET = 0,
	REQUEST_TYPE_POST = 1
}