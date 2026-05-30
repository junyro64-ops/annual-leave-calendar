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

    instance.textToLeft = false

    instance.hasGraphic = false
    instance.graphicIdle = nil
    instance.graphicHover = nil
    instance.graphicPress = nil

    instance.drawLine = false

    setmetatable(instance, Button)

    return instance
end

function Button:update(dt, mouse_x, mouse_y)
    local x = mouse_x or love.mouse.getX()
    local y = mouse_y or love.mouse.getY()

    local isHovering = self:isClicked(x, y)

    if isHovering then
        if love.mouse.isDown(1) then
            self.state = STATE.PRESSED
        else
            self.state = STATE.HOVER
        end
    else
        self.state = STATE.IDLE
    end
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

function Button:setTextToLeft()
    self.textToLeft = true
end

function Button:customDraw()

    if self.hasGraphic then
        local image = self.graphicIdle

        if self.state == STATE.HOVER and self.graphicHover then
            image = self.graphicHover
        elseif self.state == STATE.PRESSED and self.graphicPress then
            image = self.graphicPress
        end
        love.graphics.setColor(1,1,1)
        love.graphics.draw(image, 0, 0)
    elseif self.drawLine == true then
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(self.Fonts.medium)
    local width = self.Fonts.medium:getWidth(self.text)
    local height = self.Fonts.medium:getHeight()
    local x_pos = (self.width - width) / 2
    local y_pos = (self.height - height) / 2
    if self.textToLeft then
        x_pos = 0
    end
    love.graphics.print(self.text, x_pos, y_pos)
end

return Button