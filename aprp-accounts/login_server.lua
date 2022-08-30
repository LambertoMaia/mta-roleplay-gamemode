local accounts = {}

addEvent('_LoginPlayer_', true)

function login(username, password, player) 
    -- Logs a player in
    if exports['aprp-accounts']:loginUser(username, password) then
        triggerClientEvent('_Notification_', player, 'You are now logged in!', 'Success', 0, 255, 0)
        
        local account_data = exports['aprp-database']:quickSelect({'*'}, 'accounts', 'username', username, true)

        outputChatBox("You are now logged in as " .. account_data.username, player, 0, 255, 0)

        player:setData('username', username)
        player:setData('admin_level', tonumber(account_data.admin_level))
        player:setData('admin_status', tonumber(account_data.admin_status))
        player:setData('jailed', tonumber(account_data.jailed))
        player:setData('loggedIn', true)
        triggerClientEvent('_CloseLoginWindow_', player)
        triggerClientEvent('_ShowCharacterWindow_', player)

        table.insert(accounts, player)
    end
end
addEventHandler('_LoginPlayer_', root, login)

function exportAccounts()
    return accounts
end