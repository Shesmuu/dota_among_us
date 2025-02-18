_G.Debug = {
	errorHistrory = {}
}

function Debug:F( f )
	return function( ... )
		return self:Execute( f, ... )
	end
end

function Debug:Print( ... )
	local str = ""

	for k, v in pairs( { ... } ) do
		str = str .. tostring( v ) .. "\t"
	end

	print( str )

	Debug:Log( str )
end

function Debug:Log( str )
	table.insert( Debug.errorHistrory, str )

	CustomNetTables:SetTableValue( "debug", "errors", Debug.errorHistrory )
end

function Debug:Execute( f, ... )
	local args = { ... }
	local _, result = xpcall( function()
		return f( unpack( args ) )
	end, self.Error )

	return result
end

function Debug.Error( msg )
	local err = "Error: " .. msg .. "\n" .. debug.traceback() .. "\n"

	print( err )

	Debug:Log( err )
end