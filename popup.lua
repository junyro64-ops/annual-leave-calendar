local UIElement = require("ui_element")
local Button = require("button")

local popup = setmetatable({}, {__index = UIElement})
popup.__index = popup

local width = 400
local height = 300

function popup:new()
  local x = (love.graphics.getWidth() - width) / 2
  local y = (love.graphics.getHeight() - height) / 2
  
  local instance = UIElement:new(x, y, width, height)
  setmetatable(instance, popup)

  instance.date = ""
  instance.employeesOnLeave = {}
  instance.children = {}

  local closeButton = Button:new(width - 40, 10, 30, 30, "X")
  closeButton:setOnClick(
    function()
      local UIManager = require("ui_manager")
      UIManager.activeModal = nil
    end
  )
  table.insert(instance.children, closeButton)

  local addButton = Button:new(20, height - 50, 100, 40, "Add")
  addButton:setOnClick(
    function()

    end
  )
  table.insert(instance.children, addButton)
  
  return instance
end

function popup:setData(date, employees)
  self.date = date
  self.employeesOnLeave = employees
end

function popup:customDraw()
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle("fill", 0, 0, width, height, 10, 10)

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

function popup:mousepressed(screenX, screenY, button)
  local x = screenX - self.x
  local y = screenY - self.y

  for _, child in ipairs(self.children) do
    if child:isClicked(x, y) then
      if child.onClick then
        child:onClick()
      end
      return true
    end
  end

  return false
end

return popup