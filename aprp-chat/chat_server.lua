local chatRadius = {}

-- Normal chat
chatRadius['local'] = 15
-- /ooc <message>
chatRadius['ooc']   = 10
-- /me <action>
chatRadius['me']    = 10
-- /do <action>
chatRadius['do']    = 10
-- /try <action>
chatRadius['try']   = 10
-- /shout <message>
chatRadius['shout'] = 20
-- /whisper <message>
chatRadius['whisper'] = 3
-- /megaphone <message>
chatRadius['megaphone'] = 35

function createChatShpere(radius, player)
    -- creates a chat sphere around the player
    --

    if not radius then
        outputDebugString('Cannot create chat sphere. Unknown radius')
        return
    end

    if not player then
        outputDebugString('Cannot create chat sheper. Unknown player element')
    end
    
    local x, y, z = getElementPosition(player)
    local chat_sphere = createColSphere(x,y,z, radius)
    local playersInside = getElementsWithinColShape(chat_sphere, "player")

    destroyElement(chat_sphere)

    return playersInside
end

function localChat(message, messageType)
    -- Local chat
    local character_id   = tonumber(source:getData('charid'))
    local character_name = exports['aprp-accounts']:getCharacterNameById(character_id)
    local nearbyPlayers  = createChatShpere(chatRadius['local'], source)
    local r, g, b = 255, 255, 255

    if messageType == 0 then
        message = character_name .. ' (' .. tostring(character_id) ..'): ' .. message
    end

    if messageType == 1 then
        r, g, b = 246, 84, 255
        message = '* ' .. character_name .. ' ' .. message .. ' *'
    end

    for i, k in pairs(nearbyPlayers) do
        outputChatBox(message, k, r, g, b)
    end

end
addEventHandler('onPlayerChat', root, localChat)

function oocCHAT(player, command, ...)

    local character_id   = tonumber(player:getData('charid'))
    local character_name = exports['aprp-accounts']:getCharacterNameById(character_id)
    local zone = createChatShpere(chatRadius['ooc'], player)

    local message = ''

    local r, g, b = 138, 137, 135

    for i, k in ipairs(arg) do
        message = message .. ' ' .. k
    end

    if message == '' then
        outputChatBox("Syntax: /" .. command .. " <message>", player, 255, 255, 255)
        return
    end

    message = exports['aprp-helpers']:trim1(message)
    message = '( OOC Chat: ' .. character_name .. ' (' .. tostring(character_id) .. '): ' .. message .. ' )'

    for i, k in pairs(zone) do
        outputChatBox(message, k, r, g, b)
    end
end
addCommandHandler('ooc', oocCHAT)

function megaphoneCHAT(player, command, ...)

    local character_id   = tonumber(player:getData('charid'))
    local character_name = exports['aprp-accounts']:getCharacterNameById(character_id)
    local zone = createChatShpere(chatRadius['megaphone'], player)

    local message = ''

    local r, g, b = 250, 201, 5

    for i, k in ipairs(arg) do
        message = message .. ' ' .. k
    end

    if message == '' then
        outputChatBox("Syntax: /" .. command .. " <message>", player, 255, 255, 255)
        return
    end

    message = exports['aprp-helpers']:trim1(message)
    message = '( Megaphone: ' .. character_name .. ' (' .. tostring(character_id) .. '): ' .. message .. ')'

    for i, k in pairs(zone) do
        outputChatBox(message, k, r, g, b)
    end
end
addCommandHandler('m', megaphoneCHAT)

function shoutCHAT(player, command, ...)
    local character_id   = tonumber(player:getData('charid'))
    local character_name = exports['aprp-accounts']:getCharacterNameById(character_id)
    local zone = createChatShpere(chatRadius['shout'], player)

    local message = ''

    local r, g, b = 255, 255, 255

    for i, k in ipairs(arg) do
        message = message .. ' ' .. k
    end

    if message == '' then
        outputChatBox('Syntax: /' .. command .. ' <message>', player, 255, 255, 255)
        return
    end

    message = exports['aprp-helpers']:trim1(message)
    message = character_name .. ' (' .. tostring(character_id) ..') (Shout): ' .. message

    for i, k in pairs(zone) do
        outputChatBox(message, k, r, g, b)
    end
end
addCommandHandler('s', shoutCHAT)

function whisperCHAT(player, command, ...)
    local character_id   = tonumber(player:getData('charid'))
    local character_name = exports['aprp-accounts']:getCharacterNameById(character_id)
    local zone = createChatShpere(chatRadius['whisper'], player)

    local message = ''

    local r, g, b = 242, 245, 66

    for i, k in ipairs(arg) do
        message = message .. ' ' .. k
    end

    if message == '' then
        outputChatBox('Syntax: /' .. command .. ' <message>', player, 255, 255, 255)
        return
    end

    message = exports['aprp-helpers']:trim1(message)
    message = character_name .. ' (' .. tostring(character_id) ..') (Whisper): ' .. message

    for i, k in pairs(zone) do
        outputChatBox(message, k, r, g, b)
    end
end
addCommandHandler('w', whisperCHAT)

function tryAction(player, command, ...)
    local random = math.random(0, 1)
    local message = ''
    local character_id   = tonumber(player:getData('charid'))
    local character_name = exports['aprp-accounts']:getCharacterNameById(character_id)
    local zone = createChatShpere(chatRadius['local'], player)
    local r, g, b = 246, 84, 255

    for i, k in ipairs(arg) do
        message = message .. ' ' .. k
    end

    message = exports['aprp-helpers']:trim1(message)

    

    if message == '' or message == '0' then 
        outputChatBox('Syntax: /' .. command .. ' <action>', player, 255, 255, 255)
        return
    end

    local result  = false
    
    if random == 1 then
        -- Success
        result = 'and succeeds.'
    else
        result = 'and fails.'
    end

    message = '* ' .. character_name .. ' tries to ' .. message .. ' ' .. result

    for i, k in pairs(zone) do
        outputChatBox(message, k, r, g, b)
    end
end
addCommandHandler('try', tryAction)

function blockChatMessage()
    cancelEvent()
end
addEventHandler('onPlayerChat', root, blockChatMessage)

--

function clearChat(player, command)
    clearChatBox()
end
addCommandHandler('clear', clearChat)

local colision = nil
local timer    = nil

function nearMe(player, command)
    if colision then
        destroyElement(colision)
        killTimer(timer)
        colision = nil
        timer = nil
        return
    end

    local x, y, z = getElementPosition(player)
    colision = createColSphere(x, y, z, 10)

    attachElements(colision, player)

    timer = setTimer(spot, 1000, 0)
end
addCommandHandler('nearme', nearMe)

function spot()
    local elements = getElementsWithinColShape(colision)

    for i, k in ipairs(elements) do
        print(getElementType(k))
    end
end

