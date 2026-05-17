local LoadFunctions = {}

local Cell = require("cell")
local CalendarManager = require("calendar_manager")

local CELL_TYPE = require("constants").CELL_TYPE
local CELL_COUNT = require("constants").CELL_COUNT

-- this function returns weekdayCells
function LoadFunctions.loadWeekdays(weekDays)
    local weekdayCells = {}
	for i=1, #weekDays do
		table.insert(weekdayCells, Cell:new(CELL_TYPE.WEEKDAY, i))
	end
    return weekdayCells
end

-- this function returns currentCalendar, cellDates
function LoadFunctions.loadCalendar(year, month)
	local currentCalendar = {}
	local cellDates = {}

	--local nextMonth = month % 12 + 1
	local previousMonth = (month - 2) % 12 + 1
	local previousMonthYear = (previousMonth > month) and (year - 1) or year
	local previousMonthLastDay = CalendarManager.daysInMonthTable[previousMonthYear][previousMonth]
	local currentStartWeekday = CalendarManager.startingWeekDayTable[year][month]
	local currentLastDay = currentStartWeekday + CalendarManager.daysInMonthTable[year][month] - 1

	--Insert the year and the month on the calendar and cellDates table for initialization
	table.insert(currentCalendar, Cell:new(CELL_TYPE.YEAR, year))
	table.insert(currentCalendar, Cell:new(CELL_TYPE.MONTH, month))
	table.insert(cellDates, year)
	table.insert(cellDates, month)

	for i=1, CELL_COUNT do
		table.insert(currentCalendar, Cell:new(CELL_TYPE.DAY, i))
		
		if i < currentStartWeekday then
			table.insert(cellDates, previousMonthLastDay - (currentStartWeekday - i) + 1)
		elseif i > currentLastDay then
			table.insert(cellDates, i - currentLastDay)
		else
			table.insert(cellDates, i - currentStartWeekday + 1)
		end
	end

    return currentCalendar, cellDates
end

return LoadFunctions
