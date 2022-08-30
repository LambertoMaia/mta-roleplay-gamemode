local commandsType = {'vehicle', 'house', 'chat'}
function aCommands(player, command, type)
    if not exports['aprp-accounts']:isUserAdmin(player:getData('id'), 1) then
        return 
    end

    if not type then
        outputChatBox('Syntax: /' ..command.. ' <type>', player, 255, 255, 255)
        outputChatBox('Available types: <vehicle> <house>', player, 255, 255, 255)
        return
    end

    if exports['aprp-helpers']:has_value(commandsType, type) then
        if type == 'vehicle' then
            outputChatBox('Vehicle Commands: (parameters with [] are optional)', player, 172, 245, 83)
            outputChatBox('/cv <vehicle_id> (creates a vehicle)', player, 172, 245, 83)
            outputChatBox('/deleteveh <vehicle_id> (deletes a vehicle)', player, 172, 245, 83)
            outputChatBox('/thisveh (show nearby vehicle id)', player, 172, 245, 83)
            outputChatBox('/setvehowner <vehicle_id> <owner_id> (changes the vehicle ownership)', player, 172, 245, 83)
            outputChatBox('/tpv <vehicle_id> (teleports to the vehicle)', player, 172, 245, 83)
            outputChatBox('/bringveh <vehicle_id> (brings the vehicle)', player, 172, 245, 83)
            outputChatBox('/changevcolor <vehicle_id> <r> <g> <b> (changes the vehicle color)', player, 172, 245, 83)
            outputChatBox('/alock [<vehicle_id>]', player, 172, 245, 83)
            outputChatBox('/setvfuel [<vehicle_id>] [<fuel_amount>] (sets the vehicle fuel)', player, 172, 245, 83)
            outputChatBox('/repairveh [<vehicle_id>] (repair the vehicle)', player, 172, 245, 83)
            outputChatBox('/playervehs <character_id> (displays the player vehicles list)', player, 172, 245, 83)
            outputChatBox('/setvhealth <vehicle_id> <health_amount> (sets the vehicle health)', player, 172, 245, 83)
            outputChatBox('/athisveh (checks the information of the nearest vehicle)', player, 172, 245, 83)
            outputChatBox('/aunpark <vehicle_id> (unparks a vehicle)', player, 172, 245, 83)
        elseif type == 'house' then
            outputChatBox('House Commands: (parameters with [] are optional)', player, 172, 245, 83)
            outputChatBox('/ch <name> <interior> <price> (creates a house pickup)', player, 172, 245, 83)
            outputChatBox('/dh <house_id> (deletes a house)', player, 172, 245, 83)
            outputChatBox('/gh <house_id> (teleports you to a player)', player, 172, 245, 83)
            outputChatBox('/eh <house_id> <parameter> <value> (edits a house parameter)', player, 172, 245, 83)
        elseif type == 'chat' then
            return
        end
    end
end
addCommandHandler('acommands', aCommands)


    