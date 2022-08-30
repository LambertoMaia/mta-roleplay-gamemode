function characterExitVehicle(vehicle, seat)
	-- Handles user leaving vehicle
	--
	-- Save vehicle position
	local x,y,z 	= getElementPosition(source)
	local rx,ry,rz 	= getElementRotation(source)

	local position = '['..x..','..y..','..z..']'
	local rotation = '['..rx..','..ry..','..rz..']'

	local fuel = tonumber(vehicle:getData('vehicle:fuel'))

	local health = getElementHealth(vehicle)

	local vehicle_id = vehicle:getData('vehicle:id')

	-- Check if ped is the driver
	if seat == 0 then
		local data = {}

		if fuel < 0 then
			fuel = 0
		end

		data['position'] = position
		data['rotation'] = rotation
		data['fuel']	 = fuel
		data['health']	 = health

		local update = exports['aprp-database']:quickUpdate('vehicles', data, 'id', vehicle_id)

		if not update[1] then
			outputDebugString('Error while updating the vehicle location')
			outputDebugString(position .. ' - ' .. rotation)
			outputDebugString('Vehicle ID: ' .. tostring(vehicle_id))
		end
	end
	-- Removing the engine command
	removeCommandHandler('engine', toggleEngine)
	removeCommandHandler('seatbelt', toggleSeatbelt)
	-- Unbind the key
	unbindKey(source, 'j', 'down', toggleEngine)
	unbindKey(source, 'l', 'down', toggleLights) -- Toggles vehicle lights
	unbindKey(source, 'k', 'down', lockVehicle)
	-- Trigger client event to stop displaying the fuel
	triggerClientEvent('_ServerFuelStop_', root)
end
addEventHandler('onPlayerVehicleExit', root, characterExitVehicle)

function startExitVeh(player)
	removeSeatBelt(player)
end
addEventHandler('onVehicleStartExit', root, startExitVeh)

function characterEnterVehicle(vehicle, seat)
	-- Handles user entering the vehicle
	--
	-- Getting vehicle engine status
	local engine_status = vehicle:getData('vehicle:engine')

	-- Getting vehicle lights status
	local lights_status = vehicle:getData('vehicle:lights')

	-- Getting handbrake status
	local handbrake_status = tonumber(vehicle:getData('vehicle:handbrake'))

	-- Setting lights status
	if lights_status then
		-- Lights on, keeping them on
		vehicle:setOverrideLights(2)
	else
		vehicle:setOverrideLights(1)
	end

	-- Setting the engine status to the last known engine status
	vehicle:setEngineState(engine_status)

	-- Getting the seat
	local vehicle_seat = getPedOccupiedVehicleSeat(source)

	-- Check if engine is off and send a message
	if not engine_status and vehicle_seat == 0 then
		outputChatBox('Engine is off, type /engine or press J to start the engine', source, 255, 255, 255)
	else 
		triggerClientEvent('_ServerFuelStart_', root)
	end

	if handbrake_status == 1 then
		outputChatBox('The handbrake is active, type /handbrake to lower it', source, 255, 255, 255)
	end
	-- Adding the command handler
	addCommandHandler('engine', toggleEngine)
	addCommandHandler('seatbelt', toggleSeatbelt)
	
	if not isKeyBound(source, 'j') then
		bindKey(source, 'j', 'down', toggleEngine) -- Toggles vehicle engine
		bindKey(source, 'l', 'down', toggleLights) -- Toggles vehicle lights
		bindKey(source, 'k', 'down', lockVehicle)  -- Toggles vehicle lock
	end
end
addEventHandler('onPlayerVehicleEnter', root, characterEnterVehicle)

function characterStartEnter(vehicle, seat)
	-- Handles events before the user enter
	--
end
addEventHandler('onVehicleStartEnter', root, characterStartEnter)

local attemptingStart = {}

function attemptStart(vehicle, player)
	if attemptingStart[vehicle] then
		-- It has timer already
		return
	end

	-- No timer
	local timer = setTimer(attemptEngineStart, 3000, 1, vehicle, player)

	attemptingStart[vehicle] = timer

	outputChatBox('Attempting to start the engine...', player, 255, 255, 0)

end

function attemptEngineStart(vehicle, player)
	local random = math.random(0, 1)

	if random == 1 then
		-- Engine start
		vehicle:setData('vehicle:engine', true)
		vehicle:setEngineState(true)
		outputChatBox('Engine started!', player, 0, 255, 0)
		attemptingStart[vehicle] = nil
		triggerEvent('_ServerPlayerEngineStart', root, vehicle, player)
		exports['aprp-vehicles']:startRandomStall(vehicle)
		return
	end

	outputChatBox('The engine could not be started due to heavy damges in it', player, 255, 0, 0)

	attemptingStart[vehicle] = nil
end



function toggleEngine(player, command)
	-- Toggles the current vehicle engine
	--
	if isPedInVehicle(player) then
		local player_seat = player:getOccupiedVehicleSeat()
		local vehicle     = player:getOccupiedVehicle()

		local vehicle_fuel = vehicle:getData('vehicle:fuel')

		-- Check if the engine is stalled by damage
		local engine_stall = vehicle:getData('vehicle:engineLock')

		if engine_stall then
			outputChatBox('The vehicle engine is too damaged to be started!', player, 255, 0, 0)
			return
		end

		local vehicle_damaged = vehicle:getData('vehicle:damaged')

		if vehicle_damaged and not vehicle:getData('vehicle:engine') then
			-- Attempt to start
			attemptStart(vehicle, player)
			return
		end

		local update = {}

		update['fuel'] = vehicle_fuel
		exports['aprp-database']:quickUpdate('vehicles', update, 'id', vehicle:getData('vehicle:id'))

		if player_seat == 0 then
			-- Player is driving the vehicle
			-- Toggle the engine
			local engine_status = vehicle:getData('vehicle:engine')

			if engine_status then
				-- Engine is running, shutting it off
				outputChatBox('Engine is now off', player, 0, 255, 0)
				vehicle:setData('vehicle:engine', false)
				vehicle:setData('vehicle:consumingFuel', false)
				vehicle:setEngineState(false)
				triggerEvent('_ServerPlayerEngineStop_', root, vehicle)
				triggerClientEvent('_ServerFuelStop_', root)
				exports['aprp-vehicles']:stopRandomStall(vehicle)
				exports['aprp-vehicles']:randomPowerStop(vehicle)
				-- Check if the lights are on
				if vehicle:getData('vehicle:lights') then
					triggerClientEvent('_VehicleSFXPlay3D_', root, 'door_chime', vehicle, true)
				end
			else
				-- Engine is off, turning it on
				-- Shutting the door chime off
				triggerClientEvent('_VehicleSFXStop3D_', root, vehicle)
				outputChatBox('Engine is now running', player, 0, 255, 0)
				vehicle:setData('vehicle:engine', true)
				vehicle:setEngineState(true)
				triggerEvent('_ServerPlayerEngineStart', root, vehicle, player)
				exports['aprp-vehicles']:startRandomStall(vehicle)
				exports['aprp-vehicles']:randomPower(vehicle)
			end
		else
			outputChatBox('You must be driving this vehicle to turn the engine', player, 255, 0, 0)
		end
	else
		outputChatBox('You must be inside a vehicle to use this command', player, 255, 0, 0)
	end
end


function toggleLights(player, command)
	-- Toggles vehicle lights
	--
	local vehicle      = player:getOccupiedVehicle()
	local player_seat  = player:getOccupiedVehicleSeat()

	if isPedInVehicle(player) then
		-- Check if player is the driver
		if player_seat == 0 then
			local lights_status = vehicle:getData('vehicle:lights')

			if lights_status then
				-- Lights on, turning off
				vehicle:setOverrideLights(1)
				vehicle:setData('vehicle:lights', false)
				-- Check if engine is running
				if not vehicle:getData('vehicle:engine') then
					triggerClientEvent('_VehicleSFXStop3D_', root, vehicle)
				end
			else
				-- Lights off, turning on
				vehicle:setOverrideLights(2)
				vehicle:setData('vehicle:lights', true)
				-- Check if engine is stopped
				if not vehicle:getData('vehicle:engine') then
					triggerClientEvent('_VehicleSFXPlay3D_', root, 'door_chime', vehicle, true)
				end
			end
		else
			outputChatBox('You must be driving to use this command', player, 255, 0, 0)
		end
	else
		outputChatBox('You must be inside a vehicle to use this command', player, 255, 0, 0)
	end
end
addCommandHandler('lights', toggleLights)

function showVehicles(player, command)
	local allvehicles = exports['aprp-vehicles']:exportsVehicles()
	for i, k in pairs(allvehicles) do
		local vehicle_model = getVehicleNameFromModel(k:getData('vehicle:model'))
		local vehicle_owner = 'None'
		if k:getData('vehicle:owner') ~= 0 then
			vehicle_owner = exports['aprp-accounts']:getCharacterNameById(k:getData('vehicle:owner'))
		end
		outputChatBox('Vehicle ' ..vehicle_model.. ' Owner ' .. vehicle_owner, player, 255, 255, 255)
	end
end
addCommandHandler('showallvehs', showVehicles)

function lockVehicle(player, command)

	local is_admin = exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1)

	-- Check if player is inside a vehicle
	local vehicle = false
	if isPedInVehicle(player) then
		vehicle = getPedOccupiedVehicle(player)
	else 
		vehicle = exports['aprp-helpers']:getNearestVehicle(player, 5)
	end

	if not vehicle then
		outputChatBox('You must be inside a vehicle or near one to use this command', player, 255, 0, 0)
		return
	end

	local vehicle_id	= vehicle:getData('vehicle:id')
	local vehicle_owner = vehicle:getData('vehicle:owner')
	local character_id	= player:getData('charid')

	-- Check if the character is the owner of the vehicle
	if tonumber(vehicle_owner) ~= tonumber(character_id) then
		outputChatBox('You must be the owner of this vehicle to lock/unlock it', player, 255, 0, 0)
		return
	end

	local lock_status = vehicle:getData('vehicle:locked')

	local locked = 0

	if lock_status == 0 then
		-- Locking the vehicle
		vehicle:setData('vehicle:locked', 1)
		locked = 1
		outputChatBox('The vehicle is now locked!', player, 0, 255, 0)
		setVehicleLocked(vehicle, true)
		-- Trigger SFX
		triggerClientEvent('_VehicleSFXPlay3D_', root, 'car_lock', vehicle, false)
	else
		-- Unlocking the vehicle
		vehicle:setData('vehicle:locked', 0)
		locked = 0
		outputChatBox('The vehicle is now unlocked', player, 0, 255, 0)
		setVehicleLocked(vehicle, false)
		-- Trigger SFX
		triggerClientEvent('_VehicleSFXPlay3D_', root, 'car_lock', vehicle, false)
	end

	setTimer(
		function()
			local data = {}
			data['locked'] = locked
			local update = exports['aprp-database']:quickUpdate('vehicles', data, 'id', tonumber(vehicle_id))
			if not update[1] then
				print('Error updating the lock status of the vehicle ' .. tostring(vehicle_id))
			end
		end
	, 1000, 1)

end
addCommandHandler('lock', lockVehicle)

function removeSeatBelt(player)
	--
	local seatbelt = player:getData('vehicle:seatbelt')
	if not seatbelt then
		return
	end
	outputChatBox('You removed the seatbelt', player, 0, 255, 0)
	triggerClientEvent('_VehicleSFXPlay_', player, 'seatbelt_off')
	player:setData('vehicle:seatbelt', false)
end

function toggleSeatbelt(player, command)
	-- Toggles the seatbelt
	if isPedInVehicle(player) then
		local vehicle 	= getPedOccupiedVehicle(player)
		local seatbelt 	= player:getData('vehicle:seatbelt')
		if seatbelt then
			-- Seatbelt on, taking it off
			player:setData('vehicle:seatbelt', false)
			outputChatBox('You removed the seatbelt', player, 0, 255, 0)
			triggerClientEvent('_VehicleSFXPlay_', player, 'seatbelt_off')
			return
		else
			-- Seatbelt off, putting it on
			player:setData('vehicle:seatbelt', true)
			outputChatBox('You putted the seatbelt on', player, 0, 255, 0)
			triggerClientEvent('_VehicleSFXPlay_', player, 'seatbelt_on')
			return
		end
	end
end

function parkVehicle(player, command, vehicle_id)
	-- Function to park the vehicle
	--
	local vehicle = false
	local index	  = 0

	if isPedInVehicle(player) then
		unbindKey(player, 'j', 'down', toggleEngine)
		unbindKey(player, 'l', 'down', toggleLights) -- Toggles vehicle lights
		unbindKey(player, 'k', 'down', lockVehicle)

		local vehicle  		= getPedOccupiedVehicle(player)
		vehicle:setData('vehicle:engine', false)	
	end

	if vehicle_id then 
		local allvehicles = exports['aprp-vehicles']:exportsVehicles()
		for i, k in pairs(allvehicles) do
			local v_id = tonumber(k:getData('vehicle:id'))
			if v_id == tonumber(vehicle_id) then
				vehicle = k
				index = i
				return
			end
		end
	else 
		vehicle = exports['aprp-helpers']:getNearestVehicle(player, 5)
	end

	if not vehicle then
		outputChatBox('You must be inside a vehicle or close to one', player, 255, 0, 0)
		return
	end

	local owner_id = vehicle:getData('vehicle:owner')
	
	local adminForced = false
	
	if exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
		owner_id = player:getData('charid')
		adminForced = true
	end

	-- check if the player is the owner
	if tonumber(player:getData('charid')) ~= tonumber(owner_id) then
		outputChatBox("You can't park somebody else vehicle's", player, 255, 0, 0)
		return
	end

	local x, y, z 	= getElementPosition(vehicle)
	local rx,ry,rz 	= getElementRotation(vehicle)

	local position = '['..x..','..y..','..z..']'
	local rotation = '['..rx..','..ry..','..rz..']'

	local health   = getElementHealth(vehicle)

	local update = {}

	update['parked']   = 1
	update['position'] = position
	update['rotation'] = rotation
	update['health']   = health
	
	vehicle_id = vehicle:getData('vehicle:id')

	run = exports['aprp-database']:quickUpdate('vehicles', update, 'id', tonumber(vehicle_id))

	if run[1] then
		triggerEvent('_ServerPlayerEngineStop_', root, vehicle)
		-- Stop door chime SFX
		triggerClientEvent('_VehicleSFXStop3D_', root, vehicle)
		exports['aprp-vehicles']:stopRandomStall(vehicle)
		destroyElement(vehicle)
		outputChatBox("You parked your vehicle, use /unpark <id> to retrieve it", player, 0, 255, 0)
		exports['aprp-vehicles']:removeVehicleFromList(index)
		if adminForced then
			outputChatBox("ADMIN: Forced parked the vehicle", player, 0, 0, 255)
		end
	else
		outputChatBox('Error parking your vehicle', player, 255, 0, 0)
	end
end
addCommandHandler('park', parkVehicle)

function unparkVehicle(player, command, vehicle_id) 
	-- Unpark the vehicle
	--

	if not vehicle_id then
		outputChatBox('Syntax: /' .. command .. ' <vehicle_id>', player, 255, 255, 255)
		return
	end
	
	local parked = exports['aprp-database']:quickSelect({'id', 'parked'}, 'vehicles', 'id', tonumber(vehicle_id), true)

	if parked.e_size > 0 then
		if tonumber(parked.parked) == 0 then
			outputChatBox('This vehicle is not parked', player, 255, 0, 0)
			return
		end
	else
		return
	end

	local vehicleExists = exports['aprp-vehicles']:vehicleExists(tonumber(vehicle_id))

	if not vehicleExists[1] then
		outputChatBox('No vehicle found!', player, 255, 0, 0)
		return
	end

	local vehicle_owner = tonumber(vehicleExists[2])
	local character_id  = tonumber(player:getData('charid'))

	if character_id ~= vehicle_owner then
		outputChatBox('No vehicle found!', player, 255, 0, 0)
		return
	end

	local k = exports['aprp-database']:quickSelect({'*'}, 'vehicles', 'id', tonumber(vehicle_id), true)

	local p = exports['aprp-helpers']:clear1(k.position)
	local r = exports['aprp-helpers']:clear1(k.rotation)
	local c = exports['aprp-helpers']:clear1(k.colors)

	local x, y, z = getElementPosition(player) -- Player Location
	local colision = createColTube(p[1], p[2], p[3], 10, 10)

	if not isElementWithinColShape(player, colision) then
		outputChatBox('You must be near the parked spot', player, 255, 0, 0)
		destroyElement(colision)
		return
	end

	destroyElement(colision)

	local veh = createVehicle(tonumber(k.model), p[1], p[2], p[3])
	setElementRotation(veh, r[1], r[2], r[3])

	setVehicleColor(veh, c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])

	local vehicle_name = getVehicleNameFromModel(k.model)

	veh:setData('vehicle:id', tonumber(k.id))
	veh:setData('vehicle:model', tonumber(k.model))
	veh:setData('vehicle:owner', tonumber(vehicle_owner))
	veh:setData('vehicle:locked', tonumber(k.locked))
	veh:setData('vehicle:engine', false)
	veh:setData('vehicle:lights', false)
	veh:setData('vehicle:fuel', tonumber(k.fuel))
	veh:setData('vehicle:fueltype', k.fuel_type)
	veh:setData('vehicle:spawn', true)

	if tonumber(k.locked) == 1 then
		setVehicleLocked(veh, true)
	else
		setVehicleLocked(veh, false)
	end

	setElementHealth(veh, tonumber(k.health))

	setTimer(
		function ()
			veh:setData('vehicle:spawn', false)
		end
	,1500, 1)

	exports['aprp-vehicles']:addVehicleToList(veh)

	outputChatBox('Vehicle ' .. vehicle_name ..' unparked', player, 0, 255, 0)

	local set = {}

	set['parked'] = 0

	exports['aprp-database']:quickUpdate('vehicles', set, 'id', tonumber(vehicle_id))

end
addCommandHandler('unpark', unparkVehicle)

function myVehicles(player, command)
	local character_id = tonumber(player:getData('charid'))
	-- Display all the player vehicles
	--
	local vehicles = exports['aprp-database']:quickSelect({'id', 'model', 'parked', 'position'}, 'vehicles', 'owner_id', character_id)

	if not vehicles[1] then
		outputChatBox("You don't have any vehicles yet", player, 255, 255, 255)
		return
	end

	if #vehicles <= 0 then
		outputChatBox("You don't have any vehicles yet", player, 255, 255, 255)
		return
	end

	for i, k in ipairs(vehicles[2]) do
		local vehicle_parked = tonumber(k.parked)
		local vehicle_name	 = getVehicleNameFromModel(tonumber(k.model))
		local vehicle_id     = tonumber(k.id)
		local r, g, b 		 = 255, 255, 255
		local parked	     = ''

		local p = exports['aprp-helpers']:clear1(k.position)

            local zoneName = getZoneName(p[1], p[2], p[3])

            if vehicle_parked == 1 then
                r, g, b = 250, 201, 5
                parked = '(PARKED) (' .. zoneName .. ')'
            else
                parked = '(UNPARKED)'
            end

            message = 'Vehicle: ' .. vehicle_name .. ' ID: ' .. tostring(vehicle_id) .. ' ' .. parked
		outputChatBox(message, player, r, g, b)
	end
end
addCommandHandler('myvehicles', myVehicles)
addCommandHandler('myvehs', myVehicles)

function toggleHandbrake(player, command)
	-- Toggles the vehicle handbrake
	--
	if isPedInVehicle(player) then
		local vehicle_seat = getPedOccupiedVehicleSeat(player)
		if vehicle_seat == 0 then
			local vehicle = getPedOccupiedVehicle(player)
			local handbrake = vehicle:getData('vehicle:handbrake')

			-- Check if the vehicle is moving
			if exports['aprp-helpers']:isElementMoving(vehicle) then
				outputChatBox("Can't use this while moving", player, 255, 0, 0)
				return
			end

			if not isVehicleOnGround(vehicle) then
				outputChatBox('Your vehicle must be on the ground', player, 255, 0, 0)
				return
			end

			if tonumber(handbrake) == 0 then
				-- Enabling handbrake
				setElementFrozen(vehicle, true)
				vehicle:setData('vehicle:handbrake', 1)
				outputChatBox('Handbrake is now on!', player, 0, 255, 0)
				triggerClientEvent('_VehicleSFXPlay3D_', root, 'handbrake_on', vehicle)
			else
				-- disabling the handbrake
				setElementFrozen(vehicle, false)
				vehicle:setData('vehicle:handbrake', 0)
				outputChatBox('Handbrake is now off!', player, 0, 255, 0)
				triggerClientEvent('_VehicleSFXPlay3D_', root, 'handbrake_off', vehicle)
			end

			local data = {}
			data['handbrake'] = tonumber(vehicle:getData('vehicle:handbrake'))
			exports['aprp-database']:quickUpdate('vehicles', data, 'id', tonumber(vehicle:getData('vehicle:id')))

		else
			outputChatBox('You must be the driver to use this', player, 255, 0, 0)
		end
	else
		outputChatBox('You must be inside a vehicle to use this', player, 255, 0, 0)
	end		
end
addCommandHandler('handbrake', toggleHandbrake)

local res = getResourceFromName('aprp-fuel')
function resourceStop()
	-- Stops the fuel
	stopResource(res)
end
addEventHandler('onResourceStop', resourceRoot, resourceStop)

function resourceStart()
	-- Starts the fuel
	startResource(res)
end
addEventHandler('onResourceStart', resourceRoot, resourceStart)