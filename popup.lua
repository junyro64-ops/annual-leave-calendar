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
				if element.onEnter then
					element:onEnter()
				else
					element.isActive = false
				end
			end
		end
	end
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

function popup:update(dt, x, y)
	local x = x - self.x
	local y = y - self.y

	for _, element in ipairs(self.children) do
		if element.update then
			element:update(dt, x, y)
		end
	end
end

function popup:mousePressed(_x, _y, mouseButton, presses)
	local x = _x - self.x
	local y = _y - self.y

	local function deactivate(element)
		element.isActive = false
		if element.children then
			for _, child in ipairs(element.children) do
				deactivate(child)
			end
		end
	end

	for _, element in ipairs(self.children) do
		deactivate(element)
	end

	for i = #self.children, 1, -1 do
		local element = self.children[i]

		if element.isStatic then
			if element:mousePressed(x, y, mouseButton, presses) then
				return true
			end
		else
			local top = self.scroll_window_y - self.y
			local bottom = top + self.scroll_height
		
			if y >= top and y <= bottom then
				local scroll_y = y - (self.scrollY or 0)
				if element:mousePressed(x, scroll_y, mouseButton, presses) then
					return true
				end
			end
		end
	end

	return false
end

return popup