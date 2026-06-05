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
	instance.scroll_width = 0
	instance.scroll_height = 0
	instance.scroll_window_x = 0
	instance.scroll_window_y = 0

	if onClose then
		local closeButton = Button:new(width - 45, 15, 30, 30, "X")
		closeButton:setOnClick(
			function()
					onClose()
				end
			)
		closeButton:setDrawLine()
		table.insert(instance.children, closeButton)
	end
	
	return instance
end

function popup:setPositionToClick(x, y, reverse)
	self.x = x
	self.y = reverse and (y - self.height) or y
end

function popup:setScrollWindow(width, height)
	self.scroll_width = width
	self.scroll_height = height
	self.scroll_window_x = self.x + ((self.width - self.scroll_width) / 2)
	self.scroll_window_y = self.y + ((self.height - self.scroll_height) / 2)
end

function popup:textedited(text, start, length)
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

	for _, child in ipairs(self.children) do
		if child.isStatic then
			child:draw()
		end
	end

	if self.is_scrollable then

		-- setScissor ignores local translations and always require absolute screen coordinates
		love.graphics.setScissor(
			self.scroll_window_x, 
			self.scroll_window_y, 
			self.scroll_width, 
			self.scroll_height
		)

		love.graphics.push()
		love.graphics.translate(0, self.scrollY or 0)

		for _, child in ipairs(self.children) do
			if not child.isStatic then
				child:draw()
			end
		end

		love.graphics.pop()
		love.graphics.setScissor()
	end
end

local function getLocalCoordinate(self)
	local x, y = love.mouse.getPosition()
	return x - self.x, y - self.y
end

function popup:update(dt)
	local x, y = getLocalCoordinate(self)

	for _, element in ipairs(self.children) do
		if element.update then
			element:update(dt, x, y)
		end
	end
end

local function activateClick(element, x, y, click, presses)
	if element:isClicked(x, y) then
		element.isActive = true
		if presses > 1 and element.onDoubleClick then
			element:onDoubleClick()
		end
		if click == 1 and element.onClick then
            element:onClick()
        elseif click == 2 and element.rightClick then
            element:rightClick()
        end
		return true
	end
	return false
end

function popup:mousePressed(mouseButton, presses)
	local x, y = getLocalCoordinate(self)

	for _, element in ipairs(self.children) do
		element.isActive = false
	end

	for _, element in ipairs(self.children) do

		if element.isStatic then
			if activateClick(element, x, y, mouseButton, presses) then return true end
		else
			local top = self.scroll_window_y - self.y
			local bottom = top + self.scroll_height

			if y >= top and y <= bottom then
				local local_y = y - (self.scrollY or 0)
				if activateClick(element, x, local_y, mouseButton, presses) then return true end
			end
		end

	end

	return false
end

return popup