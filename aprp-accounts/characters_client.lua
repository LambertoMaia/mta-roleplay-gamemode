addEvent('_ShowCharacterWindow_', true)
addEvent('_RecieveCharacters_', true)
addEvent('_DestroyCharacterWindow_', true)

local windows = {}
local grids   = {}

function characterWindow() 
    local screenW, screenH = dgsGetScreenSize()
    characterWindow = dgsCreateWindow((screenW - 488) / 2, (screenH - 205) / 2, 488, 205, "Select your character or create a new one", false)
    dgsWindowSetMovable(characterWindow, false)
    dgsWindowSetSizable(characterWindow, false)

    dgsWindowSetCloseButtonEnabled(characterWindow, false)

    characterList = dgsCreateGridList(10, 7, 276, 168, false, characterWindow)
    column_id = dgsGridListAddColumn(characterList, "ID", 0.1)
    column_name = dgsGridListAddColumn(characterList, "Character Name", 0.5)
    column_location = dgsGridListAddColumn(characterList, "Location", 0.5)
    selectCharacterButton = dgsCreateButton(0.61, 0.40, 0.37, 0.19, "Select Character", true, characterWindow)
    createCharacterButton = dgsCreateButton(0.61, 0.67, 0.37, 0.19, "Create Character", true, characterWindow)    

    populateCharacters(source:getData('id'))

    table.insert(windows, characterWindow)
    table.insert(grids, characterList)

    addEventHandler('onDgsMouseClickDown', selectCharacterButton, selectCharacter, false)

end

addEventHandler('_ShowCharacterWindow_', localPlayer, characterWindow)

function populateCharacters(account_id)
    -- Trigger the event
    triggerServerEvent('_PopulateCharacters_', localPlayer, account_id)
end

function recieveCharacters(characters)
    for i, k in ipairs(characters[2]) do
        local p = exports['aprp-helpers']:clear1(k.position)
        local row = dgsGridListAddRow(characterList)
        dgsGridListSetItemText(characterList, row, column_id, k.id)
        dgsGridListSetItemText(characterList, row, column_name, k.character_name)
        dgsGridListSetItemText(characterList, row, column_location, getZoneName(p[1], p[2], p[3]))
    end
end
addEventHandler('_RecieveCharacters_', localPlayer, recieveCharacters)

function selectCharacter()
    local selected = dgsGridListGetSelectedItem(characterList)

    if selected == -1 then
        triggerEvent('_Notification_', localPlayer, 'You need to select a character first', 'Error', 255, 255, 0)
        return
    end
    
    selected = dgsGridListGetItemText(characterList, selected, column_id)
    triggerServerEvent('_SelectedCharacter_', localPlayer, selected, localPlayer)
end

function removeCharacterWindow()
    destroyElement(characterWindow)
    showCursor(false)
end
addEventHandler('_DestroyCharacterWindow_', localPlayer, removeCharacterWindow)
