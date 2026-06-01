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
    instance.FONT_COLOR = require("constants").FONT_COLOR
    instance.fontColor = {0, 0, 0}
    instance.callback = nil
    instance.doubleClick = nil
    instance.rightClick = nil

    instance.isStatic = true

    return instance
end

function UIElement:setOnClick(callback)
    self.callback = callback
end

function UIElement:setOnDoubleClick(callback)
    self.doubleClick = callback
end

function UIElement:setOnRightClick(callback)
    self.rightClick = callback
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

function UIElement:setFontColor(color)
    if color == self.FONT_COLOR.RED then
        self.fontColor = {1, 0, 0}
    elseif color == self.FONT_COLOR.WHITE then
        self.fontColor = {1, 1, 1}
    else
        self.fontColor = {0, 0, 0}
    end
end

function UIElement:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    love.graphics.setColor(self.fontColor[1], self.fontColor[2], self.fontColor[3])

    if self.customDraw then
        self:customDraw()
    end

    love.graphics.pop()
end

return UIElement