addEvent('_ClientPopulateVehicles_', true)

local allvehicles = {}

function createVeh(player, command, vehicle)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not vehicle or not type then
        outputChatBox("Syntax: /" .. command .. " <vehicle name> <type:faction,normal>", player, 255, 255, 255)
        return
    end

    -- setting defaults
    local vehicle_model = getVehicleModelFromName(vehicle)
    
    if not vehicle_model then
        outputChatBox(vehicle .. " is not a valid vehicle", player, 255, 0, 0)
        return
    end

    local owner_id          = 0
    local is_faction        = 0 
    local faction_id        = 0

    local x, y, z       = getElementPosition(player)
    local rx, ry, rz    = getElementRotation(player)

    local position = '['..x..','..y..','..z..']'
    local rotation = '['..rx..','..ry..','..rz..']'

    local veh = createVehicle(vehicle_model, x + 5, y, z + 2, rx, ry, rz)

    local handling = veh:getHandling()

    local c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12   = veh:getColor(true)
    local colors = '['..c1..','..c2..','..','..c3..','..c4..','..c5..','..c6..','..c7..','..c8..','..c9..','..c10..','..c11..','..c12..']'

    local health   = getElementHealth(veh)

    local fuel = 100

    local insert = exports['aprp-database']:quickInsert('vehicles', {
        'owner_id', 'is_faction', 'faction_id', 'model', 'model_name', 'position', 'rotation', 'health', 'colors', 'fuel'
    }, {owner_id, is_faction, faction_id, vehicle_model, vehicle, position, rotation, health, colors, fuel})
    
    print(insert[3])

    if insert[1] then
        outputChatBox(vehicle .. " vehicle created!", player, 0, 255, 0)
        veh:setData('vehicle:id', tonumber(insert[3]))
        veh:setData('vehicle:locked', 0)
        veh:setData('vehicle:model', vehicle_model)
        veh:setData('vehicle:engine', false)
        veh:setData('vehicle:owner', 0)
        veh:setData('vehicle:lights', false)
        veh:setData('vehicle:fuel', 100)
        veh:setData('vehicle:fueltype', 'regular')
        veh:setData('vehicle:handbrake', 0)
        table.insert(allvehicles, veh)
    else
        outputChatBox("Error while adding the vehicle to the database", player, 255, 0, 0)
    end
end
addCommandHandler('cv', createVeh)

function setVehicleOwner(player, command, vehicle_id, owner_id)
    -- Sets a vehicle owner
    --
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not vehicle_id or not owner_id then
        outputChatBox('Syntax: /' .. command .. ' <vehicle_id> <owner_id>', player, 255, 255, 255)
        return
    end

    -- Setting the vehicle owner
    local data = {}

    data['owner_id'] = tonumber(owner_id)

    local update = exports['aprp-database']:quickUpdate('vehicles', data, 'id', tonumber(vehicle_id))

    if update[1] then
        outputChatBox('The owner of this vehicle was changed', player, 0, 255, 0)
        for i, k in pairs(allvehicles) do
            local veh_id = tonumber(k:getData('vehicle:id'))
            if tonumber(vehicle_id) == veh_id then
                k:setData('vehicle:owner', tonumber(owner_id))
                return
            end
        end
    else
        outputChatBox('Error while changing the onwer of the vehicle', player, 255, 0, 0)
    end
end
addCommandHandler('setvehowner', setVehicleOwner)

function thisVehicle(player, command)
    -- Shows the vehicle id to the player
    --
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if isPedInVehicle(player) then
        local vehicle       = player:getOccupiedVehicle()
        local vehicle_id    = vehicle:getData('vehicle:id')
        outputChatBox('This vehicle ID: ' .. tostring(vehicle_id), player, 255, 255, 255)
        return
    end

    -- Nearest vehicle
    local nearestVehicle = exports['aprp-helpers']:getNearestVehicle(player, 5)

    if nearestVehicle then
        local vehicle_id    = nearestVehicle:getData('vehicle:id')
        local vehicle_model = getVehicleNameFromModel(nearestVehicle:getData('vehicle:model'))

        outputChatBox('Nearest Vehicle: ' ..vehicle_model.. ' ID: ' .. tostring(vehicle_id), player, 255, 255, 255)
        return
    end

    outputChatBox('You are not inside a vehicle or no vehicles near your', player, 255, 0, 0)
end
addCommandHandler('thisveh', thisVehicle)

function deleteVehicle(player, command, vehicle_id)
    -- Deletes the vehicle from the game and database

    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not vehicle_id then
        outputChatBox("Syntax: /" .. command .. " <vehicle_id>", player, 255, 255, 255)
        return
    end

    vehicle_id = tonumber(vehicle_id)

    local delete = exports['aprp-database']:quickDelete('vehicles', 'id', vehicle_id)

    if delete[1] then
        -- Vehicle deleted
        for i, vehicle in pairs(allvehicles) do
            local spawned_id = vehicle:getData('vehicle:id')
            if vehicle_id == spawned_id then
                destroyElement(vehicle)
                return
            end
        end
        outputChatBox("The vehicle was deleted", player, 0, 255, 0)
    else
        outputChatBox('Error while deleting the vehicle', player, 255, 0, 0)
    end
end
addCommandHandler('deleteveh', deleteVehicle)

function gotoVehicle(player, command, vehicle_id)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not vehicle_id then
        outputChatBox("Syntax: /" .. command .. " <vehicle_id>", player, 255, 255, 255)
        return
    end

    vehicle_id = tonumber(vehicle_id)

    for i, allvehs in pairs(allvehicles) do
        local veh_id = allvehs:getData('vehicle:id')
        if vehicle_id == veh_id then
            vehicle = allvehs

            local x, y, z = getElementPosition(vehicle)

            setElementPosition(player, x + 2, y, z)

            outputChatBox("Teleported to the vehicle", player, 0, 255, 0)
            return
        end
    end

    outputChatBox('No vehicle with this ID found', player, 255, 0, 0)
end
addCommandHandler('tpv', gotoVehicle)

function setVehColor(player, command, vehicle_id, r, g, b)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not vehicle_id or not r or not g or not b then
        outputChatBox("Syntax: /" .. command .. " <vehicle_id> <r> <g> <b>", player, 255, 255, 255)
        return
    end

    vehicle_id = tonumber(vehicle_id)

    r = tonumber(r)
    g = tonumber(g)
    b = tonumber(b)

    for i, vehicles in pairs(allvehicles) do
        local v_id = vehicles:getData('vehicle:id')
        
        if vehicle_id == v_id then
            vehicles:setColor(r, g, b)
            outputChatBox('Color changed!', player, 0, 255, 0)
            -- Updating in database
            local c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12 = vehicles:getColor(true)
            local colors_ = '['..c1..','..c2..','..c3..','..c4..','..c5..','..c6..','..c7..','..c8..','..c9..','..c10..','..c11..','..c12..']'
            local data = {}
            data['colors'] = colors_
            local update = exports['aprp-database']:quickUpdate('vehicles', data, 'id', tonumber(v_id))
            if update[1] then
                outputChatBox('Colors saved to the database', player, 0, 255, 0)
            else
                outputChatBox('Error saving the colors to the database', player, 255, 0, 0)
            end
            return
        end
    end
end
addCommandHandler('changevcolor', setVehColor)

function adminUnlock(player, command, vehicle_id)
    -- Forces a car to toggle its lock status
    local vehicle = false

    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if vehicle_id then
        for i, k in pairs(allvehicles) do
            local v_id = k:getData('vehicle:id')
            if tonumber(vehicle_id) == tonumber(v_id) then
                vehicle = k
            end
        end
    else
        vehicle = exports['aprp-helpers']:getNearestVehicle(player, 5)
    end

    if not vehicle then
        outputChatBox('Syntax: /' .. command .. ' <vehicle_id>', player, 255, 255, 255)
        return
    end

    -- Getting vehicle lock status
    local lock_status   = vehicle:getData('vehicle:locked')
    local vehicle_name  = getVehicleNameFromModel(vehicle:getData('vehicle:model'))

    if lock_status == 0 then
        -- Vehicle unlocked 
        outputChatBox('ADMIN: Force locking the vehicle ('.. vehicle_name .. ')', player, 0, 255, 0)
        vehicle:setData('vehicle:locked', 1)
        vehicle:setLocked(true)
    elseif lock_status == 1 then
        outputChatBox('ADMIN: Force unlocking the vehicle ('.. vehicle_name .. ')', player, 0, 255, 0)
        vehicle:setData('vehicle:locked', 0)
        vehicle:setLocked(false)
    end
end
addCommandHandler('alock', adminUnlock)

function bringVehicle(player, command, vehicle_id)
    -- Function to teleport the vehicle to the player
    --
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not  vehicle_id then
        outputChatBox('Syntax: /' .. command .. ' <vehicle_id>', player, 255, 255, 255)
        return
    end

    for i, k in pairs(allvehicles) do
        local v_id = tonumber(k:getData('vehicle:id'))
        if v_id == tonumber(vehicle_id) then
            local x, y, z = getElementPosition(player)
            setElementPosition(k, x + 4, y, z)
            outputChatBox('Bringing the vehicle to your position', player, 0, 255, 0)
            return
        end
    end
end
addCommandHandler('bringveh', bringVehicle)

function adminRefuel(player, command, vehicle_id, amount)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    local vehicle = false

    if vehicle_id then
        for i, k in pairs(allvehicles) do
            local v_id = tonumber(k:getData('vehicle:id'))
            if v_id == tonumber(vehicle_id) then
                vehicle = k
            end
        end
    else
        vehicle = exports['aprp-helpers']:getNearestVehicle(player, 5)
    end

    if not vehicle then
        outputChatBox('Syntax: /' .. command .. ' <vehicle_id> <amount>', player, 255, 255, 255)
        return
    end

    local amount_fuel = false

    if not amount then
        amount_fuel = 100
    else
        amount_fuel = tonumber(amount)
    end

    vehicle:setData('vehicle:fuel', amount_fuel)

    local update = {}
    update['fuel'] = amount_fuel

    exports['aprp-database']:quickUpdate('vehicles', update, 'id', tonumber(vehicle:getData('vehicle:id')))

    outputChatBox('Vehicle fuel changed to ' .. tostring(amount_fuel), player, 0, 255, 0)
end
addCommandHandler('setvfuel', adminRefuel)

function repairVehicle(player, command, vehicle_id)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    local vehicle = false
    if not vehicle_id then
        vehicle = exports['aprp-helpers']:getNearestVehicle(player, 5)
    else
        for i, k in pairs(allvehicles) do
            local v_id = tonumber(k:getData('vehicle:id'))
            if v_id == tonumber(vehicle_id) then
                vehicle = k
            end
        end
    end

    if not vehicle then
        outputChatBox('No vehicle nearby, Syntax: /' .. command .. ' <vehicle_id>', player, 255, 255, 255)
        return
    end

    vehicle:fix()

    local vehicle_name = getVehicleNameFromModel(vehicle:getData('vehicle:model'))

    outputChatBox('Vehicle ' .. vehicle_name .. ' repaired', player, 0, 255, 0)
end
addCommandHandler('repairveh', repairVehicle)

function removeVehicleFromList(index) 
    -- Removes a vehicle from the table
    --
    table.remove(allvehicles, tonumber(index))
end

function addVehicleToList(vehicle_element)
    -- Adds a vehicle to the list
    --
    table.insert(allvehicles, vehicle_element)
end

function playerVehicles(player, command, character_id)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not character_id then
        outputChatBox('Syntax: /' .. command .. ' <character_id>', player, 255, 255, 255)
        return
    end

    if not exports['aprp-accounts']:characterExists(tonumber(character_id)) then
        outputChatBox('No character found with this ID', player, 255, 0, 0)
        return
    end

    local vehicles = exports['aprp-database']:quickSelect({'id', 'owner_id', 'parked', 'model', 'position'}, 'vehicles', 'owner_id', tonumber(character_id))

    if vehicles[1] then
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
                parked = '(PARKED)'
            else
                parked = '(UNPARKED)'
            end

            message = 'Vehicle: ' .. vehicle_name .. ' ID: ' .. tostring(vehicle_id) .. ' ' .. parked .. ' (' ..zoneName.. ')'
            outputChatBox(message, player, r, g, b)
        end
    else
        outputChatBox('This character has no vehicles', player, 255, 255, 255)
    end
end
addCommandHandler('playervehs', playerVehicles)

function setVehHealth(player, command, vehicle_id, health) 
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not health or not vehicle_id then
        outputChatBox('Syntax: /' .. command .. ' <vehicle_id> <health>', player, 255, 255, 255)
        return
    end
    

    for i, k in pairs(allvehicles) do
        local vid = tonumber(k:getData('vehicle:id'))
        if vid == tonumber(vehicle_id) then
            k:setHealth(tonumber(health))
            k:setData("vehicle:engineLock", false)
            k:setData("vehicle:damaged", false)
            return
        end
    end

    outputChatBox('No vehicles found!', player, 255, 0, 0)
end
addCommandHandler('setvhealth', setVehHealth)

function aUnpark(player, command, vehicle)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not vehicle then
        outputChatBox("Syntax: /" .. command .. " <vehicle_id>", player, 255, 255, 255)
        return
    end

    local vehicle = exports['aprp-database']:quickSelect({'*'}, 'vehicles', 'id', tonumber(vehicle), true)

    if vehicle.e_size == 0 then
        outputChatBox("No vehicles found!", player, 255, 255, 255)
        return
    end

    local p = exports['aprp-helpers']:clear1(vehicle.position)
    local c = exports['aprp-helpers']:clear1(vehicle.colors)
    local r = exports['aprp-helpers']:clear1(vehicle.rotation) 

    local vehicle_ = createVehicle(tonumber(vehicle.model), p[1], p[2], p[3])
    setElementRotation(vehicle_, r[1], r[2], r[3])
    setVehicleColor(vehicle_, c[1], c[2], c[3])
    setElementHealth(vehicle_, tonumber(vehicle.health))

	vehicle_:setData('vehicle:id', tonumber(vehicle.id))
	vehicle_:setData('vehicle:model', tonumber(vehicle.model))
	vehicle_:setData('vehicle:owner', tonumber(vehicle.owner_id))
	vehicle_:setData('vehicle:locked', tonumber(vehicle.locked))
	vehicle_:setData('vehicle:engine', false)
	vehicle_:setData('vehicle:lights', false)
	vehicle_:setData('vehicle:fuel', tonumber(vehicle.fuel))
	vehicle_:setData('vehicle:fueltype', vehicle.fuel_type)
    vehicle_:setData('vehicle:spawn', true)

    setTimer(
        function ()
            vehicle_:setData('vehicle:spawn', false)
        end
    , 1500, 1)

    table.insert(allvehicles, vehicle_)

    local set = {parked = 0}

    exports['aprp-database']:quickUpdate('vehicles', set, 'id', tonumber(vehicle.id))

    outputChatBox("ADMIN: The vehicle was unparked!", player, 0, 255, 0)
    return
end
addCommandHandler("aunpark", aUnpark)

function aThisVeh(player, command)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    local vehicle = exports['aprp-helpers']:getNearestVehicle(player, 5)

    if not vehicle then
        outputChatBox("No vehicle nearby!", player, 255, 255, 0)
        return
    end
    
    local vehicle_name      = getVehicleNameFromModel(vehicle:getData("vehicle:model"))
    local vehicle_health    = getElementHealth(vehicle)

    outputChatBox("Vehicle " .. vehicle_name, player, 255, 0, 255)
    outputChatBox("Owner ID: " .. tostring(vehicle:getData('vehicle:owner')), player, 255, 0, 255)
    outputChatBox("Vehicle ID: " .. tostring(vehicle:getData('vehicle:id')), player, 255, 0, 255)
    outputChatBox("Health: " .. tostring(vehicle_health), player, 255, 0, 255)
end
addCommandHandler('athisveh', aThisVeh)

function placeInVeh(player, command, character_id, vehicle_id)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    local vehicle = nil

    if not vehicle_id then
        vehicle = exports['aprp-helpers']:getNearestVehicle(player, 5)
    end

    if not vehicle_id or not character_id then
        outputChatBox("No vehicles nearby or not informed", player, 255, 0, 0)
        outputChatBox("Syntax: /" .. command .. " <character_id> [<vehicle_id>]", player, 255, 255, 255)
        return
    end

    local element = exports['aprp-player']:getPlayerElement(tonumber(character_id))

    if not element then
        outputChatBox("No player found!", player, 255, 0, 0)
        return
    end

    if isPedInVehicle(element) then
        -- Remove the player from the vehicle
        removePedFromVehicle(element)
    end

    setTimer(
        function ()
            vehicle = exports['aprp-vehicles']:getVehicleElement(vehicle_id)

            if not vehicle then
                outputChatBox("No vehicle found!", player, 255, 0, 0)
                return
            end
            
            -- 

           local max = getVehicleMaxPassengers(vehicle)
           local pas = getVehicleOccupants(vehicle)

           for i=0, max do 
                if not pas[i] then
                    warpPedIntoVehicle(element, vehicle, i)
                    return
                end
            end
        
            outputChatBox("The administrator teleported you to the vehicle", element, 255, 255, 0)
            outputChatBox("You teleported the player to the vehicle", player, 0, 255, 0)
        end
    , 300, 1)

   
end
addCommandHandler('placeinveh', placeInVeh)

-- Handlers

function spawnAllVehicles()
    -- Spawns all the unparked vehicles
    local vehs = exports['aprp-database']:quickSelect({'*'}, 'vehicles', 'parked', 0)

    if vehs[1] then

        for i, k in pairs(vehs[2]) do
            local c = exports['aprp-helpers']:clear1(k.colors)
            local p = exports['aprp-helpers']:clear1(k.position)
            local r = exports['aprp-helpers']:clear1(k.rotation)

            local health    = tonumber(k.health)
            local owner_id  = tonumber(k.owner_id)
            local model     = tonumber(k.model)

            local veh = createVehicle(model, p[1], p[2], p[3])
            
            veh:setColor(c[1],c[2],c[3],c[4],c[5],c[6],c[7],c[8],c[9],c[10],c[11],c[12])

            setElementRotation(veh, r[1], r[2], r[3])
            print(health)
            setElementHealth(veh, health)

            veh:setData('vehicle:id', tonumber(k.id))
            veh:setData('vehicle:model', model)
            veh:setData('vehicle:owner', owner_id)
            veh:setData('vehicle:locked', tonumber(k.locked))
            veh:setData('vehicle:engine', false)
            veh:setData('vehicle:lights', false)
            veh:setData('vehicle:fuel', tonumber(k.fuel))
            veh:setData('vehicle:fueltype', k.fuel_type)
            veh:setData('vehicle:handbrake', tonumber(k.handbrake))

            veh:setData('vehicle:spawn', true)
            
            if tonumber(k.locked) == 1 then
                setVehicleLocked(veh, true)
            end

            if tonumber(k.handbrake) == 1 then
                setElementFrozen(veh, false)
            end

            table.insert(allvehicles, veh)

            setTimer(
                function()
                    veh:setData('vehicle:spawn', false)
                end
            , 1500, 1)

        end
    end
end
addEventHandler('onResourceStart', resourceRoot, spawnAllVehicles)

function populateVehicleList()
    local select = exports['aprp-database']:quickSelect({'id', 'owner_id', 'model_name', 'position'}, 'vehicles')
    triggerClientEvent('_ServerPopulateVehicles_', resourceRoot, select)
end
addEventHandler('_ClientPopulateVehicles_', resourceRoot, populateVehicleList)

function exportsVehicles()
    return allvehicles
end
