local UIElement = {}
UIElement.__index = UIElement

function UIElement:new(x, y, width, height)
    local instance = {
        x = x or 0,
        y = y or 0,
        width = width or 0,
        height = height or 0
    }
    setmetatable(instance, self)
    return instance
end

function UIElement:isClicked(x, y)
    if x >= self.x and x <= (self.x + self.width) and
        y <= self.y and y <= (self.y + self.height) then
            return true
    end

    return false
end

function UIElement:onClick()
end

function UIElement:draw()
end

return UIElement