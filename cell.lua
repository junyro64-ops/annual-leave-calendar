local UIElement = require("ui_element")

local Cell = setmetatable({}, {__index = UIElement})
Cell.__index = Cell

function Cell:new(x, y, width, height, type, index)
    local instance = UIElement:new(x, y, width, height)

    instance.type = type
    instance.value = index  

    setmetatable(instance, Cell)

    return instance
end

function Cell:onClick()
    
    -- skip year and month cells when clicked
    local CELL_TYPE = require("constants").CELL_TYPE
    if self.type == CELL_TYPE.YEAR or self.type == CELL_TYPE.MONTH then return end

    local UIManager = require("ui_manager")
    
    local popup = UIManager.popup
    UIManager.activePopup = popup
end

function Cell:customDraw()
    
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    
end

return Cell