local houses = {} -- Stores all the houses

function createHouse(player, command, name, interior, price)
    -- Function to create a house
    --
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not name or not interior or not price then
        outputChatBox("Syntax: /" .. command .. " <name> <interior> <price>", player, 255, 255, 255)
        return
    end

    local creator = player:getData('id')
    local x, y, z = getElementPosition(player)

    local position = '['..x..','..y..','..z..']'

    local exec = exports['aprp-house']:createHouse(name, position, interior, price, creator)
    
    if exec[1] then
        outputChatBox("House ID: " ..tostring(exec[2]) .. " created", player, 0, 255, 0)
        -- Creating the house pickup
        local house = createPickup(x, y, z, 3, 1273, 0.1)
        -- Adding data to the house
        house:setData('isHouse', true)
        house:setData('house:id', exec[2])
        house:setData('house:interior', interior)
        house:setData('house:dimension', 0)
        house:setData('house:owner', 0)
        house:setData('house:price', price)
        house:setData('house:name', name)
        house:setData('house:position', position)
        house:setData('house:locked', 1)
        -- Adding to the table
        table.insert(houses, house)
        -- adding 3d text
        exports['easy3dtext']:create3DText(x, y, z + 0.8, name)
        exports['easy3dtext']:create3DText(x, y, z + 0.7, '$ '..price)
        exports['easy3dtext']:create3DText(x, y, z + 0.6, 'ID:' .. exec[2])
    else
        outputChatBox("Error while trying to create the house")
    end
end
addCommandHandler("ch", createHouse)

function deleteHouse(player, command, houseid)
    -- Function to delete a house
    --
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not houseid then
        outputChatBox("Syntax: /" .. command .. " <houseid", player, 255, 255, 255)
        return
    end

    if exports['aprp-house']:deleteHouse(houseid) then
        outputChatBox("The house was deleted", player, 0, 255, 0)
        local res = getResourceFromName('easy3dtext')
        restartResource(res)        
        -- Deleting the house pickup
        for i, k in pairs(houses) do
            local id = k:getData('house:id') 
            if tonumber(houseid) == id then
                destroyElement(k)
            end
        end
    else
        outputChatBox("Error while deleting the house", player, 255, 0, 0)
    end
end
addCommandHandler('dh', deleteHouse)

function gotoHouse(player, command, house)
    -- Teleports the player to the house
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not house then
        outputChatBox("Syntax: /" .. command .. " <houseid>", player, 255, 255, 255)
        return
    end

    for i, k in pairs(houses) do
        local house_id = k:getData('house:id')
        if house_id == tonumber(house) then
            local position = exports['aprp-helpers']:clear1(k:getData('house:position'))
            setElementPosition(player, position[1], position[2], position[3])
            outputChatBox("Teleported to the house", player, 0, 255, 0)
        end
    end
end
addCommandHandler('gh', gotoHouse)

function editHouse(player, command, house_id, parameter, value) 
    -- Changes the house parameters
    --
    local editableParams = {'name', 'price', 'interior', 'locked', 'owner_id'}

    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not house_id or not parameter or not value then
        outputChatBox("Syntax: /" .. command .. " <houseid> <parameter> <value>", player, 255, 255, 255)
        outputChatBox("Parameters: name (single word), price (int), interior (int), locked (1 or 0), owner_id (int)", player, 255, 255, 255)
        return
    end

    if exports['aprp-helpers']:has_value(editableParams, parameter) then
        local values = {}
        values[parameter] = value

        if exports['aprp-house']:updateHouse(house_id, values) then
            outputChatBox("Parameter " .. parameter .. " set to " .. value, player, 0, 255, 0)
            -- Reloading the house
            setTimer(reloadHouse, 1000, 1, house_id, player)
        else
            outputChatBox("Error while changing the parameter", player, 255, 0, 0)
        end 
    else
        outputChatBox('Invalid parameter: ' .. tostring(parameter), player, 255, 0, 0)
    end
end
addCommandHandler('eh', editHouse)

function reloadHouse(house_id, player)
    if not house_id then
        print('Invalid house id')
    end

    local house = exports['aprp-house']:getHouse(house_id)

    local  res = getResourceFromName('easy3dtext')
    restartResource(res)

    if house[1] then
        for i, k in pairs(house[2]) do
            local house_name        = k.name
            local house_id          = tonumber(k.id)
            local house_position    = exports['aprp-helpers']:clear1(k.position)
            local house_dimension   = tonumber(k.dimension)
            local house_locked      = tonumber(k.locked)
            local house_price       = tonumber(k.price)
            local house_owner       = tonumber(k.owner_id)
            local house_interior    = tonumber(k.interior)
            local house_locked      = tonumber(k.locked)

            local isDeleted = false
            for i, k in pairs(houses) do
                -- deleting the house pickup element
                local pickup_house_id = k:getData('house:id')
                if house_id == pickup_house_id then
                    isDeleted = true
                    destroyElement(k)
                    outputChatBox("House deleted, updating a new one...", player, 0, 255, 0)
                end
            end

            if isDeleted then
                local model = 0
                if house_owner == 0 then
                    model = 1273
                else
                    model = 1272
                end
                -- creating a new house
                local house_pickup = createPickup(house_position[1], house_position[2], house_position[3], 3, model, 0.1)
                -- adding to the table
                table.insert(houses, house_pickup)
                -- adding data to the house
                house_pickup:setData('isHouse', true)
                house_pickup:setData('house:id', house_id)
                house_pickup:setData('house:interior', house_interior)
                house_pickup:setData('house:price', house_price)
                house_pickup:setData('house:name', house_name)
                house_pickup:setData('house:position', k.position)
                house_pickup:setData('house:owner', house_owner)
                house_pickup:setData('house:dimension', house_dimension)
                house_pickup:setData('house:locked', house_locked)
                outputChatBox("House updated!", player, 0, 255, 0)
                -- updating the 3d text
                setTimer(
                    function()
                        exports['easy3dtext']:create3DText(house_position[1], house_position[2], house_position[3] + 0.8, house_name)
                        exports['easy3dtext']:create3DText(house_position[1], house_position[2], house_position[3] + 0.7, '$ '..house_price)
                        exports['easy3dtext']:create3DText(house_position[1], house_position[2], house_position[3] + 0.6, 'ID:' ..house_id)
                    end
                , 2000, 1)
            else
                outputChatBox("Error while updating the house element", player, 255, 0, 0)
            end
        end
    else
        outputChatBox("Error while updating the house element", player, 255, 0, 0)
    end
end
--

function spawnAllHouses()
    -- Function to spawn all the houses when resource starts
    local res = getResourceFromName('easy3dtext')
    local all = exports['aprp-house']:getAllHouses()

    if all[1] then
        for i, rk in ipairs(all[1]) do
            local pos = exports['aprp-helpers']:clear1(rk.position)      
            local model = 0

            if tonumber(rk.owner_id) == 0 then
                model = 1273
            else
                model = 1272
            end

            local house = createPickup(pos[1], pos[2], pos[3], 3, model, 0.1, 1)
            table.insert(houses, house)
            -- adding data to the house
            house:setData('isHouse', true)
            house:setData('house:id', tonumber(rk.id))
            house:setData('house:interior', tonumber(rk.interior))
            house:setData('house:dimension', tonumber(rk.dimension))
            house:setData('house:price', tonumber(rk.price))
            house:setData('house:name', rk.name)
            house:setData('house:position', rk.position)
            house:setData('house:owner', tonumber(rk.owner_id))
            house:setData('house:locked', tonumber(rk.locked))
            -- adding to the table
            -- adding 3d text
            exports['easy3dtext']:create3DText(pos[1], pos[2], pos[3] + 0.8, rk.name)
            exports['easy3dtext']:create3DText(pos[1], pos[2], pos[3] + 0.7, '$ '..rk.price)
            exports['easy3dtext']:create3DText(pos[1], pos[2], pos[3] + 0.6, 'ID:' .. rk.id)
        end  
    end
end
addEventHandler('onResourceStart', resourceRoot, spawnAllHouses)




