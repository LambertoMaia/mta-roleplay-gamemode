function connect()
    -- Function to create a MySQL connection
    connection = dbConnect('mysql', 'dbname=aprp;host=127.0.0.1', 'root', '')
    -- Testing connection
    if not connection then
        print('Error while connecting to the database')
    else
        print('Database connected!')
    end
end

addEventHandler('onResourceStart', resourceRoot, connect)

function connectDb()
    return connection
end

function parseQuery(poll)
    -- Function to parse the result and return table with the information
    local result, nAffectedRows, lastId = poll
    if result == nil then 
        -- If the result is not ready
        return false
    elseif result == false then
        local error_code, error_msg = nAffectedRows, lastId
        print('dbPoll Error (' .. tostring(error_code) .. ')')
        print('Error message: ' .. tostring(error_msg))
    else
        local data = {}
        for rid, row in ipairs(result) do
            for column, value in pairs(row) do
                data[column] = value
            end
        end
        local size = 0
        for k,v in pairs(data) do 
            size = size + 1
        end
        data['e_size'] = size
        return data
    end
end

function quickUpdate(table, setValues, where, equalsTo)
    local sql = "UPDATE " .. table .. " SET "
 
    -- Couting the setValues size
    local setValuesCounter = 0
    for i, k in pairs(setValues) do
       setValuesCounter = setValuesCounter + 1
    end
 
    local counter = 0
    for i, k in pairs(setValues) do
       counter = counter + 1
       if setValuesCounter == counter then
          sql = sql .. "" .. i .. " = '" .. k .. "' "
       else
          sql = sql .. '' .. i .. " = '" .. k .. "', "
       end
    end
    
    sql = sql .. 'WHERE ' .. where .. ' = ?'
 
    local prepare = dbPrepareString(connection, sql, equalsTo)
    local query   = dbQuery(connection, prepare)

    local result, naf, lastid = dbPoll(query, -1)

    if result then
        return {true, naf, lastid}
    else
        return {false, naf, lastid}
    end
end

function quickInsert(table, tableFields, tableValues)
    local sql = "INSERT INTO " .. table .. " ("
    
    local tableFieldsCount = #tableFields
    local tableValuesCount = #tableValues
 
    local counter = 0 
    for i, k in pairs(tableFields) do
       counter = counter + 1
       if counter == tableFieldsCount then
          sql = sql .. '' .. k .. ') '
       else
          sql = sql .. '' .. k .. ', '
       end
    end
 
    sql = sql .. ' VALUES ('
 
    local counter = 0
    for i, k in pairs(tableValues) do
       counter = counter + 1
       if counter == tableValuesCount then
          sql = sql .. "'" .. k .. "')"
       else
          sql = sql .. "'" .. k .. "', "
       end
    end
    
    local query   = dbQuery(connection, sql)
    local result, naf, lastid = dbPoll(query, -1)

    if result then
        return {true, naf, lastid, sql}
    else
        return {false, naf, lastid, sql}
    end
 end

 function quickDelete(table, where, equalsTo)
    local sql = "DELETE FROM " .. table .. " WHERE " .. where .. " = " .. equalsTo

    local prepare = dbPrepareString(connection, sql)
    local query   = dbQuery(connection, prepare)
    local result, naf, lastid = dbPoll(query, -1)

    if result then 
        return {true, naf, lastid}
    else
        return {false, naf, lastid}
    end
end

function quickSelect(selectList, from, where, equalsTo, parse, comparision, debug)
    local sql = "SELECT "

    if not comparision then
        comparision = "="
    end

    local selectListCount = #selectList

    local counter = 0 
    for i, k in pairs(selectList) do
        counter = counter + 1
        if counter == selectListCount then
            sql = sql .. k 
        else
            sql = sql .. k .. ', '
        end
    end

    sql = sql .. ' FROM ' .. from 

    if where then 
        local whereListCount = #where
        if not equalsTo then
            local counter = 0 
            sql = sql .. " WHERE "
            for i, k in pairs(where) do
                counter = counter + 1
                if counter == whereListCount then
                    sql = sql .. i .. " = " .. "'" .. k .. "'" 
                else
                    sql = sql .. i .. " = " .. "'" .. k .. "' and "
                end
            end
        else 
            sql = sql .. " WHERE " .. where .. " " .. comparision .. " '" .. equalsTo .. "'"
        end
    end

    if debug then
        print(sql)
    end

    local prepare = dbPrepareString(connection, sql)
    local query   = dbQuery(connection, prepare)
    
    if parse then
        return parseQuery(dbPoll(query, -1))
    end

    local result, naf, lastid = dbPoll(query, -1)

    
    if result then
        if #result <= 0 then
            return {false, false, false}
        else
            local data = {}
            return {true, result, naf, lastid}
        end
    else
        return {false, naf, lastid}
    end
end


