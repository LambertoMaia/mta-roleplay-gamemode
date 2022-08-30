addEvent('_PopulateCharacters_', true)
addEvent('_SelectedCharacter_', true)

function populateCharacters(account_id)
    account_id = tonumber(account_id) 
    local characters = exports['aprp-database']:quickSelect({'id', 'position', 'character_name'}, 'characters', 'account_id', account_id)

    if #characters == 0 then
        return false
    end

    triggerClientEvent('_RecieveCharacters_', source, characters)

end
addEventHandler('_PopulateCharacters_', root, populateCharacters)

function selectedCharacter(character_id, player)
    print(character_id)
    triggerClientEvent('_DestroyCharacterWindow_', player)

    -- Spawn the character
    local character = exports['aprp-database']:quickSelect({'*'}, 'characters', 'id', tonumber(character_id), true)

    player:setData('charid', tonumber(character.id))
    player:setData('character:spawned', true)
    player:setData('character:interior', tonumber(character.interior))
    player:setData('character:dimension', tonumber(character.dimension))
    player:setData('character:name', character.character_name)
    
    local p = exports['aprp-helpers']:clear1(character.position)
    local r = exports['aprp-helpers']:clear1(character.rotation)
    
    local a = spawnPlayer(player, p[1], p[2], p[3])

    setElementInterior(player, character.interior)
    setElementDimension(player, character.dimension)
    setElementHealth(player, 100)
    setElementRotation(player, r[1], r[2], r[3])
    setElementModel(player, character.model)

    setPlayerMoney(player, tonumber(character.cash), true)

    setCameraTarget(player, player)
    fadeCamera(player, true)

    triggerClientEvent('_Notification_', player, 'You are now playing as ' .. character.character_name, 'Success!', 0, 255, 0)
end
addEventHandler('_SelectedCharacter_', root, selectedCharacter)