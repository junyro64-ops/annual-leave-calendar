-- employee_manager.lua

local ERROR_CHECK = require("constants").ERROR_CHECK

local EmployeeManager = {}
EmployeeManager.database = {}

function EmployeeManager.addEmployee(name, maxLeave, year, month)
	EmployeeManager.database[name] = {
		name = name,
		maxLeave = maxLeave,
		leaveStartYear = year,
		leaveStartMonth = month,
		usedLeave = 0,
		leaveDates = {}
	}
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

function EmployeeManager.cancelLeave(data, year, month, date)
end

-- this function should be called only in case when
--   the manager changes employee's annual leave start month
function EmployeeManager.changeStartMonth(name, month)
	EmployeeManager.database[name].leaveStartMonth = month
end

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

	data.usedLeave = data.usedLeave + amount

	data.leaveDates[year] = data.leaveDates[year] or {}
	data.leaveDates[year][month] = data.leaveDates[year][month] or {}
	data.leaveDates[year][month][day] = amount

	return ERROR_CHECK.SUCCESS
end

return EmployeeManager