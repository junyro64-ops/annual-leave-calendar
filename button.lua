local UIElement = require("ui_element")

local Button = setmetatable({}, {__index = UIElement})
Button.__index = Button

local STATE = {
    IDLE = "IDLE", 
    HOVER = "HOVER", 
    PRESSED = "PRESSED"
}

function Button:new(x, y, width, height, text)
    local instance = UIElement.new(self, x, y, width, height)

    instance.callback = nil

    instance.state = STATE.IDLE
    instance.text = text

    instance.hasGraphic = false
    instance.graphicIdle = nil
    instance.graphicHover = nil
    instance.graphicPress = nil

    setmetatable(instance, Button)

    return instance
end

function Button:onClick()
    if self.callback then
        self.callback()
    end
end

function Button:setOnClick(callback)
    self.callback = callback
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

function Button:draw()
    if self.hasGraphic then
        local image = self.graphicIdle

        if self.state == STATE.HOVER and self.graphicHover then
            image = self.graphicHover
        elseif self.state == STATE.PRESSED and self.graphicPress then
            image = self.graphicPress
        end

        love.graphics.draw(image, self.x, self.y)
    end
end

return Button