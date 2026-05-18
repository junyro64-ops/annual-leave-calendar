local Button = {}

Button.__index = Button

local STATE = {
    IDLE = "IDLE", 
    HOVER = "HOVER", 
    PRESSED = "PRESSED"
}

function Button:new(x, y, width, height)
    local instance = setmetatable({}, self)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height

    instance.onClick = nil

    instance.state = STATE.IDLE

    instance.hasGraphic = false
    instance.graphicIdle = nil
    instance.graphicHover = nil
    instance.graphicPress = nil

    return instance
end

function Button:click()
    if self.onClick then
        self.onClick()
    end
end

function Button:setOnClick(callback)
    self.onClick = callback
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