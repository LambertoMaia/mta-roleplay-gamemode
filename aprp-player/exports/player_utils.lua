function getPlayerElement(character_id)
    if not character_id then
        return false
    end

    local accounts = exports['aprp-accounts']:exportAccounts()

    for i, k in pairs(accounts) do
        local charid = k:getData('charid')
        if tonumber(charid) == tonumber(character_id) then
            return k
        end
    end

    return false
end

function saveBackPosition(element) 
    -- Saves the the position of the element for later use
    if not element then
        return false
    end

    local x, y, z   = getElementPosition(element)
    local dimension = getElementDimension(element)
    local interior  = getElementInterior(element)

    local position  = '['..x..','..y..','..z..']'

    element:setData('teleport:backPosition', position)
    element:setData('teleport:backDimension', dimension)
    element:setData('teleport:backInterior', interior)

    return true
end

function removeBackPosition(element)
    if not element then
        return false
    end

    if not element:getData('teleport:backPosition') then
        return false
    end

    element:removeData('teleport:backPosition')
    element:removeData('teleport:backInterior')
    element:removeData('teleport:backDimension')
end

function teleportToBackPosition(element)
    if not element then
        return false
    end

    if not element:getData('teleport:backPosition') then
        return false
    end

    local position = exports['aprp-helpers']:clear1(element:getData('teleport:backPosition'))

    setElementPosition(element, position[1], position[2], position[3])
    setElementInterior(element, element:getData('teleport:backInterior'))
    setElementDimension(element, element:getData('teleport:backDimension'))

    return true
end




    