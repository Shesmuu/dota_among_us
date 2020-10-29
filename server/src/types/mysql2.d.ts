declare module "mysql2" {
	export function createPool( any ): Connection 

	export class Connection {
		query( a: string, b: any[], c: ( err: string, data: any[] ) => void | undefined ): null
	}
}