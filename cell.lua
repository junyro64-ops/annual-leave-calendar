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

    local width = 400
    local height = 300
    local x = (love.graphics.getWidth() - width) / 2
    local y = (love.graphics.getHeight() - height) / 2
    local PopupCell = require("popup_cell"):new(x, y, width, height)

    local UIManager = require("ui_manager")
    UIManager.activePopup = PopupCell
end

function Cell:customDraw()
    
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    
end

return Cell