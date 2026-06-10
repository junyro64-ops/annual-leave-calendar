local UIElement = require("ui_element")
local utf8 = require("utf8")

local TextInput = setmetatable({}, {__index = UIElement})
TextInput.__index = TextInput

function TextInput:new(x, y, width, height)
    local instance = UIElement:new(x, y, width, height)
    setmetatable(instance, self)

    instance.text = ""
    instance.compositeText = ""
    instance.placeholder = "입력..."
    instance.isActive = false

    instance.cursorTimer = 0
    instance.showCursor = true

    instance.entered = nil

    return instance
end

function TextInput:changePlaceHolder (text)
    self.placeholder = text
end

function TextInput:update(dt)
    if self.isActive then
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer > 0.5 then
            self.showCursor = not self.showCursor
            self.cursorTimer = 0
        end
    else
        self.showCursor = false
    end
end

function TextInput:activate()
    self.isActive = true
end

function TextInput:edit(text)
    if self.isActive then
        self.compositeText = text
    end
end

function TextInput:addText(t)
    if self.isActive then
        self.text = self.text .. t
        self.compositeText = ""
    end
end

function TextInput:removeText()
    if self.isActive and string.len(self.text) > 0 then
        local byteoffset = utf8.offset(self.text, -1)
        if byteoffset then
            self.text = string.sub(self.text, 1, byteoffset - 1)
        end
    end
end

function TextInput:returnText()
    return self.text
end

function TextInput:onClick()
    self.isActive = true
end

function TextInput:setOnEnter(callback)
    self.entered = callback
end

function TextInput:onEnter()
    self.entered()
end

function TextInput:customDraw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    if self.isActive then
        love.graphics.setColor(0.2, 0.6, 1)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.rectangle("line", 0, 0, self.width, self.height)

    love.graphics.setColor(0, 0, 0)
    
    local displayText = self.text
    if self.isActive then
        displayText = self.text .. self.compositeText
    end

    if displayText =="" and not self.isActive then
        love.graphics.setColor(0.6, 0.6, 0.6)
        displayText = self.placeholder
    end

    love.graphics.print(displayText, 10, self.height / 2 - 15)

    if self.showCursor then
        love.graphics.setColor(0, 0, 0)
        local textWidth = love.graphics.getFont():getWidth(displayText)
        love.graphics.line(10 + textWidth + 2, 15, 10 + textWidth + 2, self.height - 15)
    end
end

return TextInput