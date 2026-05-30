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

    instance.Fonts = require("constants").FONTS
    instance.callback = nil
    instance.doubleClick = nil

    instance.isStatic = true

    return instance
end

function UIElement:setOnClick(callback)
    self.callback = callback
end

function UIElement:setOnDoubleClick(callback)
    self.onDoubleClick = callback
end

function UIElement:isClicked(x, y)
    if x >= self.x and x <= (self.x + self.width) and
        y >= self.y and y <= (self.y + self.height) then
            return true
    end

    return false
end

function UIElement:onClick()
    if self.callback then
        self.callback()
    end
end

function UIElement:onDoubleClick()
    if self.doubleClick then
        self.doubleClick()
    end
end

function UIElement:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    love.graphics.setColor(0, 0, 0)

    if self.customDraw then
        self:customDraw()
    end

    love.graphics.pop()
end

return UIElement