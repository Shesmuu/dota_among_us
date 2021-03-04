//import { ServiceSettings } from "../types/service_settings"

const init_services = ( services: Array<( settings: ServiceSettings ) => void> ) => {
	const settings = {} as ServiceSettings

	for ( let init of services ) {
		init( settings )
	}
}

export { init_services }