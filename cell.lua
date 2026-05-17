local Cell = {}
Cell.__index = Cell

local CELL_TYPE = require("constants").CELL_TYPE
local CELL_SIZE = require("constants").CELL_SIZE
local MARGIN = require("constants").MARGIN

local function drawYear()
    love.graphics.rectangle("line", 0, 0, CELL_SIZE.YEAR.width, CELL_SIZE.YEAR.height)
end

local function drawMonth()
    love.graphics.rectangle("line", 0, 0, CELL_SIZE.MONTH.width, CELL_SIZE.MONTH.height)
end

local function drawDay()
    love.graphics.rectangle("line", 0, 0, CELL_SIZE.DAY.width, CELL_SIZE.DAY.height)
end

local function drawWeekday()
    love.graphics.rectangle("line", 0, 0, CELL_SIZE.WEEKDAY.width, CELL_SIZE.WEEKDAY.height)
end

function Cell:new(type, index)

    local instance = setmetatable({}, self)

    instance.type = type
    instance.value = index

    if instance.type == CELL_TYPE.YEAR then
        instance.coordinates = MARGIN
        instance.drawFunc = drawYear

    elseif instance.type == CELL_TYPE.MONTH then
        instance.coordinates = { x = MARGIN.x + CELL_SIZE.YEAR.width, y = MARGIN.y}
        instance.drawFunc = drawMonth

    elseif instance.type == CELL_TYPE.DAY then
        local offset = index - 1
        instance.coordinates = { 
            x = MARGIN.x + ((offset % 7) * CELL_SIZE.DAY.width),
            y = MARGIN.y + CELL_SIZE.YEAR.height + CELL_SIZE.WEEKDAY.height
                + (math.floor(offset / 7) * CELL_SIZE.DAY.height) 
        }
        instance.drawFunc = drawDay

    elseif instance.type == CELL_TYPE.WEEKDAY then
        instance.coordinates = {
            x = MARGIN.x + (((index - 1) % 7) * CELL_SIZE.WEEKDAY.width),
            y = MARGIN.y + CELL_SIZE.YEAR.height
        }
        instance.drawFunc = drawWeekday
    end

    return instance
end

function Cell:draw()
    love.graphics.push()
    love.graphics.translate(self.coordinates.x, self.coordinates.y)

    love.graphics.setColor(0 , 0, 0)
    
    self.drawFunc()

    love.graphics.pop()
end

return Cell