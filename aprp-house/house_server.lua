-- Handlers
function walkOnHouse(player)
    -- When a player walks on top of a house pickup
    if source:getData('isHouse') then
        local house_id          = source:getData('house:id')
        local house_interior    = source:getData('house:interior')
        local house_dimension   = source:getData('house:dimension')
        local house_owner       = source:getData('house:owner')
        local house_lock        = source:getData('house:locked')
        local house_price       = source:getData('house:price')

        -- Set the player's current house ID
        player:setData('athouse:elem', source)
        player:setData('athouse:id', house_id)
        player:setData('athouse:interior', house_interior)
        player:setData('athouse:dimension', house_dimension)
        player:setData('athouse:lock', house_lock)
        player:setData('athouse:owner', house_owner)
        player:setData('athouse:price', house_price)
        bindKey(player, 'f', 'down', enterHouse)

        if house_owner == 0 then
            outputChatBox("Use /buyhouse to buy this house", player, 255, 255, 255)
            --outputChatBox("Use /visit to check the house interior", player, 255, 255, 255)
            return
        end
    end
end
addEventHandler('onPickupUse', resourceRoot, walkOnHouse)

function walkOffHouse(player)
    -- When a player laves a house pickup
    if source:getData('isHouse') then
        -- Remove player's current house ID
        player:removeData('athouse:id')
        player:removeData('athouse:interior')
        player:removeData('athouse:dimension')
        player:removeData('athouse:owner')
        player:removeData('athouse:price')
        player:removeData('athouse:lock')
        unbindKey(player, 'f', 'down', enterHouse)
    end
end
addEventHandler('onPickupLeave', resourceRoot, walkOffHouse)

-- Commands
function visitHouse(player, command) -- To be completed
    -- Enables the user to enter the house to check the interior
    --
    local athouse = player:getData('athouse:id')
    if athouse then
        print('at house')
    else
        print('not at house')
    end
end
addCommandHandler('visit', visitHouse)

function enterHouse(player, command)
    -- Teleports the player to the house
    local house_id = player:getData('athouse:id')
    if house_id then
        local house_interior    = player:getData('athouse:interior')
        local house_dimension   = player:getData('athouse:dimension')
        local house_lock        = player:getData('athouse:lock')
        
        -- Check if the house is locked
        if house_lock == 1 then
            -- house locked
            outputChatBox("You can't enter a locked house", player, 255, 0, 0)
            return
        end
        -- Getting house interior
        local interior = exports['aprp-house']:getInterior(house_interior)
        if interior.e_size == 0 then
            print('Error interior')
            return
        end

        -- Check if the house has any owner
        if player:getData('athouse:owner') == 0 then
            outputChatBox("You can't enter this house", player, 255, 0, 0)
            return
        end
        
        local x, y, z = getElementPosition(player)
        local exit_position = '['..x..','..y..','..z..']'

        -- Teleporting the player to the interior
        player:setData('athouse:inside', true)
        player:setData('athouse:exit', exit_position)
        setElementInterior(player, interior.interior_id)
        setElementDimension(player, house_dimension)
        setElementPosition(player, interior.posX, interior.posY, interior.posZ)
        outputChatBox("Press F to leave the house or type /leave", player, 255, 255, 255)
        unbindKey(player, 'f', 'down', enterHouse)
        bindKey(player, 'f', 'down', leaveHouse)
    end
end
addCommandHandler('enter', enterHouse)

function leaveHouse(player, command) 
    -- Teleports the player back to the exit location
    local athouse = player:getData('athouse:inside')
    
    if not athouse then
        return
    end

    local pos = exports['aprp-helpers']:clear1(player:getData('athouse:exit'))
    setElementDimension(player, 0)
    setElementInterior(player, 0)
    setElementPosition(player, pos[1], pos[2], pos[3])

    player:removeData('athouse:inside')
    player:removeData('athouse:exit')
end
addCommandHandler('leave', leaveHouse)

function buyHouse(player, command)
    -- Allows the user to buy the house he stands on
    local house = player:getData('athouse:id')
    -- check if player is at house
    if not house then
        outputChatBox("You have to be at a unowned house to use this", player, 255, 0, 0)
        return
    end

    local house_owner = player:getData('athouse:owner')
    local house_price = player:getData('athouse:price')
    local house_elem  = player:getData('athouse:elem')
    local house_id    = player:getData('athouse:id')
    
    -- Check if the house is unowned
    if house_owner ~= 0 then
        outputChatBox("You can't buy this house", player, 255, 0, 0)
        return
    end

    local transaction = exports['aprp-accounts']:moneyTransaction(player:getData('charid'), house_price, player)

    if not transaction[1] then
        outputChatBox("You can't buy this house, check your funds", player, 255, 0, 0)
        return
    end

    if not exports['aprp-house']:transferHouse(house_id, player:getData('charid')) then
        outputChatBox("Error while transfering the house, contact admin", player, 255, 0, 0)
        return
    end

    outputChatBox("This house was purchased!", player, 0, 255, 0)
    setTimer(
        function()    
            exports['aprp-house']:reloadHouse(house_id, player)
        end
    , 2000, 1)
end
addCommandHandler('buyhouse', buyHouse)

function toggleLock(player, command) 
    -- Function to toggle the house lock
    --
    local house     = player:getData('athouse:id')
    local ihouse    = player:getData('athouse:inside')

    -- Check if player is inside a house
    if not house then
        outputChatBox("You must be at a house you own", player, 255, 0, 0)
        return
    end

    if not house and not ihouse then
        outputChatBox("You must be at a house you own", player, 255, 0, 0)
        return
    end


    local house_owner = player:getData('athouse:owner')
    local house_lock  = player:getData('athouse:lock')
    local house_id    = player:getData('athouse:id')

    if tonumber(house_owner) ~= tonumber(player:getData('charid')) then
        outputChatBox("You can't lock/unlock this house", player, 255, 0, 0)
        return
    end

    local house_elem = player:getData('athouse:elem')
    if tonumber(house_lock) == 1 then
        -- Unlock the house
        if not exports['aprp-house']:setLock(house_id, 0) then
            outputChatBox('Error while toggling the house lock', player, 255, 0, 0)
            return
        end
        house_elem:setData('house:lock', 0)
        player:setData('athouse:lock', 0)
        outputChatBox('House is now: unlocked', player, 0, 255, 0)
    else
        if not exports['aprp-house']:setLock(house_id, 1) then
            outputChatBox('Error while toggling the house lock', player, 255, 0, 0)
            return
        end
        house_elem:setData('house:lock', 1)
        player:setData('athouse:lock', 1)
        outputChatBox('House is now: locked', player, 0, 255, 0)
    end
end
addCommandHandler('lockhouse', toggleLock)


