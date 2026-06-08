local SaveManager = require("save_manager")
local EmployeeManager = require("employee_manager")
local CalendarManager = require("calendar_manager")
local UIManager = require("ui_manager")

local SCREEN_SIZE = require("constants").SCREEN_SIZE

local function loadData()
	local saveData = SaveManager.load("calendar_save_data.json")

	if saveData then
		EmployeeManager.database = saveData.employees
		EmployeeManager.leaveDateList = saveData.leaveDates
		CalendarManager.holidayTable = saveData.holidays
	else
		EmployeeManager.database = {}
		EmployeeManager.leaveDateList = {}
		CalendarManager.holidayTable = {}
	end
end

local function saveData()
	local Data = {
		employees = EmployeeManager.database,
		leaveDates = EmployeeManager.leaveDateList,
		holidays = CalendarManager.holidayTable
	}
	SaveManager.save("calendar_save_data.json", Data)
end

function love.load()
	love.keyboard.setKeyRepeat(true)
	
	loadData()

	-- get the current system time
	UIManager.setCurrentDate()
	local year = UIManager.getCurrentYear()
	local month = UIManager.getCurrentMonth()

	for k, v in pairs(EmployeeManager.database) do
		EmployeeManager.checkLeaveStart(k, year, month)
	end

	UIManager.loadWeekdays()
	UIManager.loadCalendar(year, month)
	love.window.setMode(SCREEN_SIZE.width, SCREEN_SIZE.height)
	love.graphics.setBackgroundColor(1,1,1)
end

function love.wheelmoved(x, y)
	UIManager.wheelmoved(x, y)
end

function love.textedited(text, start, length)
	UIManager.textedited(text, start, length)
end

function love.textinput(t)
	UIManager.textinput(t)
end

function love.keypressed(key, scancode, isrepeat)
	UIManager.keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    UIManager.mousePressed(x, y, button, presses)
end

function love.update(dt)
	UIManager:update(dt)
end

function love.draw()
	
	UIManager.draw()

end

-- The save file is located in the following directory:
-- C:\Users\(user)\AppData\Roaming\LOVE\calendar
function love.quit()
	saveData()

	return false
end
