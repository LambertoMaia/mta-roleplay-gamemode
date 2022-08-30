local randomStallTimer = 20000 -- 20 seconds to roll a random stall

local timers = {} -- Stores the timers with the vehicle element

function engineDamage(loss)
    -- This function is triggered when a vehicle gets damaged
    -- Checks the damage taken in the vehicle
    -- If the damage is below 251 then, the vehicle cant take any more damage and 
    -- is completely stuck
    -- If the damage is above 251 and below 400 then the engine enters in a random
    -- stall mode 
    -- Once the vehicle engine is stopped the random stall stops
    -- Once the vehicle engine is started then we check if the engine is in the random
    -- stall zone
    --
    -- Getting vehicle heath
    local vehicle = source
    local vehicle_health = source:getHealth()
    local with_damage    = vehicle_health - loss -- This is the vehicle health after the 
    
    if vehicle:getData('vehicle:spawn') then
        return
    end

    if loss > 300 then
        local occupants = getVehicleOccupants(source)
        for i, k in pairs(occupants) do
            local seatbelt = k:getData('vehicle:seatbelt')
            if not seatbelt then
                local playerHealth = k:getHealth()
                local toset = playerHealth - 10
                k:setHealth(toset)
            end
        end
    end 

    print('Damage Taken -> ' .. with_damage)
    -- Check if the vehicle health (with_damage) is above 251 but below 400
    if with_damage > 251 and with_damage < 450 then
        -- Start the engine random stall
        -- Attribute the vehicle engine damaged
        print('Vehicle damage is above 251 and below 450')
        source:setData('vehicle:damaged', true)
        startRandomStalls(vehicle)
        randomPower(vehicle)
        return
    end
    -- Check if the vehicle health is below 251
    if with_damage <= 251 then
        print('Vehicle damage is below 251')
        -- Set the vehicle health 
        vehicle:setHealth(251)
        vehicle:setData('vehicle:damaged', false)
        vehicle:setData('vehicle:engineLock', true)
        vehicle:setEngineState(false)
        vehicle:setData('vehicle:engine', false)

        local driver = getVehicleController(vehicle)

        if driver then
            outputChatBox('The engine locked due to heavy damages in it!', driver, 255, 0, 0)
        end

        triggerEvent('_ServerPlayerEngineStop_', root, vehicle)
        triggerClientEvent('_ServerFuelStop_', root)
        stopRandomStall(vehicle)
        randomPowerStop(vehicle)

        setVehicleDamageProof(vehicle, true)

        return
    end
end
addEventHandler('onVehicleDamage', resourceRoot, engineDamage)

function startRandomStalls(vehicle) 
    -- Starts the random vehicle stall
    -- Check if the vehicle has engine damaged
    if not vehicle:getData('vehicle:damaged') then
        -- Vehice doens't have engine damage
        return
    end

    if vehicle:getData('vehicle:engineLock') then
        return
    end
    -- Vehicle has engine damage
    -- Check if the vehicle has any timer already set
    if timers[vehicle] then
        -- Timer is already set, skipping it
        return
    end
    -- Timer is not set yet
    -- Setting new timer for the vehicle
    local timer = setTimer(randomStall, randomStallTimer, 0, vehicle)
    -- Adding the timer to the table
    timers[vehicle] = timer
end

function randomStall(vehicle)
    -- Random engine stalls every x seconds
    local stall = math.random(0, 1)
    -- Check if the stall can happen
    if stall == 0 then
        -- Don't stall the engine
        print("Wont stall this time")
        return
    end 
    -- Stall the engine
    -- Turning the engine off
    vehicle:setData('vehicle:engine', false)
    vehicle:setEngineState(false)
    -- Stopping the timer
    stopRandomStall(vehicle)
    randomPowerStop(vehicle)
    -- Check if there's any player inside the vehicle
    local driver = getVehicleController(vehicle)
    if driver then
        -- Sending message to the driver
        outputChatBox('The vehicle engine stalled due to heavy damages in it', driver, 255, 0, 0)
    end
end

function stopRandomStall(vehicle)
    -- Stops the random stall timer
    -- Check if the timer is set
    if timers[vehicle] then
        -- Kill the timer
        killTimer(timers[vehicle])
        setVehicleDamageProof(vehicle, false)
        -- Remove from the table
        timers[vehicle] = nil
    end
end

function startRandomStall(vehicle)
    print('Start random stall independent')
    -- This starts the random stall without the vehicle getting damage
    -- Used by the engine start function 
    -- Getting the vehicle health
    local vehicle_health = vehicle:getHealth()
    -- Check if the vehicle heath is below 400 but above 251
    if vehicle_health > 251 and vehicle_health < 450 then
        -- Start the random engine stall 
        -- Set the vehicle engine damage parameter
        vehicle:setData('vehicle:damaged', true)
        startRandomStalls(vehicle)
        randomPower(vehicle)
        return
    end
    -- Check if the vehicle health is below 251
    if vehicle_health <= 251 then
        -- Do engine Lock
        -- Check if the engine is already locked
        if not vehicle:getData('vehicle:engineLock') then
            -- Setting engine lock
            vehicle:setData("vehicle:engineLock", true)
        end
        -- Shutting the engine down
        vehicle:setData("vehicle:engine", false)
        vehicle:setData("vehicle:damaged", false)
        vehicle:setEngineState(false)

        randomPowerStop(vehicle)
        
        local driver = getVehicleController(vehicle)

        if driver then
            outputChatBox("Engine off!", driver, 255, 0, 0)
            outputChatBox("The engine won't start due to heavy damages in it", driver, 255, 0, 0)
        end
    end
end

local randomPowerTimers = {}

function randomPower(vehicle)
    
    if not vehicle:getData('vehicle:damaged') then
        return
    end

    print('Random Power')
    if randomPowerTimers[vehicle] then
        print('Vehicle is already set')
        -- Random Power already set
        return
    end

    local timer = setTimer(randomPowerStart, 10000, 0, vehicle)

    randomPowerTimers[vehicle] = timer
    print('Vehicle setted')
end

function randomPowerStart(vehicle)
    local randomPower = math.random(0, 3)
    local handling    = getOriginalHandling(vehicle:getData('vehicle:model'))

    local maxVelocity   = handling.maxVelocity

    local maxVelocity50 = maxVelocity * 0.40
    local maxVelocity30 = maxVelocity * 0.20

    if randomPower > 0 then
        -- Set Velocity at 70% of the original speed
        setVehicleHandling(vehicle, 'maxVelocity', maxVelocity50)
        print('Set 40% power')
    elseif randomPower == 0 then
        -- Set Velocity at 50% of the original speed
        print('set 20% of power')
        setVehicleHandling(vehicle, 'maxVelocity', maxVelocity30)
    end
end

function randomPowerStop(vehicle)
    local handling = getOriginalHandling(vehicle:getData('vehicle:model'))
    setVehicleHandling(vehicle, 'maxVelocity', handling['maxVelocity'])
    print('Original settings set')
    if not randomPowerTimers[vehicle] then
        print('no power to kill')
        return
    end
    print('Killing random power timer')
    killTimer(randomPowerTimers[vehicle]) 
    randomPowerTimers[vehicle] = nil
end
