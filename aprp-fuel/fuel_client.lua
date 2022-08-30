local screenW, screenH = guiGetScreenSize ( ) -- Get the screen resolution (width and height)

addEvent('_ServerFuelStart_', true)
addEvent('_ServerFuelStop_', true)

function createText ( )
    local vehicle = getPedOccupiedVehicle(getLocalPlayer())
    
    if vehicle then
        local vehicle_seat = getPedOccupiedVehicleSeat(getLocalPlayer())
        
        if vehicle_seat == 0 then
            local vehicle_fuel = vehicle:getData('vehicle:fuel')

            vehicle_fuel = math.floor(tonumber(vehicle_fuel) + 0.05)

            dxDrawText('Fuel: ' .. tostring(vehicle_fuel), screenW * 0.0695, screenH * 0.7000, screenW * 0.2094, screenH * 0.7325, tocolor(255, 255, 255, 255), 0.80, "bankgothic", "center", "top", false, false, false, false, false)
        end
    end
end

function HandleTheRendering ()
    addEventHandler ( "onClientRender", root, createText) -- keep the text visible with onClientRender.
end
addEventHandler ( "_ServerFuelStart_", resourceRoot, HandleTheRendering )

function destroyText()
    removeEventHandler('onClientRender', root, createText)
end
addEventHandler('_ServerFuelStop_', resourceRoot, destroyText)
