local SaveManager = {}
local json = require("json")

local function changeToNumbers(t)
    local table = {}
    for k, v in pairs(t) do
        local key = tonumber(k) or k
        local value = type(v) == "table" and changeToNumbers(v) or v

        table[key] = value
    end
    return table
end

local function changeToString(t)
    local table = {}
    for k, v in pairs(t) do
        local key = tostring(k) or k
        local value = type(v) == "table" and changeToString(v) or v

        table[key] = value
    end
    return table
end

function SaveManager.save(fileName, rawData)
    local contents = changeToString(rawData)
    local encodeData = json.encode(contents)
    love.filesystem.write(fileName, encodeData)
end

function SaveManager.load(fileName)
    if love.filesystem.getInfo(fileName) then
        local contents = love.filesystem.read(fileName)
        local decodeData = json.decode(contents)

        return changeToNumbers(decodeData)
    end

    return nil
end

return SaveManager