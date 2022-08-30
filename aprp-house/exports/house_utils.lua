function createHouse(name, position, interior, price, createdBy)
    -- Function to create a house
    -- returns true if the house was created
    --

    local locked    = 1
    local owner_id  = 0
    local dimension = 0

    local insert = exports['aprp-database']:quickInsert('houses', {
        'name', 'position', 'interior', 'dimension', 'locked', 'owner_id', 'price'
    }, {name, position, interior, dimension, locked, owner_id, price})

    if insert[1] then
        return {true, insert[3]}
    else
        return {false, false}
    end
end

function deleteHouse(house_id)
    -- Function to delete a house
    -- returns true if the house was deleted
    --
    local delete = exports['aprp-database']:quickDelete('houses', 'id', house_id)
    if delete[1] then
        return true
    else
        return false
    end
end

function transferHouse(house_id, character_id)
    -- Transfer a house to a character
    -- returns true if the transfer was ok
    --
    local data = {}

    data['dimension'] = tonumber(character_id) + 100
    data['owner_id']  = tonumber(character_id)
    
    local update = exports['aprp-database']:quickUpdate('houses', data, 'id', house_id)

    if update[1] then
        return true
    else
        return false
    end
end

-- Helpers
function houseExists(house_id)
    -- Function to check if a house exists
    -- returns true if the house exists
    -- returns the house ID
    --
    local select = exports['aprp-database']:quickSelect({'id'}, 'houses', 'id', house_id)

    if select[1] then
        return true
    else
        return false
    end
end

function getAllHouses()
    -- Gets all the houses from the database
    -- returns a table with the houses 
    local select = exports['aprp-database']:quickSelect({'*'}, 'houses')

    if select[1] then
        return {select[2], select[3]}
    else
        return {false, false}
    end
end

function updateHouse(house_id, values)
    -- Updates a house with a new parameter
    --
    local update = exports['aprp-database']:quickUpdate('houses', values, 'id', house_id)
    if update[1] then
        return true
    else
        return false
    end
end

function getHouse(house_id)
    -- Returns a specific house
    --
    local house = exports['aprp-database']:quickSelect({'*'}, 'houses', 'id', house_id)

    if house[1] then
        return {true, house[2], house[3]}
    else
        return {false, false}
    end
end

function getInterior(interior)
    -- Returns the interior
    --
    local int = exports['aprp-database']:quickSelect({'*'}, 'interiors', 'id', tonumber(interior), true)
    if int.e_size > 0 then
        return int
    else
        return false
    end
end

function setLock(house_id, set)
    -- Sets the house lock status
    --
    local data = {}

    data['locked'] = set

    local update = exports['aprp-database']:quickUpdate('houses', data, 'id', tonumber(house_id))

    if update[1] then
        return true
    else
        return false
    end
end


