addEvent('_VehicleSFXPlay_', true)
addEvent('_VehicleSFXStop3D_', true)
addEvent('_VehicleSFXPlay3D_', true)


local sounds            = {}
local playingSounds     = {}

sounds['handbrake_on']  = "sfx/vehicles/handbrake_on.mp3"
sounds['handbrake_off'] = "sfx/vehicles/handbrake_off.mp3"

sounds['door_chime']    = "sfx/vehicles/door_chime.mp3"

sounds['car_lock']      = "sfx/vehicles/car_lock.mp3"

sounds['seatbelt_on']   = "sfx/vehicles/seatbelt_on.mp3"
sounds['seatbelt_off']  = "sfx/vehicles/seatbelt_off.mp3"

sounds['pop']           = "sfx/ui/pop.mp3"

function soundPlay(sound_name)
    playSound(sounds[sound_name])
end

addEventHandler('_VehicleSFXPlay_', localPlayer, soundPlay)

function soundPlay3D(sound_name, element, loop)
    if not loop then
        loop = false
    end

    local x, y, z = getElementPosition(element)

    local sound = playSound3D(sounds[sound_name], x, y, z, loop)
    setSoundVolume(sound, 0.3)

    attachElements(sound, element)

    if not loop then
        return
    end

    playingSounds[element] = sound
end
addEventHandler('_VehicleSFXPlay3D_', root, soundPlay3D)

function stop3DSound(element)
    local sound = playingSounds[element]
    
    if not sound then
        return
    end

    destroyElement(sound) 
    playingSounds[element] = nil
end
addEventHandler('_VehicleSFXStop3D_', root, stop3DSound)

