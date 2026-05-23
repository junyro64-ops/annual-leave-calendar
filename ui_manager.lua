local UIManager = {
    elements = {},
    currentCalendar = {},
    weekDays = {}
}

UIManager.popup = nil
UIManager.activePopup = nil

local Button = require("button")

local CalendarManager = require("calendar_manager")

local Cell = require("cell")
local CELL_COUNT = require("constants").CELL_COUNT
local CELL_TYPE = require("constants").CELL_TYPE
local CELL_SIZE = require("constants").CELL_SIZE
local cellDates = {}
local week = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"}

local SCREEN_SIZE = require("constants").SCREEN_SIZE
local POP_UP = require("constants").POP_UP
local MARGIN = require("constants").MARGIN

local Fonts = {
	large = love.graphics.newFont("font/NanumGothic.ttf", 45),
	medium = love.graphics.newFont("font/NanumGothic.ttf", 26),
	small = love.graphics.newFont("font/NanumGothic.ttf", 16)
}

local function registerUI(element)
    table.insert(UIManager.elements, element)
end

local function registerCalendar(cell)
    table.insert(UIManager.currentCalendar, cell)
end

local function registerWeekdays(cell)
    table.insert(UIManager.weekDays, cell)
end

local function deleteCalendar()
    UIManager.currentCalendar = {}
    cellDates = {}
end

function UIManager.createButton(x, y, width, height)
    local button = Button:new(x, y, width, height)
    registerUI(button)
    return button
end

local function calculatePos(type, index)
    local x, y
    if type == CELL_TYPE.YEAR then
        x = MARGIN.x
        y = MARGIN.y
    end
    if type == CELL_TYPE.MONTH then
        x = MARGIN.x + CELL_SIZE.YEAR.width
        y = MARGIN.y
    end
    if type == CELL_TYPE.DAY then
        local offset = index - 1
        x = MARGIN.x + ((offset % 7) * CELL_SIZE.DAY.width)
        y = MARGIN.y + CELL_SIZE.YEAR.height + CELL_SIZE.WEEKDAY.height
            + (math.floor(offset / 7) * CELL_SIZE.DAY.height)
    end
    if type == CELL_TYPE.WEEKDAY then
        x = MARGIN.x + (((index - 1) % 7) * CELL_SIZE.WEEKDAY.width)
        y = MARGIN.y + CELL_SIZE.YEAR.height
    end

    return x, y
end

function UIManager.loadWeekdays()
    local x, y
    
	for i=1, #week do
        x, y = calculatePos(CELL_TYPE.WEEKDAY, i)
		registerWeekdays(
            Cell:new(x, y, CELL_SIZE.WEEKDAY.width, CELL_SIZE.WEEKDAY.height, CELL_TYPE.WEEKDAY, i)
        )
	end
end

function UIManager.loadCalendar(year, month)
    local x, y

	deleteCalendar()

  --this block uses calendar manager
  --needs to be decoupled later
	--local nextMonth = month % 12 + 1
	local previousMonth = (month - 2) % 12 + 1
	local previousMonthYear = (previousMonth > month) and (year - 1) or year
	local previousMonthLastDay = CalendarManager.daysInMonthTable[previousMonthYear][previousMonth]
	local currentStartWeekday = CalendarManager.startingWeekDayTable[year][month]
	local currentLastDay = currentStartWeekday + CalendarManager.daysInMonthTable[year][month] - 1

	--Insert the year and the month on the calendar and cellDates table for initialization
    -- year cell:
    x, y = calculatePos(CELL_TYPE.YEAR, year)
	registerCalendar(Cell:new(x, y, CELL_SIZE.YEAR.width, CELL_SIZE.YEAR.height, CELL_TYPE.YEAR, year))
    -- month cell:
    x, y = calculatePos(CELL_TYPE.MONTH, month)
	registerCalendar(Cell:new(x, y, CELL_SIZE.MONTH.width, CELL_SIZE.MONTH.height, CELL_TYPE.MONTH, month))
	table.insert(cellDates, year)
	table.insert(cellDates, month)
    -- day cell:
	for i=1, CELL_COUNT do
        x, y = calculatePos(CELL_TYPE.DAY, i)
		registerCalendar(Cell:new(x, y, CELL_SIZE.DAY.width, CELL_SIZE.DAY.height, CELL_TYPE.DAY, i))
		
		if i < currentStartWeekday then
			table.insert(cellDates, previousMonthLastDay - (currentStartWeekday - i) + 1)
		elseif i > currentLastDay then
			table.insert(cellDates, i - currentLastDay)
		else
			table.insert(cellDates, i - currentStartWeekday + 1)
		end
	end
end

function UIManager.mousePressed(x, y, mouseButton)
    if UIManager.activePopup then
        local popup = UIManager.activePopup

        if popup:isClicked(x, y) == false then
            UIManager.activePopup = nil
            return true
        end

        popup.mousepressed(x, y, mouseButton)
        return true
    end

    if mouseButton == 1 then
        for i = #UIManager.elements, 1, -1 do
            local element = UIManager.elements[i]
            if element:isClicked(x, y) == true then
                if element.onClick then
                    element:onClick()
                end
                return true
            end
        end
        for i = 1, #UIManager.currentCalendar do
            local element = UIManager.currentCalendar[i]
            if element:isClicked(x, y) == true then
                if element.onClick then
                    element:onClick()
                end
                return true
            end
        end
    end
    return false
end

function UIManager.draw()
    for i=1, #UIManager.elements do
        local element = UIManager.elements[i]
        if element.draw then
            element:draw()
        end
    end
    for i=1, #UIManager.currentCalendar do
        local element = UIManager.currentCalendar[i]
        if element.draw then
            element:draw()
        end
		if element.type == CELL_TYPE.DAY then
			love.graphics.setFont(Fonts.small)
		else
			love.graphics.setFont(Fonts.large)			
		end

		love.graphics.print(
			cellDates[i], 
			element.x + MARGIN.indent, 
			element.y
		)
    end

	love.graphics.setFont(Fonts.medium)
    
    local height = Fonts.medium:getHeight()
    for i=1, #UIManager.weekDays do
        local element = UIManager.weekDays[i]
        if element.draw then
            element:draw()
        end
        local width = Fonts.medium:getWidth(week[i])
		love.graphics.print(
			week[i], 
			element.x + (CELL_SIZE.WEEKDAY.width - width)/2, 
			element.y + (CELL_SIZE.WEEKDAY.height - height)/2
	    )
    end

    if UIManager.activePopup then
        UIManager.activePopup:draw()
    end
    
end

function UIManager.dimBackground()
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)
end

return UIManager