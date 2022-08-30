function isVehicleParked(vehicle_id) 
    -- Checks if the vehicle is parked
    --
    local select = exports['aprp-database']:quickSelect({'id', 'parked'}, 'vehicles', 'id', tonumber(vehicle_id), true)

    if select.e_size > 0 then
        if tonumber(select.parked) == 1 then
            return true
        else
            return false
        end
    else
        return false
    end
end

function vehicleExists(vehicle_id) 
    -- Checks if the vehicle exists
    --
    local select = exports['aprp-database']:quickSelect({'id', 'owner_id'}, 'vehicles', 'id', tonumber(vehicle_id), true)

    if select.e_size > 0 then
        return {true, select.owner_id}
    else
        return {false, false}
    end
end

function isEngineOn(vehicle)
    if vehicle:getData('vehicle:engine') then
        return true
    else
        return false
    end
end

function getVehicleElement(vehicle_id) 
    -- Returns the vehicle element
    local vehicles = exports['aprp-vehicles']:exportsVehicles()

    for i, k in pairs(vehicles) do
        local vid = tonumber(k:getData('vehicle:id'))
        if vid == tonumber(vehicle_id) then
            return k
        end
    end

    return false
end





