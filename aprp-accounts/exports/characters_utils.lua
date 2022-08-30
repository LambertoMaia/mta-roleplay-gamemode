-- default spawn position
local x, y, z = -2203.09765625,-2266.2109375,30.625
function createCharacter(character_name, account_id)
    -- creates a new character
    -- check if the character already exists
    if not characterExistsByName(character_name) then
        local connection = exports['aprp-database']:connectDb()
        local position = '['..x..','..y..','..z..']'
        local rotation = '[0,0,0]'
        -- Generate random player skin
        local model = math.random(0, 400)
        -- prepare sql
        local sql       = "INSERT INTO characters (account_id, character_name, position, rotation, model) VALUES (?,?,?,?,?)"
        local prepare   = dbPrepareString(connection, sql, account_id, character_name, position, rotation, model)
        if dbExec(connection, prepare) then
            return true
        else
            return false
        end
    end
end

function updateCharacterPosition(character_id, position, rotation, interior, dimension, athouse)
    -- Updates the character last position, interior and dimension
    -- returns true if updated
    --
    local update_fields = {}

    update_fields['position'] = position
    update_fields['rotation'] = rotation
    update_fields['interior'] = interior
    update_fields['dimension'] = dimension
    update_fields['athouse'] = athouse

    local update = exports['aprp-database']:quickUpdate('characters', update_fields, 'id', character_id)

    if update[1] then
        return true
    else
        return false
    end
end

function getAllCharacters(account_id)
    local connection = exports['aprp-database']:connectDb()
    -- returns a list with all the characters 
    if hasCharacters(account_id) then
        -- prepare the query
        local sql           = "SELECT id, character_name FROM characters WHERE account_id = ?"
        local prepare       = dbPrepareString(connection, sql, account_id)
        local runQuery      = dbPoll(dbQuery(connection, prepare), -1)
        return runQuery 
    else
        return nil
    end
end

function getCharacterData(character_id)
    local connection = exports['aprp-database']:connectDb()
    -- return a table with the character data
    if characterExists(character_id) then
        -- prepare the query
        local sql       = "SELECT * FROM characters WHERE id = ?"
        local prepare   = dbPrepareString(connection, sql, character_id)
        local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1))
        if runQuery.e_size > 0 then
            return runQuery
        else
            return nil
        end
    else
        return nil
    end
end

function characterBelongsToAccount(account_id, character_id)
    local connection = exports['aprp-database']:connectDb()
    -- return true if the character belongs to the account
    --
    -- check if the character exists
    if characterExists(character_id) then
        -- prepare the sql
        local sql       = "SELECT id FROM characters WHERE id = ? and account_id = ?"
        local prepare   = dbPrepareString(connection, sql, tonumber(character_id), tonumber(account_id))
        local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1))
        if runQuery.e_size > 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end

function characterExistsByName(character_name)
    local connection = exports['aprp-database']:connectDb()
    -- return true if the character exists
    --
    -- preparing the query
    local sql       = "SELECT character_name FROM characters WHERE character_name = ?"
    local prepare   = dbPrepareString(connection, sql, character_name)
    local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1))
    -- check if returned something
    if runQuery.e_size > 0 then
        return true
    else
        return false
    end
end

function characterExists(character_id)
    local connection = exports['aprp-database']:connectDb()
    -- return true if the character exists
    --
    -- preparing the query
    local sql       = "SELECT id FROM characters WHERE id = ?"
    local prepare   = dbPrepareString(connection, sql, character_id)
    local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1))
    -- check if returned something
    if runQuery.e_size > 0 then
        return true
    else
        return false
    end
end

function hasCharacters(account_id) 
    local connection = exports['aprp-database']:connectDb()
    -- return true if the account has character's associated with it
    --
    -- preparing the query
    local sql       = "SELECT id, account_id FROM characters WHERE account_id = ?"
    local prepare   = dbPrepareString(connection, sql, tonumber(account_id))
    local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1))

    if runQuery.e_size > 0 then
        return true
    else
        return false
    end
end

function getCharacterNameById(character_id)
    -- Gets the character name by its id
    -- returns the character name or false
    --
    local select = exports['aprp-database']:quickSelect({'id', 'character_name'}, 'characters', 'id', tonumber(character_id), true)

    if select.e_size > 0 then
        return select.character_name
    else
        return false
    end
end

function isCharacterMasked(character_id) 
    -- Checks if the character us wearing a mask
    --
    local select = exports['aprp-database']:quickSelect({'id', 'masked'}, 'characters', 'id', tonumber(character_id), true)

    if select.e_size > 0 then
        if tonumber(select.masked) == 1 then
            return true
        else
            return false
        end
    else
        return false
    end
end

function getCharacterAccountIdByCharacterId(character_id) 
    -- Retuns account ID of the character
    if not characterExists(character_id) then
        return false
    end

    local select = exports['aprp-database']:quickSelect({'account_id'}, 'characters', 'id', tonumber(charactere_id), true, 'LIKE')

    if select.e_size > 0 then
        return select.account_id
    else
        return false
    end
end


function updateCharacterBalance(character_id, balance_type, current_balance)
    local connection = exports['aprp-database']:connectDb()
    -- Function to update a character balance
    -- returns true if update
    --
    -- prepare the query
    local sql       = "UPDATE characters SET "..balance_type.." = ? WHERE id = ?"
    local prepare   = dbPrepareString(connection, sql, tonumber(current_balance), tonumber(character_id))
    if dbExec(connection, prepare) then
        return true
    else
        return false
    end
end

function moneyTransaction(character_id, product_price, player) 
    local connection = exports['aprp-database']:connectDb()
    -- Function to execute a money transaction 
    --
    -- Check if character exists
    if characterExists(character_id) then
        -- Get character balance
        local character_data = getCharacterData(character_id)
        -- Check if the character has sufficient money
        if tonumber(character_data.cash) ~= nil then
            if tonumber(character_data.cash) >= tonumber(product_price) then
                -- Execute the transaction
                local current_balance = tonumber(character_data.cash) - tonumber(product_price)
                if updateCharacterBalance(character_id, 'cash', current_balance) then
                    setPlayerMoney(player, tonumber(current_balance))
                    return {true, current_balance}
                else
                    return {false, false}
                end
            else
                return {false, 'No funds'}
            end
        else
            return {false, 'No funds'}
        end
    else
        return {false, 'No char'}
    end
end

