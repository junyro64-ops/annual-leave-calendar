local ErrorCheck = {}
local ERROR_CHECK = require("constants").ERROR_CHECK

function ErrorCheck.execute(func, ...)
    local success, result = pcall(func, ...)

    -- pcall resulting in fail is a fatal engine crash
    if not success then
        return nil, ERROR_CHECK.CRASHED
    end

    if result == ERROR_CHECK.FAILED or 
        result == ERROR_CHECK.MAX_REACHED or 
        result == ERROR_CHECK.NOT_FOUND then
        return nil, result
    end

    return result, ERROR_CHECK.SUCCESS
end

return ErrorCheck