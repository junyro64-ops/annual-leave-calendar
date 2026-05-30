local GraphicsButton = {}

local Button = require("button")
local ButtonGraphics = require("constants").ButtonGraphics

function GraphicsButton.createButton(x, y, text)
    local button = Button:new(x, y, 200, 60, text)
    
    button:setGraphic(ButtonGraphics.idle, ButtonGraphics.hover, ButtonGraphics.click)
    return button
end

return GraphicsButton