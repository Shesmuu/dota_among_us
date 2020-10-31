declare type Url = 
	"/api/match/before" |
	"/api/match/after" 

declare type SqlTableName = 
	"players" |
	"matches" |
	"player_matches"

declare type SqlKV = { [key: string]: number | string }

declare type KV = { [key: string]: any }

declare type SqlCallBack = ( data: any[] ) => void

declare const enum RequestTypes {
	REQUEST_TYPE_GET = 0,
	REQUEST_TYPE_POST = 1
}