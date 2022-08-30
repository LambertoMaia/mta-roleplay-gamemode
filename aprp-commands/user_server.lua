local commandsType = {'vehicle', 'house', 'chat'}
function aCommands(player, command, type)
    if not type then
        outputChatBox('Syntax: /' ..command.. ' <type>', player, 255, 255, 255)
        outputChatBox('Available types: <vehicle> <house>', player, 255, 255, 255)
        return
    end

    if exports['aprp-helpers']:has_value(commandsType, type) then
        if type == 'vehicle' then
            
        elseif type == 'house' then
            
        elseif type == 'chat' then
            outputChatBox('Chat Commands: (parameters with [] are optional)', player, 172, 245, 83)
            outputChatBox('/myid (Displays your character ID and account ID)', player, 172, 245, 83)
            outputChatBox('/id <name> (displays the character id of the player>', player, 172, 245, 83)
            outputChatBox('/ooc <message> (display a OOC message to local players)', player, 172, 245, 83)
            outputChatBox('/w <message> (whisper a message to the nearest player)', player, 172, 245, 83)
            outputChatBox('/s <message> (shout a message to nearby players)', player, 172, 245, 83)
            outputChatBox('/me <action> (perform an action)', player, 172, 245, 83)
            outputChatBox('/s <message> (scream a message to nearby players)', player, 172, 245, 83)
            outputChatBox('/try <action> (attempt to perform an action 50/50)', player, 172, 245, 83)

        end
    end
end
addCommandHandler('commands', aCommands)
addCommandHandler('cmd', aCommands)


    