local UIManager = {
    elements = {},
    currentCalendar = {},
    weekDays = {}
}

UIManager.activePopup = {}

local Button = require("button")

local CalendarManager = require("calendar_manager")
local EmployeeManager = require("employee_manager")

local Cell = require("cell")
local CELL_COUNT = require("constants").CELL_COUNT
local CELL_TYPE = require("constants").CELL_TYPE
local CELL_SIZE = require("constants").CELL_SIZE
local cellDates = {}
local week = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"}

local SCREEN_SIZE = require("constants").SCREEN_SIZE
local MARGIN = require("constants").MARGIN

local Fonts = require("constants").FONTS

local popup = require("popup")
local TextInput = require("text_input")

local ButtonGraphics = {
    idle = love.graphics.newImage("ui/button_idle.png"),
    hover = love.graphics.newImage("ui/button_hover.png"),
    click = love.graphics.newImage("ui/button_click.png")
}

local function deleteCalendar()
    UIManager.elements = {}
    UIManager.currentCalendar = {}
    cellDates = {}
end

local function createButton(x, y, width, height, text)
    local button = Button:new(x, y, width, height, text)
    
    button:setGraphic(ButtonGraphics.idle, ButtonGraphics.hover, ButtonGraphics.click)
    table.insert(UIManager.elements, button)
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

function UIManager:update(dt)
    if #UIManager.activePopup > 0 then 
        local popup = UIManager.activePopup[#UIManager.activePopup]
        if popup.update then
            popup:update(dt)
        end
        return 
    end

    for i=1, #UIManager.elements do
        local element = UIManager.elements[i]
        if element.update then
            element:update(dt)
        end
    end
end

function UIManager.textedited(text, start, length)
    if #UIManager.activePopup > 0 then
        local popup = UIManager.activePopup[#UIManager.activePopup]
        if popup.textedited then
            popup:textedited(text, start, length)
        end
    end
end

function UIManager.textinput(t)
    local popup = UIManager.activePopup[#UIManager.activePopup]
    if popup.textinput then
        popup:textinput(t)
    end
end

function UIManager.keypressed(key)
    if key == "escape" then
        table.remove(UIManager.activePopup)
        return
    end
    local popup = UIManager.activePopup[#UIManager.activePopup]
    popup:keypressed(key)
end

function UIManager.loadWeekdays()
    local x, y
    
	for i=1, #week do
        x, y = calculatePos(CELL_TYPE.WEEKDAY, i)
		local weekCell = Cell:new(x, y, CELL_SIZE.WEEKDAY.width, CELL_SIZE.WEEKDAY.height, CELL_TYPE.WEEKDAY, i)
        table.insert(UIManager.weekDays, weekCell)
	end
end

local function closePopup()
    if #UIManager.activePopup > 0 then
        table.remove(UIManager.activePopup)
    end
end

local function openApplyLeavePopup()
    local applyLeavePopup = popup:new(300, 200, closePopup)
    table.insert(UIManager.activePopup, applyLeavePopup)
end

local function setCellPopup(cell, width, height, year, month, day)
    cell:setOnClick(
        function()
            if cell.type == CELL_TYPE.YEAR or cell.type == CELL_TYPE.MONTH then return end

            local popupCell = popup:new(width, height, closePopup)
            
            local date = string.format("%02d/%02d/%02d", year, month, day)
            local setDate = Button:new(0, 0, 200, 50, date)
            popupCell:addChild(setDate)

            popupCell.employeesOnLeave = {}
            
            local applyLeaveButton = Button:new(20, height - 50, 120, 40, "연차신청")
            applyLeaveButton:setOnClick(
                function()
                    openApplyLeavePopup()
                end
            )
            applyLeaveButton:setDrawLine()
            popupCell:addChild(applyLeaveButton)

            table.insert(UIManager.activePopup, popupCell)
        end
    )
end

local function setInputTitles(popup, x, y, text)
    local width = 300
    local height = 100
    local inputTitle = Button:new(x, y, width, height, text)
    inputTitle:setTextToLeft()
    inputTitle:setDrawLine()
    popup:addChild(inputTitle)
end

local function addEmployee()
    local popup = popup:new(800, 600, closePopup)
    local x = 50
    local y = 100
    setInputTitles(popup, x, y,     "이름")
    setInputTitles(popup, x, y * 2, "총 연차 회수")
    setInputTitles(popup, x, y * 3, "연차 시작 연")
    setInputTitles(popup, x, y * 4, "연차 시작 월")
    local nameInput = TextInput:new(x + 300, y, 300, 100)
    popup:addChild(nameInput)
    local maxLeaveInput = TextInput:new(x + 300, y * 2, 300, 100)
    popup:addChild(maxLeaveInput)

    table.insert(UIManager.activePopup, popup)
end

function UIManager.loadCalendar(year, month)
    local x, y

	deleteCalendar()

    --this block uses calendar manager
	--local nextMonth = month % 12 + 1
	local previousMonth = (month - 2) % 12 + 1
	local previousMonthYear = (previousMonth > month) and (year - 1) or year
	local previousMonthLastDay = CalendarManager.daysInMonthTable[previousMonthYear][previousMonth]
	local currentStartWeekday = CalendarManager.startingWeekDayTable[year][month]
	local currentLastDay = currentStartWeekday + CalendarManager.daysInMonthTable[year][month] - 1

	--Insert the year and the month on the calendar and cellDates table for initialization
    -- year cell:
    x, y = calculatePos(CELL_TYPE.YEAR, year)
	local yearCell = Cell:new(x, y, CELL_SIZE.YEAR.width, CELL_SIZE.YEAR.height, CELL_TYPE.YEAR, year)
    table.insert(UIManager.currentCalendar, yearCell)
    -- month cell:
    x, y = calculatePos(CELL_TYPE.MONTH, month)
	local monthCell = Cell:new(x, y, CELL_SIZE.MONTH.width, CELL_SIZE.MONTH.height, CELL_TYPE.MONTH, month)
    table.insert(UIManager.currentCalendar, monthCell)
	table.insert(cellDates, year)
	table.insert(cellDates, month)
    -- day cell:
	for i=1, CELL_COUNT do
        x, y = calculatePos(CELL_TYPE.DAY, i)
        local dayCell = Cell:new(x, y, CELL_SIZE.DAY.width, CELL_SIZE.DAY.height, CELL_TYPE.DAY, i)
		
		if i < currentStartWeekday then
			table.insert(cellDates, previousMonthLastDay - (currentStartWeekday - i) + 1)
		elseif i > currentLastDay then
			table.insert(cellDates, i - currentLastDay)
		else
			table.insert(cellDates, i - currentStartWeekday + 1)

            -- creates a popup when the cell is clicked
            setCellPopup(dayCell, 400, 300, year, month, i - currentStartWeekday + 1)
		end

        table.insert(UIManager.currentCalendar, dayCell)
	end

    -- add employee button position:
    x = 100
    y = y + CELL_SIZE.DAY.height + 10

    local add_employee_button = createButton(x, y, 200, 50, "사원추가")
    add_employee_button:setOnClick(
        function()
            addEmployee()
        end
    )
end

function UIManager.mousePressed(x, y, mouseButton)
    if #UIManager.activePopup > 0 then
        local topIndex = #UIManager.activePopup
        local topPopup = UIManager.activePopup[topIndex]

        if topPopup:isClicked(x, y) == false then
            table.remove(UIManager.activePopup, topIndex)
            return true
        end

        if topPopup.mousePressed then
            topPopup:mousePressed(mouseButton)
        end

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

    if #UIManager.activePopup > 0 then
        for i=1, #UIManager.activePopup do
            UIManager.dimBackground()
            UIManager.activePopup[i]:draw()
        end
    end
    
end

function UIManager.dimBackground()
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)
end

return UIManager