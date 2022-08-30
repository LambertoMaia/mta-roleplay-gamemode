function setPlayerHp(player, command, character_id, health)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        outputChatBox("You don't have permission to use this command", player, 255, 0, 0)
        return
    end

    if not character_id or not health then
        outputChatBox("Sytax: /" .. command .. " <character_id> <health_amount>", player, 255, 255,255)
        return
    end

    health = tonumber(health)

    local accounts = exports['aprp-accounts']:exportAccounts()
    
    local character = nil
    for i, k in pairs(accounts) do
        local vid = k:getData('charid')
        if tonumber(character_id) == tonumber(vid) then
            character = k
        end
    end

    if not character then
        outputChatBox('No character found', player, 255, 0, 0)
        return
    end

    character:setHealth(health)

    if isPedDead(character) then
       local x, y, z = getElementPosition(character)
       spawnPlayer(character, x, y, z)
       fadeCamera(character, true)
       setCameraTarget(character, character)
       outputChatBox("You've been revived by the administrator", character, 0, 255, 0) 
    end
end
addCommandHandler("setcharhealth", setPlayerHp)

