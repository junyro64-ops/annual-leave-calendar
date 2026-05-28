local UIElement = require("ui_element")
local Button = require("button")

local popup = setmetatable({}, {__index = UIElement})
popup.__index = popup

function popup:new(width, height, onClose)
	local screen_x, screen_y = love.graphics.getDimensions()
	local x = (screen_x - width) / 2
	local y = (screen_y - height) / 2

	local instance = UIElement:new(x, y, width, height)
	setmetatable(instance, popup)

	instance.children = {}

	local closeButton = Button:new(width - 40, 5, 30, 30, "X")
	closeButton:setOnClick(
		function()
			if onClose then
				onClose()
			end
		end
	)
	closeButton:setDrawLine()
	table.insert(instance.children, closeButton)
	
	return instance
end

function popup:addChild(element)
	table.insert(self.children, element)
end

function popup:customDraw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, self.width, self.height, 10, 10)

	for _, child in ipairs(self.children) do
		child:draw()
	end
end

function popup:mousePressed(screenX, screenY, button)
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