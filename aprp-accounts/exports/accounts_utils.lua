function createAccount(username, password)
    local connection = exports['aprp-database']:connectDb()
    -- creates a new account for the user
    -- checking if the account already exists
    if not accountExists(username) then
        -- creating the account
        -- preapring the query
        local register_date = exports['aprp-helpers']:showTime()
        -- Todo: better encryption method
        password = base64Encode(password)
        local sql = "INSERT INTO accounts (username, password, register_date, last_login) VALUES (?,?,?,?)"
        local prepare = dbPrepareString(connection, sql, username, password, register_date, register_date)
        if dbExec(connection, prepare) then
            -- account created
            -- assign values to the element
            client:setData('loggedin', true)
            client:setData('admin_level', 0)
            client:setData('admin_status', 0)
            client:setData('jailed', 0)
            client:setData('id', getAccountIdByName(username))
            return true
        else
            return false
        end
    else
        return false
    end
end

function loginUser(username, password)
    -- logs in the user
    --
    -- checking if the user exists
    if accountExists(username) then
        local accountId = getAccountIdByName(username)
        local account   = retrieveAccountData(accountId)
        local pass      = base64Decode(account.password)
        if password == pass then
            -- log in the user
            client:setData('loggedin', true)
            client:setData('admin_level', tonumber(account.admin_level))
            client:setData('admin_status', tonumber(account.admin_status))
            client:setData('jailed', tonumber(account.jailed))
            client:setData('id', accountId)
            return true
        else
            return false
        end
    else
        return false
    end
end


function accountExists(username) 
    local connection = exports['aprp-database']:connectDb()
    -- Searches by the username if an account exists
    -- returns true if the account exists
    -- returns false if the account does not exists
    --
    -- Preparing the query 
    local sql       = "SELECT username FROM accounts WHERE username = ?"
    local prepare   = dbPrepareString(connection, sql, username)
    local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1))
    -- Check if the result returned any value
    if runQuery.e_size > 0 then
        -- return true if it returned
        return true
    else
        -- return false if no value found
        return false
    end
end

function getAccountIdByName(username)
    local connection = exports['aprp-database']:connectDb()
    -- returns the account id (if exists)
    -- 
    -- check if the user exists
    if accountExists(username) then
        -- prepare the query
        local sql       = "SELECT id FROM accounts WHERE username = ?"
        local prepare   = dbPrepareString(connection, sql, username)
        local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1)) 
        -- check if the query returned something
        if runQuery.e_size > 0 then
            -- return the player id
            return tonumber(runQuery.id)
        else
            return nil
        end
    else
        return nil
    end
end

function retrieveAccountData(id)
    local connection = exports['aprp-database']:connectDb()
    -- returns the account data if the account exists
    -- preparing the query
    local sql       = "SELECT * FROM accounts WHERE id = ?"
    local prepare   = dbPrepareString(connection, sql, id)
    local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1))
    if runQuery.e_size > 0 then
        return runQuery
    else
        return nil
    end
end

function isAccountLogged()
    -- return true if the account is logged in
    if client:getData('loggedin') then
        return true
    else
        return false
    end
end

function isUserAdmin(id, level) 
    local connection = exports['aprp-database']:connectDb()
    -- Returns true if the user is admin
    -- checks if the user has a level greater or equal to setted level
    --
    -- preparing the query
    local sql           = "SELECT admin_level FROM accounts WHERE id = ?"
    local prepare       = dbPrepareString(connection, sql, id)
    local runQuery  = exports['aprp-database']:parseQuery(dbPoll(dbQuery(connection, prepare), -1))

    if runQuery.e_size > 0 and tonumber(runQuery.admin_level) >= tonumber(level) then
        return true
    else
        return false
    end
end

