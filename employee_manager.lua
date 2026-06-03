local EmployeeManager = {}
EmployeeManager.database = {}

local deletedData = {}

local ERROR_CHECK = require("constants").ERROR_CHECK

-- Checks if the inputs are valid in addEmployee popup
-- The order of inputs are name, maxLeave, startYear, startMonth
local validationRules = {
	function(value) return value ~= nil and string.len(value) > 0 end;
	function(value) return value ~= nil and (value > 0) and (value < 50) end;
	function(value) 
		local year = os.date("*t").year
		return value ~= nil and ((value >= year - 1) and (value <= year))
	end;
	function(value) return value ~= nil and (0 < value) and (value < 13) end
}

local validationCheck = {
	"이름이 입력되지 않았습니다.",
	"유효하지 않은 여차 횟수입니다.",
	"시작연도는 작년부터 가능합니다.",
	"유요하지 않은 월 입니다."
}

function EmployeeManager.addEmployee(name, maxLeave, year, month, position)
	if EmployeeManager.database[name] then return ERROR_CHECK.DATA_EXIST, "등록된 이름입니다" end
	local inputData = {name, maxLeave, year, month}

	for i, validation in ipairs(validationRules)do
		local value = inputData[i]
		if validation and not validation(value) then 
			return ERROR_CHECK.INVALID_DATA, validationCheck[i]
		end
	end
	
	EmployeeManager.database[name] = {
		name = name,
		maxLeave = maxLeave,
		leaveStartYear = year,
		leaveStartMonth = month,
		postion = position,
		usedLeave = 0,
		leaveDates = {}
	}

	return ERROR_CHECK.SUCCESS, 0
end

function EmployeeManager.deleteEmployee(name)
	if not EmployeeManager.database[name] then return ERROR_CHECK.NOT_FOUND end

	deletedData[name] = EmployeeManager.database[name]
	EmployeeManager.database[name] = nil
end

function EmployeeManager.getEmployeeData(name)
	local data = EmployeeManager.database[name]

	if not data then
		return nil
	else
		return data
	end
end

function EmployeeManager.getDeletedData()
	return deletedData
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
	local time = os.date("*t")
	if year ~= time.year or month ~= time.month or day <= time.day then
		return ERROR_CHECK.INVALID_DATA
	end
	local data = EmployeeManager.database[name]
	data.usedLeave = data.usedLeave - amount
	data.leaveDates[year][month][day] = nil

	return ERROR_CHECK.SUCCESS
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

return EmployeeManager