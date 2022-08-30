loadstring(exports.dgs:dgsImportFunction())()

local displayingWindows = {}

addEvent('_CloseLoginWindow_', true)

function loginWindow()

    local screenW, screenH = dgsGetScreenSize()
    loginWindow = dgsCreateWindow((screenW - 227) / 2, (screenH - 149) / 2, 227, 180, "Login/Register", false)
    
    dgsWindowSetMovable(loginWindow, false)
    dgsWindowSetSizable(loginWindow, false)

    usernameField   = dgsCreateEdit(10, 26, 206, 35, "", false, loginWindow)
    passwordField   = dgsCreateEdit(10, 67, 206, 35, "", false, loginWindow)
    loginButton     = dgsCreateButton(10, 109, 207, 30, "Login or Register", false, loginWindow)    
    
    dgsEditSetMasked(passwordField, true)

    showCursor(true)

    dgsWindowSetCloseButtonEnabled(loginWindow, false)

    dgsEditSetPlaceHolder(usernameField, 'Username')
    dgsEditSetPlaceHolder(passwordField, 'Password')

    dgsEditSetAlignment(usernameField, 'center', 'center')
    dgsEditSetAlignment(passwordField, 'center', 'center')

    table.insert(displayingWindows, loginWindow)

    addEventHandler('onDgsMouseClickDown', loginButton, login, false)
    addEventHandler('onDgsDestroy', loginWindow, toggleCursor)

end
addEventHandler('onClientResourceStart', resourceRoot, loginWindow)

function login()
    username = dgsGetText(usernameField)
    password = dgsGetText(passwordField)

    if username == '' or password == '' then
        outputChatBox("Please enter a valid username/password", 255, 255, 0)
        triggerEvent('_Notification_', localPlayer, 'Type a valid username/password', 'Invalid Username/Password', 255, 255, 0, 450)
        return
    end

    local validate_password = exports['aprp-accounts']:validatePassword(password)
    local validate_username = exports['aprp-accounts']:validateUsername(username)

    if not validate_password[1] then
        triggerEvent('_Notification_', localPlayer, validate_password[2], 'Invalid Password', 255, 255, 0)
        return
    end

    if not validate_username[1] then
        triggerEvent('_Notification_', localPlayer, validate_username[2], 'Invalid Password', 255, 255, 0)
        return
    end

    triggerServerEvent('_LoginPlayer_', localPlayer, username, password, localPlayer)
end

function toggleCursor()
    if isCursorShowing() then
        showCursor(false)
    else
        showCursor(true)
    end
end

function closeLoginWindow()
    destroyElement(displayingWindows[1])
    table.remove(displayingWindows, 1)
end

addEventHandler('_CloseLoginWindow_', localPlayer, closeLoginWindow)

    