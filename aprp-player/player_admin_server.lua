function teleportToPlayer(player, command, character_id) 
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not character_id then
        outputChatBox("Syntax: /" .. command .. " <character_id>", player, 255, 255, 255)
        return
    end

    local element = exports['aprp-player']:getPlayerElement(character_id)

    if not element then
        outputChatBox("No character's found with this ID", player, 255, 255, 0)
        return
    end
    
    if not exports['aprp-player']:saveBackPosition(player) then
        outputChatBox("Error saving your last position", player, 255, 255, 0)
    end

    outputChatBox("Last position saved. Use /tpb to return!", player, 255, 255, 0)

    local x, y, z   = getElementPosition(element)
    local interior  = getElementInterior(element)
    local dimension = getElementDimension(element)

    local character_name = exports['aprp-accounts']:getCharacterNameById(tonumber(character_id))
    
    -- Teleporting player to element

    setElementPosition(player, x + 2, y, z)
    setElementInterior(player, interior)
    setElementDimension(player, interior)

    outputChatBox("Teleporting you to " .. character_name .. " (" .. character_id .. ")", player, 0, 255, 0)
end
addCommandHandler('tp', teleportToPlayer)

function teleportBackPosition(player, command)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not player:getData('teleport:backPosition') then
        outputChatBox("You don't have any backpositions set", player, 255, 0, 0)
        return
    end

    if exports['aprp-player']:teleportToBackPosition(player) then
        exports['aprp-player']:removeBackPosition(player)
    end

    outputChatBox("Teleported you back to the last position", player, 0, 255, 0)
end 
addCommandHandler('tpb', teleportBackPosition)

function saveLastPosition(player, command) 
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not exports['aprp-player']:saveBackPosition(player) then
        outputChatBox("Error while saving your last position", player, 255, 0, 0)
        return
    end

    outputChatBox("Current position saved. Use /tpb to return to this location", player, 0, 255, 0)
end
addCommandHandler('tps', saveLastPosition)

function teleportToMe(player, command, character_id)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not character_id then
        outputChatBox("Syntax: /" .. command .. " <character_id>", player, 255, 255, 255)
        return
    end

    character_id = tonumber(character_id) 

    local x, y, z   = getElementPosition(player)
    local dimension = getElementDimension(player)
    local interior  = getElementInterior(player)

    local element = exports['aprp-player']:getPlayerElement(character_id)

    if isPedInVehicle(element) then
        -- Teleport the player vehicle
        if interior > 0 then
            outputChatBox('This player is inside a vehicle and cant be teleported to a interior', player, 255, 0, 0)
            return
        end
        local vehicle = getPedOccupiedVehicle(element)
        setElementPosition(vehicle, x + 5, y, z)
        setElementInterior(vehicle, interior)
        setElementDimension(vehicle, dimension)
        outputChatBox("You've been teleported by the admin", element, 255, 255, 0)
        return
    end

    -- Teleporting the player
    setElementPosition(element, x + 2, y, z)
    setElementInterior(element, interior)
    setElementDimension(element, dimension)

    local character_name = exports['aprp-accounts']:getCharacterNameById(character_id)

    outputChatBox("You've been teleported by the admin", element, 255, 255, 0)
    outputChatBox("You teleported " .. character_name .. " to you", player, 255, 255, 0)
end
addCommandHandler('tpm', teleportToMe)

function getPlayerIdByCharacter(player, command, character_name)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not character_name then
        outputChatBox("Syntax: /" .. command .. " <character_name>", player, 255, 255, 255)
        return
    end

    local accounts = exports['aprp-accounts']:exportAccounts()

    local names = {}

    print(#accounts)
        
    for i, k in pairs(accounts) do
        local char_name = exports['aprp-accounts']:getCharacterNameById(k:getData('charid'))
        if char_name then
            if char_name == character_name then
                names[char_name] = {k:getData('charid'), k:getData('id')}
                return
            else
                if char_name.find(char_name, character_name) then
                    names[char_name] = {k:getData('charid'), k:getData('id')}
                end
            end
        end
    end

    for i, k in pairs(names) do
        outputChatBox("Character: " .. i, player, 0, 255, 255)
        outputChatBox("Character ID: " .. k[1], player, 0, 255, 255)
        outputChatBox("Account ID: " .. k[2], player, 0, 255, 255)
    end
end
addCommandHandler('id', getPlayerIdByCharacter)

function slap(player, command, character_id, distance)
    -- Slaps the player
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not character_id then
        outputChatBox("Syntax: /" .. command .. " <character_id> [<distance>]", player, 255, 255, 255)
        return
    end

    if not distance then
        distance = 5
    end

    character_id = tonumber(character_id)

    local element = exports['aprp-player']:getPlayerElement(character_id)

    local x, y, z = getElementPosition(element)

    setElementPosition(element, x, y, z + distance)

    local character_name = exports['aprp-accounts']:getCharacterNameById(character_id)

    outputChatBox("You slapped the player " .. character_name, player, 0, 255, 0)
    outputChatBox("The administrator slapped you", element, 255, 255, 0)
end
addCommandHandler('slap', slap)


