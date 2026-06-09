local UIElement = {}
UIElement.__index = UIElement

local Constants = require("constants")

function UIElement:new(x, y, width, height)
    local instance = {
        x = x or 0,
        y = y or 0,
        width = width or 0,
        height = height or 0,
        children = {}
    }
    setmetatable(instance, self)

    instance.Fonts = Constants.FONTS
    instance.FONT_COLOR = Constants.FONT_COLOR
    instance.fontColor = {0, 0, 0}
    instance.callback = nil
    instance.doubleClick = nil
    instance.rightClick = nil

    instance.isStatic = true

    return instance
end

function UIElement:addChild(element)
    table.insert(self.children, element)
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

function UIElement:onRightClick()
    if self.rightClick then
        self.rightClick()
    end
end

function UIElement:onDoubleClick()
    if self.doubleClick then
        self.doubleClick()
    end
end

function UIElement:mousePressed(_x, _y, mouseButton, presses)
    if not self:isClicked(_x, _y) then return false end
    
	local x = _x - self.x
	local y = _y - self.y

    for i = #self.children, 1, -1 do
        local element = self.children[i]
        if element:mousePressed(x, y, mouseButton, presses) then
            return true
        end
    end

    self.isActive = true
    
    if presses > 1 and mouseButton == 1 and self.onDoubleClick then
        self:onDoubleClick()
    end
    if mouseButton == 1 and self.onClick then
        self:onClick()
    elseif mouseButton == 2 and self.onRightClick then
        self:onRightClick()
    end

	return true
end

function UIElement:setFontColor(color)
    if color == self.FONT_COLOR.RED then
        self.fontColor = {1, 0, 0}
    elseif color == self.FONT_COLOR.BLUE then
        self.fontColor = {0, 0, 1}
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