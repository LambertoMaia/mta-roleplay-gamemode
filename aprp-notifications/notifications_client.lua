addEvent('_Notification_', true)

loadstring(exports.dgs:dgsImportFunction())()
local displayingNotifications = {}

function notificationPopup(notification, notification_title, height, r, g, b, alpha)
    local screenW, screenH = dgsGetScreenSize()
    notificationWindow = dgsCreateWindow(screenW - 265 - 20, (screenH - height) / 2, 280, 52, notification_title, false, 0xFFFFFFFF, 25, nil, 0xC8141414, nil, tocolor(r, g, b, alpha))
    dgsWindowSetMovable(notificationWindow, false)
    dgsWindowSetSizable(notificationWindow, false)

    notificationLabel = dgsCreateLabel(0, 0, 280, 25, notification, false, notificationWindow)
    dgsLabelSetHorizontalAlign(notificationLabel, "center")    
    dgsLabelSetVerticalAlign(notificationLabel, 'center')

    notificationWindow:setData('notification:notification', notification)
    notificationWindow:setData('notification:notification_title', notification_title)
    notificationWindow:setData('notification:height', height)

    table.insert(displayingNotifications, notificationWindow)

    setTimer(killNotification, 5000, 1, notificationWindow)
    

    triggerEvent('_VehicleSFXPlay_', localPlayer, 'pop')
end

local notifications = {
    invalid_username = "Please enter a valid username/password",
    invalid_password = "Please enter a valid username/password",
    
    invalid_password_size = "Your password must be at least 6 character long"
}

function createNotification(notification, notification_title, r, g, b, alpha)
    -- Check if theres another notification displaying
    if displayingNotifications[notification] then
        print('Already displaying this notification!')
        return
    end
    -- Check if theres any notification being displayed

    if not alpha then
        alpha = 100
    end

    if #displayingNotifications == 0 then
        -- First notification
        notificationPopup(notification, notification_title, 300, r, g, b, alpha)
        return
    end

    local notificationElement = displayingNotifications[#displayingNotifications]

    local height = notificationElement:getData('notification:height') - 120

    notificationPopup(notification, notification_title, height, r, g, b, alpha)
end
addEventHandler('_Notification_', localPlayer, createNotification)

function killNotification(element) 
    for i, k in pairs(displayingNotifications) do
        if k == element then
            destroyElement(k)
            table.remove(displayingNotifications, i)
            return
        end
    end
end
