local injuredPlayers = {}

function characterDeath()
    -- Player killed
    local x, y, z = getElementPosition(source)
    -- Setting player health back to 10
    spawnPlayer(source, x, y, z)
    setCameraTarget(source, source)
    fadeCamera(source, true)
    -- Playing animation
    setPedAnimation(source, 'crack', 'crckdeth2', -1, true, false, false)
    outputChatBox('You are injured and in need of medical assistance', source, 255, 0, 0)
    source:setData('injured', true)
    table.insert(injuredPlayers, source)
end
addEventHandler('onPlayerWasted', root, characterDeath)

function exportInjured()
end