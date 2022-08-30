local guis = {}
local grids = {}
local rows = {}

addEvent('_ServerPopulateVehicles_', true)

addEventHandler("onClientResourceStart", resourceRoot,
function()
local screenW, screenH = guiGetScreenSize()
    vehicleListWindow = guiCreateWindow((screenW - 460) / 2, (screenH - 263) / 2, 460, 263, "Vehicle's List", false)
    guiWindowSetMovable(vehicleListWindow, false)
    guiWindowSetSizable(vehicleListWindow, false)

    -- Hidden the gui
    vehicleListWindow:setVisible(false)

    vehiclesGrid = guiCreateGridList(11, 29, 431, 131, false, vehicleListWindow)
    guiGridListAddColumn(vehiclesGrid, "ID", 0.1)
    guiGridListAddColumn(vehiclesGrid, "Vehicle Name", 0.2)
    guiGridListAddColumn(vehiclesGrid, "Location", 0.8)
    guiGridListAddColumn(vehiclesGrid, "Owner Name", 0.3)
    teleportBtn = guiCreateButton(11, 170, 119, 37, "Teleport", false, vehicleListWindow)
    bringBtn = guiCreateButton(11, 217, 119, 36, "Bring to me", false, vehicleListWindow)
    parkBtn = guiCreateButton(140, 170, 119, 37, "Park", false, vehicleListWindow)
    deleteBtn = guiCreateButton(323, 170, 119, 37, "Delete", false, vehicleListWindow)    
    closeMenuBtn = guiCreateButton(323, 216, 119, 37, "Close Menu", false, vehicleListWindow)   

    -- Adding the gui to the table
    table.insert(guis, vehicleListWindow)
    -- Adding the grid to the list
    table.insert(grids, vehiclesGrid)

    -- Adding click events
    addEventHandler('onClientGUIClick', closeMenuBtn, closeMenu)
end
)

function closeMenu()
    showCursor(false)
    guis[1]:setVisible(false)

    -- Wiping the rows

    local count = grids[1]:getRowCount()

    print(count)
    for i, k in pairs(rows) do
        guiGridListRemoveRow(grids[1], rows[i])
    end

end

function populateVehiclesList(vehicles)
    for i, k in pairs(vehicles[2]) do
        local row = grids[1]:addRow(k.id, k.model_name, k.position, k.owner_id)
        table.insert(rows, row)
    end
end
addEventHandler('_ServerPopulateVehicles_', resourceRoot, populateVehiclesList)

function showVehiclesWindow()
    guis[1]:setVisible(true)
    showCursor(true)
    triggerServerEvent('_ClientPopulateVehicles_', resourceRoot)
end
addCommandHandler('vehiclelist', showVehiclesWindow)

