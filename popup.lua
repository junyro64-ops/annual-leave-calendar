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
	instance.is_scrollable = false
	instance.scroll_height = 0

	local closeButton = Button:new(width - 45, 15, 30, 30, "X")
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

function popup:textedited(text, start, legnth)
	for _, element in ipairs(self.children) do
		if element.isActive and element.edit then
			element:edit(text)
		end
	end
end

function popup:textinput(t)
	for _, element in ipairs(self.children) do
		if element.isActive and element.addText then
			element:addText(t)
		end
	end
end

function popup:keypressed(key)
	for _, element in ipairs(self.children) do
		if element.isActive then
			if key == "backspace" then
				element:removeText()
			elseif key == "return" then
				element.isActive = false
			end
		end
	end
end

function popup:addChild(element)
	table.insert(self.children, element)
end

function popup:customDraw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, self.width, self.height, 10, 10)

	love.graphics.setScissor(self.x + 10, self.y + 10, self.width - 20, self.height - 20)

	love.graphics.push()
	love.graphics.translate(0, self.scrollY or 0)

	for _, child in ipairs(self.children) do
		child:draw()
	end

	love.graphics.pop()

	love.graphics.setScissor()
end

local function getGlobalCoordinates(self)
	local x, y = love.mouse.getPosition()
	return x - self.x, y - self.y - (self.scrollY or 0)
end

function popup:update(dt)
	local x, y = getGlobalCoordinates(self)

	for _, child in ipairs(self.children) do
		if child.update then
			child:update(dt, x, y)
		end
	end
end

function popup:mousePressed(button)
	local x, y = getGlobalCoordinates(self)

	for _, element in ipairs(self.children) do
		element.isActive = false
	end

	for _, element in ipairs(self.children) do
		if element:isClicked(x, y) then
			element.isActive = true
			if element.onClick then
				element:onClick()
			end
			return true
		end
	end

	return false
end

return popup