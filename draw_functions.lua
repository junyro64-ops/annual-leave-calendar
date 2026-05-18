local DrawFunctions = {}

local CELL_SIZE = require("constants").CELL_SIZE
local CELL_TYPE = require("constants").CELL_TYPE
local SCREEN_SIZE = require("constants").SCREEN_SIZE
local POP_UP = require("constants").POP_UP
local MARGIN = require("constants").MARGIN

local Fonts = {
	large = love.graphics.newFont("font/NanumGothic.ttf", 45),
	medium = love.graphics.newFont("font/NanumGothic.ttf", 26),
	small = love.graphics.newFont("font/NanumGothic.ttf", 16)
}

function DrawFunctions.drawWeekdays(weekdayCells, weekDays)
	love.graphics.setFont(Fonts.medium)

	for i=1, #weekdayCells do
		weekdayCells[i]:draw()
		local width = Fonts.medium:getWidth(weekDays[1])
		local height = Fonts.medium:getHeight()
		love.graphics.print(
			weekDays[i], 
			weekdayCells[i].coordinates.x + (CELL_SIZE.WEEKDAY.width - width)/2, 
			weekdayCells[i].coordinates.y + (CELL_SIZE.WEEKDAY.height - height)/2
	)
	end
end

function DrawFunctions.drawCalendar(currentCalendar, cellDates)

	for i=1, #currentCalendar do
		currentCalendar[i]:draw()

		if currentCalendar[i].type == CELL_TYPE.YEAR or currentCalendar[i].type == CELL_TYPE.MONTH then
			love.graphics.setFont(Fonts.large)
		else
			love.graphics.setFont(Fonts.small)			
		end

		love.graphics.print(
			cellDates[i], 
			currentCalendar[i].coordinates.x + MARGIN.indent, 
			currentCalendar[i].coordinates.y
		)
	end
end

function DrawFunctions.dimBackground()
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)
end

function DrawFunctions.popupScreen(message)
	local x = (SCREEN_SIZE.width - POP_UP.width) / 2
	local y = (SCREEN_SIZE.height - POP_UP.height) / 2

	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.rectangle("fill", x, y, POP_UP.width, POP_UP.height)

	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(Fonts.medium)

	love.graphics.print(message, x + 20, y + 20)
end

-- function that prints the error check message at the bottom right corner of the screen
-- can only be used inside love.draw() function
function DrawFunctions.debugMessage(error_message)
	love.graphics.setFont(Fonts.medium)
	love.graphics.print(
		error_message, 
		SCREEN_SIZE.width - Fonts.medium:getWidth(error_message), 
		SCREEN_SIZE.height - Fonts.medium:getHeight()
	)
end

return DrawFunctions