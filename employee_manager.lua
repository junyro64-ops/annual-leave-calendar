local EmployeeManager = {}
EmployeeManager.database = {}
EmployeeManager.leaveDateList = {}

local deletedData = {}

local ERROR_CHECK = require("constants").ERROR_CHECK
local LEAVE_AMOUNT = require("constants").LEAVE_AMOUNT

-- Checks if the inputs are valid in addEmployee popup
-- The order of inputs are name, maxLeave, startYear, startMonth
local validationRules = {
	function(value) return value ~= nil and string.len(value) > 0 end;
	function(value) return value ~= nil and (value > 1999) and (value <= os.date("*t").year) end;
	function(value) return value ~= nil and (value > 0) and (value < 50) end;
	function(value) 
		local year = os.date("*t").year
		return value ~= nil and ((value >= year - 1) and (value <= year))
	end;
	function(value) return value ~= nil and (0 < value) and (value < 13) end
}

local validationCheck = {
	"이름이 입력되지 않았습니다.",
	"유효하지 않은 입사 연도입니다.",
	"유효하지 않은 연차 횟수입니다.",
	"시작연도는 작년부터 가능합니다.",
	"유요하지 않은 월 입니다."
}

local function validate(name, employmentYear, maxLeave, year, month)
	local inputData = {name, employmentYear, maxLeave, year, month}

	for i, validation in ipairs(validationRules)do
		local value = inputData[i]
		if validation and not validation(value) then 
			return false, validationCheck[i]
		end
	end

	return true, 0
end

function EmployeeManager.addEmployee(name, employmentYear, maxLeave, year, month, position)
	if EmployeeManager.database[name .. " " .. position] then return ERROR_CHECK.DATA_EXIST, "등록된 이름입니다" end
	
	local validation, check = validate(name, employmentYear, maxLeave, year, month)
	if not validation then
		return ERROR_CHECK.INVALID_DATA, check
	end
	
	EmployeeManager.database[name .. " " .. position] = {
		name = name,
		employmentYear = employmentYear,
		maxLeave = maxLeave,
		leaveStartYear = year,
		leaveStartMonth = month,
		position = position,
		usedLeave = 0,
		leaveDates = {}, -- saves leave names in [year][month][day] table
		pastLeaveData = {}
	}

	return ERROR_CHECK.SUCCESS, "등록됐습니다."
end

local function deleteChangeLeaveData(employee, oldName, newName)
	if employee.leaveDates then
		for year, months in pairs(employee.leaveDates) do
			for month, days in pairs(months) do
				for day, _ in pairs(days) do
					if EmployeeManager.leaveDateList[year] and
						EmployeeManager.leaveDateList[year][month] and
						EmployeeManager.leaveDateList[year][month][day] then
							local list = EmployeeManager.leaveDateList[year][month][day]
							for i = #list, 1, -1 do
								local listItem = list[i]
								if listItem.name == oldName then
									local currentKey = listItem.key
									table.remove(list, i)
									if newName then table.insert(list, {name = newName, key = currentKey}) end
								end
							end
					end
				end
			end
		end
	end
end

-- If this function is called, the popup window that called it must be closed.
function EmployeeManager.editEmployee(_name, employmentYear, maxLeave, year, month, position)
	
	local validation, check = validate(_name, employmentYear, maxLeave, year, month)
	if not validation then
		return ERROR_CHECK.INVALID_DATA, check
	end
	
	local data = EmployeeManager.database[_name]
	local name = EmployeeManager.database[_name].name
	local newName = name .. " " .. position

	data.maxLeave = maxLeave
	data.leaveStartMonth = month
	
	if data.position ~= position then
		EmployeeManager.database[newName] = data
		EmployeeManager.database[newName].position = position
		EmployeeManager.database[_name] = nil
		deleteChangeLeaveData(data, _name, newName)
	end
	

	return ERROR_CHECK.SUCCESS, "정보를 수정했습니다."
end

function EmployeeManager.deleteEmployee(name)
	if not EmployeeManager.database[name] then 
		return ERROR_CHECK.NOT_FOUND, "사원이 없습니다."
	end

	deleteChangeLeaveData(EmployeeManager.database[name], name)

	deletedData[name] = EmployeeManager.database[name]
	EmployeeManager.database[name] = nil

	return ERROR_CHECK.SUCCESS, "사원 정보를 삭제했습니다."
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
function EmployeeManager.checkLeaveStart(name, year, month)
	local data = EmployeeManager.database[name]
	local monthsPassed = ((year - data.leaveStartYear) * 12) + (month - data.leaveStartMonth)

	if monthsPassed >= 12 then
		data.pastLeaveData = {
			key = tostring(data.leaveStartYear),
			value = {
				maxLeave = data.maxLeave,
				leaveStartYear = data.leaveStartYear,
				leaveStartMonth = data.leaveStartMonth,
				usedLeave = data.usedLeave,
				leaveDates = data.leaveDates
			}
		}
		data.leaveStartYear = data.leaveStartYear + math.floor(monthsPassed / 12)
		data.usedLeave = 0
		data.leaveDates = {}
	end
end

local function checkDate(year, month, checkAdminFunc)
	local checkAdmin = checkAdminFunc()
	if checkAdmin == true then return true end

	local time = os.date("*t")

	if year < time.year then return false end

	if year == time.year and month < time.month then return false end

	return true
end

local function currentCycle(name, year, month)
	local data = EmployeeManager.database[name]

	if year == data.leaveStartYear and month >= data.leaveStartMonth then
		return true
	elseif year == data.leaveStartYear + 1 and month < data.leaveStartMonth then
		return true
	else 
		return false
	end
end

function EmployeeManager.cancelLeave(name, year, month, day, amount_key, checkAdminFunc)
	local data = EmployeeManager.database[name]

	local check_date = checkDate(year, month, checkAdminFunc)

	if check_date == false then
		return ERROR_CHECK.FAILED, "지난 날짜는 삭제가 불가능합니다. 관리자를 문의해주세요."
	end

	if currentCycle(name, year, month) then
		local amount = LEAVE_AMOUNT[amount_key]
		data.usedLeave = data.usedLeave - amount
	end
	
	local leaveDates = data.leaveDates[year][month][day]
	if leaveDates then
		for i = #leaveDates, 1, -1 do
			if leaveDates[i] == amount_key then
				table.remove(leaveDates, i)
				break
			end
		end
		if #leaveDates == 0 then data.leaveDates[year][month][day] = nil end
	end

	local list = EmployeeManager.leaveDateList[year][month][day]
	for i = #list, 1, -1 do
		local listItem = list[i]
		if listItem.name == name and listItem.key == amount_key then
			table.remove(list, i)
			break
		end
	end

	return ERROR_CHECK.SUCCESS, "취소했습니다."
end

function EmployeeManager.useLeave(name, year, month, day, amount_key, checkAdminFunc) -- amount is LEAVE_NAME constant's key
	-- local data is just a pointer to the employee's database
	-- everything updated on 'data' will actually be set to the employee's database
	local data = EmployeeManager.database[name]

	if not data then
		return ERROR_CHECK.FAILED, "데이터가 없습니다."
	end

	local check_date = checkDate(year, month, checkAdminFunc)

	if check_date == false then
		return ERROR_CHECK.FAILED, "신청이 불가능합니다. 관리자를 문의해주세요."
	end

	data.leaveDates = data.leaveDates or {}	
	data.leaveDates[year] = data.leaveDates[year] or {}
	data.leaveDates[year][month] = data.leaveDates[year][month] or {}
	data.leaveDates[year][month][day] = data.leaveDates[year][month][day] or {}
	
	for _, key in ipairs(data.leaveDates[year][month][day]) do
		if key == amount_key then
			return ERROR_CHECK.DATA_EXIST, "이미 사용한 연차입니다."
		end
	end
	
	if currentCycle(name, year, month) then
		local amount = LEAVE_AMOUNT[amount_key]
		local carry = data.carriedLeave or 0
		
		data.usedLeave = data.usedLeave or 0
		if (data.usedLeave + amount) > (data.maxLeave + carry) then
			return ERROR_CHECK.MAX_REACHED, "연차 횟수를 초과했습니다."
		end
		
		table.insert(data.leaveDates[year][month][day], amount_key)
		
		data.usedLeave = data.usedLeave + amount
	end

	EmployeeManager.leaveDateList = EmployeeManager.leaveDateList or {}
	EmployeeManager.leaveDateList[year] = EmployeeManager.leaveDateList[year] or {}
	EmployeeManager.leaveDateList[year][month] = EmployeeManager.leaveDateList[year][month] or {}
	EmployeeManager.leaveDateList[year][month][day] = EmployeeManager.leaveDateList[year][month][day] or {}

	table.insert(EmployeeManager.leaveDateList[year][month][day], {name = name, key = amount_key})

	return ERROR_CHECK.SUCCESS, "연차 신청이 완료됐습니다."
end

function EmployeeManager.editLeave(name, year, month, day, original_key, edit_key, checkAdminFunc)
	local data = EmployeeManager.database[name]

	if not data then
		return ERROR_CHECK.FAILED, "데이터가 없습니다."
	end

	local check_date = checkDate(year, month, checkAdminFunc)

	if check_date == false then
		return ERROR_CHECK.FAILED, "지난 날짜는 수정이 불가능합니다. 관리자를 문의해주세요."
	end

	if original_key == edit_key then
		return ERROR_CHECK.INVALID_DATA, "똑같은 연차입니다."
	end

	data.leaveDates = data.leaveDates or {}	
	data.leaveDates[year] = data.leaveDates[year] or {}
	data.leaveDates[year][month] = data.leaveDates[year][month] or {}
	data.leaveDates[year][month][day] = data.leaveDates[year][month][day] or {}

	local leaveDates = data.leaveDates[year][month][day]
	if leaveDates then
		for i, key in ipairs(leaveDates) do
			if key == edit_key then
				return ERROR_CHECK.DATA_EXIST, "해당 날짜에 같은 연차가 존재합니다."
			end
		end
		for i, key in ipairs(leaveDates) do
			if key == original_key then
				leaveDates[i] = edit_key
				break
			end
		end
	end

	EmployeeManager.leaveDateList = EmployeeManager.leaveDateList or {}
	EmployeeManager.leaveDateList[year] = EmployeeManager.leaveDateList[year] or {}
	EmployeeManager.leaveDateList[year][month] = EmployeeManager.leaveDateList[year][month] or {}
	EmployeeManager.leaveDateList[year][month][day] = EmployeeManager.leaveDateList[year][month][day] or {}

	local list = EmployeeManager.leaveDateList[year][month][day]
	if list then
		for _, v in ipairs(list) do
			if v.name == name and v.key == original_key then
				v.key = edit_key
				break
			end
		end
	end

	if currentCycle(name, year, month) then
		local amountOriginal = LEAVE_AMOUNT[original_key]
		local amountEdit = LEAVE_AMOUNT[edit_key]

		local carry = data.carriedLeave or 0
		
		data.usedLeave = data.usedLeave or 0
		if (data.usedLeave - amountOriginal + amountEdit) > (data.maxLeave + carry) then
			return ERROR_CHECK.MAX_REACHED, "연차 횟수를 초과했습니다."
		end
		
		data.usedLeave = data.usedLeave - amountOriginal + amountEdit
	end

	return ERROR_CHECK.SUCCESS, "연차 수정이 완료됐습니다."
end

return EmployeeManager