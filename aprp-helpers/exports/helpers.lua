function showTime ()
	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second

    local monthday = time.monthday
	local month = time.month
	local year = time.year

    local formattedTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year + 1900, month + 1, monthday, hours, minutes, seconds)
	return formattedTime
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function trim1(s) 
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end 

function split1 (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function clear1(s)
    s = s:gsub('%[', '')
    s = s:gsub('%]', '')
    s = trim1(s)
    return split1(s, ',')
end

function toggleCursor(source)
    if isCursorShowing(source) then
        showCursor(source, false)
    else
        showCursor(source, true)
    end
end

addEventHandler('onPlayerJoin', root, 
    function () 
        bindKey(source, 'm', 'down', toggleCursor)
    end
)

function getNearestVehicle(player,distance)
    local lastMinDis = distance-0.0001
    local nearestVeh = false
    local px,py,pz = getElementPosition(player)
    local pint = getElementInterior(player)
    local pdim = getElementDimension(player)

    for _,v in pairs(getElementsByType("vehicle")) do
        local vint,vdim = getElementInterior(v),getElementDimension(v)
        if vint == pint and vdim == pdim then
            local vx,vy,vz = getElementPosition(v)
            local dis = getDistanceBetweenPoints3D(px,py,pz,vx,vy,vz)
            if dis < distance then
                if dis < lastMinDis then 
                    lastMinDis = dis
                    nearestVeh = v
                end
            end
        end
    end
    return nearestVeh
end

function isElementMoving (theElement )
   if isElement ( theElement ) then                                   -- First check if the given argument is an element
      return Vector3( getElementVelocity( theElement ) ).length ~= 0
   end
   return false
end


-- List of vehicles that doens't need to be started
local vehicles = {
    'Andromada', 'AT-400', 'Beagle', 'Cropduster', 'Dodo', 'Hydra', 'Nevada',
    'Rustler', 'Shamal', 'Skimmer', 'Stuntplane', 'Cargobob', 'Hunter', 'Leviathan',
    'Maverick', 'News Chopper', 'Police Maverick', 'Raindance', 'Seasparrow', 'Sparrow',
    'Coastguard', 'Dinghy', 'Jetmax', 'Marquis', 'Predator', 'Reefer', 'Speeder', 'Squalo',
    'Tropic', 'Bike', 'BMX', 'Mountain Bike', 'Vortex'
}

function wontStartVehicles(vehicle_name)
    if has_value(vehicles, vehicle_name) then
        return true
    else
        return false
    end
end

function me(player, command)
    -- Displays player char id and id
    --
    print(player, command)
    local player_id     = player:getData('id')
    local character_id  = player:getData('charid')

    outputChatBox('Player ID: ' .. tostring(player_id), player, 255, 255, 255)
    outputChatBox('Character ID: ' .. tostring(character_id), player, 255, 255, 255)
end
addCommandHandler('meinfo', me)

local sentMessage = {}

function addSentMessage(message, element, timeToKill)
    table.insert(sentMessage, {element, message})
    setTimer(killMessage, timeToKill, 1, element, message)
end

function killMessage(element, message)
    for i, k in pairs(sentMessage) do
        local el = k[1]
        local me = k[2]
        if element == el and message == me then
            table.remove(sentMessage, i)
            return
        end
    end
end

function isMessageSent(message, element)
    if #sentMessage == 0 then
        return false
    end

    for i, k in ipairs(sentMessage) do
        local el = k[1]
        local me = k[2]
        if element == el and message == me then
            return true
        end
    end
    return false
end


function has_value2(list, key)
    if values[key] == nil then
        return false
    else
        return true
    end
end
