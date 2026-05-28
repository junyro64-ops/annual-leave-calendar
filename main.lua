local ErrorCheck = require("error_check_module")

local CalendarManager = require("calendar_manager")
local EmployeeManager = require("employee_manager")
local UIManager = require("ui_manager")

local SCREEN_SIZE = require("constants").SCREEN_SIZE
local ERROR_CHECK = require("constants").ERROR_CHECK

local currentYear, currentMonth

local debugCheck = false
local error_message = ""
local calendarChanged = false


function love.load()

	-- get the current system time
	local currentDate = os.date("*t")
	currentYear = currentDate.year
	currentMonth = currentDate.month

	-- creates the entire year date table
	CalendarManager.createYearTree(currentYear)
	CalendarManager.createYearTree(currentYear - 1)
	CalendarManager.createYearTree(currentYear + 1)

	UIManager.loadWeekdays()
	UIManager.loadCalendar(currentYear, currentMonth)
	love.window.setMode(SCREEN_SIZE.width, SCREEN_SIZE.height)
	love.graphics.setBackgroundColor(1,1,1)
end

function love.keypressed(key, scancode, isrepeat)
	if UIManager.activePopup then return end

	if key == "left" then
		if currentMonth == 1 then
			currentMonth = 12
			currentYear = currentYear - 1
			CalendarManager.createYearTree(currentYear - 1)
			CalendarManager.destroyYearTree(currentYear + 2)
		else
			currentMonth = currentMonth - 1
		end
		calendarChanged = true
	elseif key == "right" then
		if currentMonth == 12 then
			currentMonth = 1
			currentYear = currentYear + 1
			CalendarManager.createYearTree(currentYear + 1)
			CalendarManager.destroyYearTree(currentYear - 2)
		else
			currentMonth = currentMonth + 1
		end
		calendarChanged = true
	end
end

function love.mousepressed(x, y, button, istouch, presses)
    UIManager.mousePressed(x, y, button)
end

function love.update(dt)
	if calendarChanged then
		UIManager.loadCalendar(currentYear, currentMonth)
		calendarChanged = false
	end
	UIManager:update(dt)
end

function love.draw()
	
	UIManager.draw()

end
