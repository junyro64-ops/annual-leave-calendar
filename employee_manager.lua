
local EmployeeManager = {}
EmployeeManager.database = {}

local json = require("json")
local ERROR_CHECK = require("constants").ERROR_CHECK

local saveFileName = "employee_data.json"

function EmployeeManager.addEmployee(name, maxLeave, year, month)
	if EmployeeManager.database[name] then return ERROR_CHECK.DATA_EXIST end
	
	EmployeeManager.database[name] = {
		name = name,
		maxLeave = maxLeave,
		leaveStartYear = year,
		leaveStartMonth = month,
		usedLeave = 0,
		leaveDates = {}
	}

	return ERROR_CHECK.SUCCESS
end

function EmployeeManager.getEmployeeData(name)
	local data = EmployeeManager.database[name]

	if not data then
		return nil
	else
		return data
	end
end

-- this function should run whenver the application loads
--   so that it can reset the leave record for another year
--   but keep the leave dates data for future checks
function EmployeeManager.checkLeaveStart(data, year, month)
	local monthsPassed = ((year - data.leaveStartYear) * 12) + (month - data.leaveStartMonth)

	if monthsPassed >= 12 then
		data.leaveStartYear = data.leaveStartYear + math.floor(monthsPassed / 12)
		data.usedLeave = 0
	end
end

function EmployeeManager.cancelLeave(name, year, month, day, amount)
	local data = EmployeeManager.database[name]
	data.usedLeave = data.usedLeave - amount
	data.leaveDates[year][month][day] = nil
end

-- The current function below might cause an issue when 
--  an employee registers another leave on the same day.
-- This must be looked over later.
function EmployeeManager.useLeave(name, year, month, day, amount)
	-- local data is just a pointer to the employee's database
	-- everything updated on 'data' will actually be set to the employee's database
	local data = EmployeeManager.database[name]

	if not data then
		return ERROR_CHECK.FAILED
	end
	if (data.usedLeave + amount) > data.maxLeave then
		return ERROR_CHECK.MAX_REACHED
	end
	
	data.leaveDates[year] = data.leaveDates[year] or {}
	data.leaveDates[year][month] = data.leaveDates[year][month] or {}
	
	if data.leaveDates[year][month][day] then
		return ERROR_CHECK.DATA_EXIST
	end
	
	data.leaveDates[year][month][day] = amount
	
	data.usedLeave = data.usedLeave + amount

	return ERROR_CHECK.SUCCESS
end

-- The save file is located in the following directory:
-- C:\Users\(user)\AppData\Roaming\LOVE\calendar
function EmployeeManager.saveData()
	local jsonData = json.encode(EmployeeManager.database)

	local success, message = love.filesystem.write(saveFileName, jsonData)

	if success then
		print("Successfully saved!")
	else
		print("Failed: " .. tostring(message))
	end
end

function EmployeeManager.loadData()
	if love.filesystem.getInfo(saveFileName) then
		local contents = love.filesystem.read(saveFileName)

		EmployeeManager.database = json.decode(contents)
		print("Successfully loaded!")
	else
		print("No save file found. Starting a new database.")
		EmployeeManager.database = {}
	end
end

return EmployeeManager