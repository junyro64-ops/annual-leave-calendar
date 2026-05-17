local CalendarManager = require("calendar_manager")
local EmployeeManager = require("employee_manager")

local LoadFunctions = require("load_functions")
local DrawFunctions = require("draw_functions")

local SCREEN_SIZE = require("constants").SCREEN_SIZE
local ERROR_CHECK = require("constants").ERROR_CHECK

local currentCalendar = {}
local cellDates = {}
local weekDays = {"일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"}
local weekdayCells = {}

local currentYear, currentMonth

local debugCheck = false
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

	weekdayCells = LoadFunctions.loadWeekdays(weekDays)
	currentCalendar, cellDates = LoadFunctions.loadCalendar(currentYear, currentMonth)

	love.window.setMode(SCREEN_SIZE.width, SCREEN_SIZE.height)
	love.graphics.setBackgroundColor(1,1,1)

end

function love.keypressed(key, scancode, isrepeat)
	if key == "left" then
		if currentMonth == 1 then
			currentMonth = 12
			currentYear = currentYear - 1
			CalendarManager.createYearTree(currentYear - 1)
			CalendarManager.destroyYearTree(currentYear + 2)
		else
			currentMonth = currentMonth - 1
		end
	elseif key == "right" then
		if currentMonth == 12 then
			currentMonth = 1
			currentYear = currentYear + 1
			CalendarManager.createYearTree(currentYear + 1)
			CalendarManager.destroyYearTree(currentYear - 2)
		else
			currentMonth = currentMonth + 1
		end
	end
	calendarChanged = true
end

function love.update(dt)
	if calendarChanged then
		currentCalendar, cellDates = LoadFunctions.loadCalendar(currentYear, currentMonth)
		calendarChanged = false
	end
end

function love.draw()

	if debugCheck then
		DrawFunctions.debugMessage(ERROR_CHECK.SUCCESS)
		debugCheck = false
	end

	DrawFunctions.drawWeekdays(weekdayCells, weekDays)
	DrawFunctions.drawCalendar(currentCalendar, cellDates)

end
