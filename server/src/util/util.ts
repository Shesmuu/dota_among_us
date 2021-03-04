import { Response } from "express"

const request_error = ( res: Response, message: string, status?: number ) => {
	res.status( 500 || status ).send( message )

	throw( message )
}

export { request_error }