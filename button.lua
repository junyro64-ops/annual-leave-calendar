local UIElement = require("ui_element")

local Button = setmetatable({}, {__index = UIElement})
Button.__index = Button

local STATE = {
    IDLE = "IDLE", 
    HOVER = "HOVER", 
    PRESSED = "PRESSED"
}

function Button:new(x, y, width, height, text)
    local instance = UIElement:new(x, y, width, height)

    instance.state = STATE.IDLE
    instance.text = text

    instance.hasGraphic = false
    instance.graphicIdle = nil
    instance.graphicHover = nil
    instance.graphicPress = nil

    instance.drawLine = false

    setmetatable(instance, Button)

    return instance
end

function Button:setDrawLine()
    self.drawLine = true
end

function Button:setGraphic(idle_image, hover_image, pressed_image)
    if idle_image then
        self.graphicIdle = idle_image
        self.hasGraphic = true
    end
    if hover_image then
        self.graphicHover = hover_image
    end
    if pressed_image then
        self.graphicPress = pressed_image
    end

end

function Button:customDraw()

    if self.hasGraphic then
        local image = self.graphicIdle

        if self.state == STATE.HOVER and self.graphicHover then
            image = self.graphicHover
        elseif self.state == STATE.PRESSED and self.graphicPress then
            image = self.graphicPress
        end

        love.graphics.draw(image, 0, 0)
    elseif self.drawLine == true then
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
    end
    love.graphics.setFont(self.Fonts.medium)
    local width = self.Fonts.medium:getWidth(self.text)
    local height = self.Fonts.medium:getHeight()
    love.graphics.print(self.text, (self.width - width) / 2, (self.height - height) / 2)
end

return Button