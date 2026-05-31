local UIElement = require("ui_element")

local Cell = setmetatable({}, {__index = UIElement})
Cell.__index = Cell

function Cell:new(x, y, width, height, type, value)
    local instance = UIElement:new(x, y, width, height)

    instance.type = type
    instance.value = value  

    setmetatable(instance, Cell)

    return instance
end

function Cell:customDraw()
    
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    
end

return Cell