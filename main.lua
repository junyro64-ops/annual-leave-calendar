local SaveManager = require("save_manager")
local EmployeeManager = require("employee_manager")
local CalendarManager = require("calendar_manager")
local UIManager = require("ui_manager")

local SCREEN_SIZE = require("constants").SCREEN_SIZE

function love.load()
	local saveData = SaveManager.load("calendar_save_data.json")

	if saveData then
		EmployeeManager.database = saveData.employees
		CalendarManager.holidayTable = saveData.holidays
	else
		EmployeeManager.database = {}
		CalendarManager.holidayTable = {}
	end

	-- get the current system time
	UIManager.setCurrentDate()

	UIManager.loadWeekdays()
	UIManager.loadCalendar(UIManager.getCurrentYear(), UIManager.getCurrentMonth())
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
	local Data = {
		employees = EmployeeManager.database,
		holidays = CalendarManager.holidayTable
	}
	SaveManager.save("calendar_save_data.json", Data)

	return false
end
