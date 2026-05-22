local UIElement = require("ui_element")

local popup = setmetatable({}, {__index = UIElement})
popup.__index = popup

local width = 400
local height = 300

function popup.new()
  x = (love.graphics.getWidth() - width) / 2
  y = (love.graphics.getHeight() - height) / 2
  
  local instance = UIElement:new(x, y, width, height)
  setmetatable(instance, popup)
  
  return instance
end

return popup