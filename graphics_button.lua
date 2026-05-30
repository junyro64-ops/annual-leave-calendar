local GraphicsButton = {}

local Button = require("button")
local ButtonGraphics = require("constants").ButtonGraphics

function GraphicsButton.createButton(x, y, width, height, text)
    local button = Button:new(x, y, width, height, text)
    
    button:setGraphic(ButtonGraphics.idle, ButtonGraphics.hover, ButtonGraphics.click)
    return button
end

return GraphicsButton