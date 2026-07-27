local UIElement = require("ui_element")

local Cell = setmetatable({}, {__index = UIElement})
Cell.__index = Cell

function Cell:new(x, y, width, height, type, value)
    local instance = UIElement:new(x, y, width, height)

    instance.type = type
    instance.value = value

    instance.line = true

    setmetatable(instance, Cell)

    return instance
end

function Cell:disableLine()
    self.line = false
end

function Cell:customDraw()
    if self.line == true then
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
    end
    
    for i, child in ipairs(self.children) do
        if i == 4 then
            love.graphics.print("외 " .. #self.children - 4 .. "명", 0, 90)
            return
        end
		if child.draw then
			child:draw()
		end
	end
end

return Cell