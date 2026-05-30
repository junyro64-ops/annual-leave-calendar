local UIManager = {
    elements = {},
    currentCalendar = {},
    weekDays = {}
}

UIManager.activePopup = {}

local GraphicsButton = require("graphics_button")

local CalendarManager = require("calendar_manager")
local EmployeeManager = require("employee_manager")
local PopupManager = require("popup_manager")

local Cell = require("cell")
local CELL_COUNT = require("constants").CELL_COUNT
local CELL_TYPE = require("constants").CELL_TYPE
local CELL_SIZE = require("constants").CELL_SIZE
local cellDates = {}
local week = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"}

local SCREEN_SIZE = require("constants").SCREEN_SIZE
local MARGIN = require("constants").MARGIN

local ERROR_CHECK = require("constants").ERROR_CHECK

local Fonts = require("constants").FONTS

local currentYear = 0
local currentMonth = 0

local calendar_changed = false

function UIManager.calendarChanged()
    calendar_changed = true
end

local function setCurrentYear(year)
    currentYear = year
end

local function setCurrentMonth(month)
    currentMonth = month
end

function UIManager.getCurrentYear()
    return currentYear
end

function UIManager.getCurrentMonth()
    return currentMonth
end

function UIManager.setCurrentDate()
	local currentDate = os.date("*t")
	setCurrentYear(currentDate.year)
	setCurrentMonth(currentDate.month)
end

function UIManager:update(dt)
	if calendar_changed then
		UIManager.loadCalendar(currentYear, currentMonth)
		calendar_changed = false
	end
    if #PopupManager.activePopup > 0 then 
        local popup = PopupManager.activePopup[#PopupManager.activePopup]
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

function UIManager.checkActivePopup()
    return #PopupManager.activePopup > 0
end

function UIManager.textedited(text, start, length)
    if #PopupManager.activePopup == 0 then return end

    local popup = PopupManager.activePopup[#PopupManager.activePopup]
    if popup.textedited then
        popup:textedited(text, start, length)
    end
  
end

function UIManager.textinput(t)
    if #PopupManager.activePopup == 0 then return end
    
    local popup = PopupManager.activePopup[#PopupManager.activePopup]
    if popup.textinput then
        popup:textinput(t)
    end
    
end

function UIManager.keypressed(key)
    if #PopupManager.activePopup > 0 then 
        if key == "escape" then
            table.remove(PopupManager.activePopup)
            return
        end
        local popup = PopupManager.activePopup[#PopupManager.activePopup]
        popup:keypressed(key)

        return 
    else
        if key == "left" then
            if currentMonth == 1 then
                currentMonth = 12
                currentYear = currentYear - 1
                CalendarManager.createYearTree(currentYear - 1)
                CalendarManager.destroyYearTree(currentYear + 2)
            else
                currentMonth = currentMonth - 1
            end
            calendar_changed = true
        elseif key == "right" then
            if currentMonth == 12 then
                currentMonth = 1
                currentYear = currentYear + 1
                CalendarManager.createYearTree(currentYear + 1)
                CalendarManager.destroyYearTree(currentYear - 2)
            else
                currentMonth = currentMonth + 1
            end
            calendar_changed = true
        end
    end

end

local function scrolling(popup, x, y)
    popup.scrollY = popup.scrollY or 0

    local scrollSpeed = 40
    popup.scrollY = popup.scrollY + (y * scrollSpeed)

    local buttonHeight = popup.itemStride
    local totalListHeight = #(popup.children) * buttonHeight
    local listWindowHeight = popup.scroll_height

    local maxScroll = math.min(0, listWindowHeight - totalListHeight)

    if popup.scrollY > 0 then
        popup.scrollY = 0
    elseif popup.scrollY < maxScroll then
        popup.scrollY = maxScroll
    end
end

function UIManager.wheelmoved(x, y)
    if #PopupManager.activePopup == 0 then return end
    local popup = PopupManager.activePopup[#PopupManager.activePopup]
    if popup.is_scrollable then
        scrolling(popup, x, y)
    end
end

function UIManager.mousePressed(x, y, mouseButton, presses)
    if #PopupManager.activePopup > 0 then
        local topIndex = #PopupManager.activePopup
        local topPopup = PopupManager.activePopup[topIndex]

        if topPopup:isClicked(x, y) == false then
            table.remove(PopupManager.activePopup, topIndex)
            return true
        end

        if topPopup.mousePressed then
            topPopup:mousePressed(presses)
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

local function deleteCalendar()
    UIManager.elements = {}
    UIManager.currentCalendar = {}
    cellDates = {}
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
		local weekCell = Cell:new(x, y, CELL_SIZE.WEEKDAY.width, CELL_SIZE.WEEKDAY.height, CELL_TYPE.WEEKDAY, i)
        table.insert(UIManager.weekDays, weekCell)
	end
end

function UIManager.createYear(year)
    CalendarManager.createYearTree(year)
end

function UIManager.destroyYear(year)
    CalendarManager.destroyYearTree(year)
end

function UIManager.loadCalendar(year, month)

	-- creates the entire year date table
	CalendarManager.createYearTree(year)
	CalendarManager.createYearTree(year - 1)
	CalendarManager.createYearTree(year + 1)

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
    PopupManager.setYearPopup(yearCell, year, 
        function(selected_number)
            UIManager.loadCalendar(selected_number, month)
            calendar_changed = true
        end
        )
    table.insert(UIManager.currentCalendar, yearCell)
    -- month cell:
    x, y = calculatePos(CELL_TYPE.MONTH, month)
	local monthCell = Cell:new(x, y, CELL_SIZE.MONTH.width, CELL_SIZE.MONTH.height, CELL_TYPE.MONTH, month)
    PopupManager.setMonthPopup(monthCell, 
        function(selected_number)
            UIManager.loadCalendar(year, selected_number)
            calendar_changed = true
        end
        )
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
            PopupManager.setCellPopup(dayCell, 400, 300, year, month, i - currentStartWeekday + 1)
		end

        table.insert(UIManager.currentCalendar, dayCell)
	end

    -- add employee button position:
    x = 100
    y = y + CELL_SIZE.DAY.height + 10

    local add_employee_button = GraphicsButton.createButton(x, y, "사원등록")
    table.insert(UIManager.elements, add_employee_button)
    add_employee_button:setOnClick(
        function()
            PopupManager.addEmployee()
        end
    )

    local show_employee_button = GraphicsButton.createButton(x + 200 +50, y, "사원목록")
    table.insert(UIManager.elements, show_employee_button)
    show_employee_button:setOnClick(
        function()
            PopupManager.showEmployee()
        end
    )
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

    if #PopupManager.activePopup > 0 then
        for i=1, #PopupManager.activePopup do
            UIManager.dimBackground()
            PopupManager.activePopup[i]:draw()
        end
    end
    
end

function UIManager.dimBackground()
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)
end

return UIManager