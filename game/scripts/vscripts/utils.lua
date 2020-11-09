function CreateEventUnit( unitName, pos, func, radius )
	local unit = CreateUnitByName( unitName, pos, false, nil, nil, AU_DUMMIES_TEAM )
	local modifier = unit:AddNewModifier( unit, nil, "modifier_au_aura", nil )

	unit.event = func
	modifier.radius = radius or 250
	modifier.modifierAura = "modifier_au_unit_event"

	return unit
end

function StringToArray( str )
	local t = {}
	local i = 1

	for s in string.gmatch( str, "([^%s]+)" ) do
		t[i] = s
		i = i + 1
	end

	return t
end

function MathRound( n )
    local abs = math.abs( n )
	local a = abs - math.floor( abs )
	local d = ( n / abs )

	if a > 0.5 then
		return math.ceil( abs ) * d
	else
		return math.floor( abs ) * d
	end
end

function Add( t, o )
	local i = 1

	while true do
		if not t[i] then
			break
		end

		i = i + 1
	end

	t[i] = o

	return i
end

function RemoveFrom( t, value )
	for k, v in pairs( t ) do
		if v == value then
			table.remove( t, k )

			break
		end
	end
end

function Delay( t, f )
	return Add( GameMode.timers, {
		endTime = GameRules:GetGameTime() + t,
		func = f
	} )
end

function ListenToClient( n, f, context, id )
	return CustomGameEventManager:RegisterListener( n, function( _, data )
		if id and id ~= data.PlayerID then
			return
		end

		f( context, data )
	end )
end

function Projectile( from, to, effect, speed )
	local projectile = {
		Target = to,
		Source = from,
		EffectName = effect,
		iMoveSpeed = speed,
		vSourceLoc = from:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = false,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false
	}

	ProjectileManager:CreateTrackingProjectile( projectile )
end

function IsTest()
	return GameRules:IsCheatMode() or IsInToolsMode()
end