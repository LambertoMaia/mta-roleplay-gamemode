local peds = {}
function createPedestrian(player, command)
    -- Creates a random ped to test the chat function
    --
    local x, y, z = getElementPosition(player)
    local ped = createPed(0, x, y, z)
    -- Adding to the table
    table.insert(peds, ped)
end
addCommandHandler('createped', createPedestrian)
