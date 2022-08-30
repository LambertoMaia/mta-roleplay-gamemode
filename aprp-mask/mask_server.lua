function removeMask(player, command)
    -- Removes the player mask
    --
    local character_id = tonumber(player:getData('charid'))
    if exports['aprp-accounts']:isCharacterMasked(character_id) then
        -- Removing the mask
        outputChatBox('Masked removed', player, 0, 255, 0)
        player:setData('character:masked', false)
    else
        outputChatBox('You are now wearing a mask', player, 0, 255, 0)
        player:setData('character:masked', true)
    end

    local data = {}

    if player:getData('character:masked') then
        data['masked'] = 1
    else
        data['masked'] = 0
    end

    local update = exports['aprp-database']:quickUpdate('characters', data, 'id', character_id)

    if not update[2] then
        print('Error updating character mask status')
    end
end
addCommandHandler('mask', removeMask)
