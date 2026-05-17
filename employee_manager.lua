-- employee_manager.lua

local ERROR_CHECK = require("constants").ERROR_CHECK

local EmployeeManager = {}
EmployeeManager.database = {}

function EmployeeManager.addEmployee(name, maxLeave, leaveStartMonth)
	EmployeeManager.database[name] = {
		maxLeave = maxLeave,
		leaveStartMonth = leaveStartMonth,
		usedLeave = 0,
		leaveDates = {}
	}
end

function EmployeeManager.getEmployee(name)
	return EmployeeManager.database[name]
end

function EmployeeManager.getLeaveDates(name)
	return EmployeeManager.database[name].leaveDates
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