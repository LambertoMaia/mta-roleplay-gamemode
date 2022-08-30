function removePlayerFromVeh(player, command, character_id)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not character_id then
        outputChatBox("Syntax: /" .. command .. " <character_id>", player, 255, 255, 255)
        return
    end

    local element = exports['aprp-player']:getPlayerElement(tonumber(character_id)) 

    if not isPedInVehicle(element) then
        outputChatBox("This player is not inside a vehicle!", player, 255, 0, 0)
        return
    end

    -- Removing the player from the vehicle

    local vehicle       = getPedOccupiedVehicle(element)
    local vehicle_name  = getVehicleNameFromModel(vehicle:getData('vehicle:model'))

    removePedFromVehicle(element)

    local x, y, z = getElementPosition(element)
    setElementPosition(element, x + 2, y, z)

    local character_name = exports['aprp-accounts']:getCharacterNameById(tonumber(character_id))

    outputChatBox("You removed the player " .. character_name .. " from the vehicle " .. vehicle_name, player, 0, 255, 0)
    outputChatBox("The administrator ejected you from the vehicle", element, 255, 255, 0)
end
addCommandHandler('rfv', removePlayerFromVeh)


