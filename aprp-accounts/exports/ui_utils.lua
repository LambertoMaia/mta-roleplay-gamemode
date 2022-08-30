function validatePassword(password)
    -- Validate length
    if #password < 6 then
        return {false, 'Your password must be at least 6 characters long'}
    end

    return {true, true}

end

function validateUsername(username)
    if #username < 3 then
        return {false, 'Your username must be at least 3 characters long'}
    end

    return {true, true}
end