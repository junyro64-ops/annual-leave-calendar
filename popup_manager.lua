local PopupManager = {}

PopupManager.activePopup = {}

local popup = require("popup")
local Cell = require("cell")
local Button = require("button")
local TextInput = require("text_input")
local GraphicsButton = require("graphics_button")
local ERROR_CHECK = require("constants").ERROR_CHECK

local CELL_TYPE = require("constants").CELL_TYPE
local Fonts = require("constants").FONTS
local FONT_SIZE = require("constants").FONT_SIZE

local LEAVE_NAME = require("constants").LEAVE_NAME
local LEAVE_ORDER = require("constants").LEAVE_ORDER

local POSITION = require("constants").POSITION

function PopupManager.registerPopup(popup)
    table.insert(PopupManager.activePopup, popup)
end

local function closePopup(value)
    if #PopupManager.activePopup > 0 then
        table.remove(PopupManager.activePopup)
        if value then
            for i = 1, value, 1 do
                table.remove(PopupManager.activePopup, #PopupManager.activePopup)
            end
        end
    end
end

local function setInputTitles(popup, x, y, text)
    local width = 300
    local height = 70
    local inputTitle = Button:new(x, y, width, height, text)
    inputTitle:setTextToLeft()
    popup:addChild(inputTitle)
end

local function editEmployeePopup(name, EmployeeManager, func)
    local newPopup = popup:new(800, 600, closePopup)
    local x = 50
    local y = 70
    setInputTitles(newPopup, x, y,     "총 연차 횟수")
    setInputTitles(newPopup, x, y * 2, "연차 시작 월")
    setInputTitles(newPopup, x, y * 3, "직책")
    local maxLeaveInput = TextInput:new(x + 300, y, 300, y)
    newPopup:addChild(maxLeaveInput)
    local startMonthInput = TextInput:new(x + 300, y * 2, 300, y)
    newPopup:addChild(startMonthInput)
    local positionInput = TextInput:new(x + 300, y * 3, 300, y)
    newPopup:addChild(positionInput)

    local confirm = GraphicsButton.createButton(x + 100, y * 6 + 40, "확인")
    newPopup:addChild(confirm)
    confirm:setOnClick(
        function()
            local data = EmployeeManager.database[name]
            local employmentYear = data.employmentYear
            local _maxLeave = tonumber(maxLeaveInput:returnText())
            local startYear = data.leaveStartYear
            local _startMonth = tonumber(startMonthInput:returnText())
            local position_text = positionInput:returnText()
            
            local maxLeave = _maxLeave ~= nil and _maxLeave or data.maxLeave
            local startMonth = _startMonth ~= nil and _startMonth or data.leaveStartMonth

            local position = data.position
            if position_text and position_text:match("%S") then
                position = position_text
            end

            local error_check, validity = 
                EmployeeManager.editEmployee(name, employmentYear, maxLeave, startYear, startMonth, position)

            if error_check == ERROR_CHECK.SUCCESS then closePopup() func() end

            PopupManager.message_popup(validity)

        end
    )

    table.insert(PopupManager.activePopup, newPopup)
end

local function rightClickPopup(edit_func, delete_func)
    local newPopup = popup:new(100, 100)
    local x, y = love.mouse.getPosition()
    newPopup:setPositionToClick(x, y)

    x = 0
    y = 10
    local width = 100
    local height = 40

    local editButton = Button:new(x, y, width, height, "수정")
    editButton:setOnClick(function () edit_func() end)
    local deleteButton = Button:new(x, y + height, width, height, "삭제")
    deleteButton:setOnClick(function () delete_func() end)
    newPopup:addChild(editButton)
    newPopup:addChild(deleteButton)

    table.insert(PopupManager.activePopup, newPopup)
end

local function smallSelectionPopup(start, selections, type, onSelect)
    local newPopup = popup:new(200, 300)
    local x, y = love.mouse.getPosition()
    newPopup:setPositionToClick(x, y)
    newPopup.is_scrollable = true
    newPopup:setScrollWindow(200, 250)

    x = 50
    y = 20
    local width = 100
    local height = 40

    newPopup.itemStride = height

    local concat = ""
    if type == CELL_TYPE.MONTH then
        concat = "월"
    end

    if type == CELL_TYPE.YEAR or type == CELL_TYPE.MONTH then
        for i = 1, selections do
            local number = start + i - 1
            local button = Button:new(x, y + (height * (i - 1)), width, height, tostring(number) .. concat)
            button.isStatic = false
            button.textToLeft = true

            button:setOnClick(
                function ()
                    if onSelect then
                        onSelect(number)
                    end
                    closePopup()
                end
            )

            newPopup:addChild(button)
        end
    end

    if type == CELL_TYPE.LEAVE_SELECTION then
        for i = 1, #LEAVE_ORDER, 1 do
            local leaveName = LEAVE_NAME[LEAVE_ORDER[i]]
            local button = Button:new(x, y + (height * (i - 1)), width, height, leaveName)
            button.isStatic = false
            button.textToLeft = true

            button:setOnClick(
                function ()
                    if onSelect then
                        onSelect(LEAVE_ORDER[i])
                    end
                end
            )

            newPopup:addChild(button)
            i = i + 1
        end
    end

    table.insert(PopupManager.activePopup, newPopup)
end

local function openApplyLeavePopup(year, month, day, EmployeeManager, func, checkAdmin)
    local applyLeavePopup = popup:new(600, 400)

    -- NEED TO IMPLEMENT POPUP FOR EMPLOYEE'S APPLYING LEAVE
    applyLeavePopup.is_scrollable = true
    applyLeavePopup:setScrollWindow(600, 400)

    local x = 50
    local y = 0
    local width = 300
    local height = 50

    applyLeavePopup.itemStride = height

    local sortedNames = {}
    for name, data in pairs(EmployeeManager.database) do
        table.insert(sortedNames, name)
    end

    table.sort(sortedNames)

    for i, name in ipairs(sortedNames) do
        local employee = Button:new(x, y + (height * (i - 1)), width, height, name)
        employee.isStatic = false
        employee:setOnClick(
            function ()
                smallSelectionPopup(1, 1, CELL_TYPE.LEAVE_SELECTION, function (amount)
                    local error, message = EmployeeManager.useLeave(name, year, month, day, amount, checkAdmin)
                    if error == ERROR_CHECK.SUCCESS then closePopup(2) func() end
                    PopupManager.message_popup(message)
                end)
            end
        )
        applyLeavePopup:addChild(employee)
    end

    table.insert(PopupManager.activePopup, applyLeavePopup)
end

local function editCancelLeave(name, year, month, day, amount_key, EmployeeManager, func, checkAdmin)
    rightClickPopup(
        function ()
            -- edit leave function
            smallSelectionPopup(1, 1, CELL_TYPE.LEAVE_SELECTION,
                function (amountEdit)
                    local error, message = 
                        EmployeeManager.editLeave(name, year, month, day, amount_key, amountEdit, checkAdmin)
                    if error == ERROR_CHECK.SUCCESS then closePopup(2) func() end
                    PopupManager.message_popup(message)
                end
            )
        end,
        function ()
            -- delete leave function
            local error, message = 
                EmployeeManager.cancelLeave(name, year, month, day, amount_key, checkAdmin)
            if error == ERROR_CHECK.SUCCESS then closePopup(1) func() end
            PopupManager.message_popup(message)
        end
    )
end

function PopupManager.setCellPopup(cell, width, height, year, month, day, isHoliday, employeeList, 
    EmployeeManager, func, checkAdmin, calculateUpToDateLeaves)
    cell:setOnClick(
        function()
            if cell.type == CELL_TYPE.YEAR or cell.type == CELL_TYPE.MONTH then return end
            if isHoliday then return end

            local popupCell = popup:new(width, height, closePopup)
            
            local date = string.format("%02d/%02d/%02d", year, month, day)
            local setDate = Button:new(0, 0, 200, 50, date)

            popupCell:addChild(setDate)

            if employeeList then
                local x = 20
                local y = 50
                local width = 200
                local height = 30

                for i = #employeeList, 1, -1 do
                    local listItem = employeeList[i]
                    local employeeName = listItem.name
                    local leaveType = listItem.key

                    local index = 1
                    local leaveLimit = EmployeeManager.database[employeeName].leaveDates[year][month][day]
                    if leaveLimit then
                        for j, key in ipairs(leaveLimit) do
                            if key == leaveType then
                                index = j
                                break
                            end
                        end
                    end

                    local leaveName = LEAVE_NAME[leaveType]
                    local usedLeave = calculateUpToDateLeaves(employeeName, year, month, day, index)
                    local concat = employeeName .. " (" .. leaveName .. ") " .. usedLeave
                    local employee = Button:new(x, y + ((i - 1) * height), width, height, concat)
                    employee:setTextToLeft()
                    employee.font_size = FONT_SIZE.small_medium
                    employee:setOnRightClick(
                        function ()
                            editCancelLeave(employeeName, year, month, day, leaveType, EmployeeManager, func, checkAdmin)
                        end
                    )
                    popupCell:addChild(employee)
                end
            end
            
            local applyLeaveButton = Button:new(20, height - 50, 120, 40, "연차신청")
            applyLeaveButton:setOnClick(
                function()
                    openApplyLeavePopup(year, month, day, EmployeeManager, func, checkAdmin)
                end
            )
            applyLeaveButton:setDrawLine()
            popupCell:addChild(applyLeaveButton)

            PopupManager.registerPopup(popupCell)
        end
    )
end

function PopupManager.setYearPopup(cell, year, onSelect)
    cell:setOnClick(
        function ()
            smallSelectionPopup(2018, year - 2018, cell.type, onSelect)
        end
    )
end

function PopupManager.setMonthPopup(cell, onSelect)
    cell:setOnClick(
        function ()
            smallSelectionPopup(1, 12, cell.type, onSelect)
        end
    )
end

function PopupManager.addEmployee(EmployeeManager, func)
    local newPopup = popup:new(800, 600, closePopup)
    local x = 50
    local y = 70
    setInputTitles(newPopup, x, y,     "이름")
    setInputTitles(newPopup, x, y * 2, "입사 연도")
    setInputTitles(newPopup, x, y * 3, "총 연차 횟수")
    setInputTitles(newPopup, x, y * 4, "연차 시작 연도")
    setInputTitles(newPopup, x, y * 5, "연차 시작 월")
    setInputTitles(newPopup, x, y * 6, "직책")
    local nameInput = TextInput:new(x + 300, y, 300, y)
    newPopup:addChild(nameInput)
    local employmentYearInput = TextInput:new(x + 300, y * 2, 300, y)
    newPopup:addChild(employmentYearInput)
    local maxLeaveInput = TextInput:new(x + 300, y * 3, 300, y)
    newPopup:addChild(maxLeaveInput)
    local startYearInput = TextInput:new(x + 300, y * 4, 300, y)
    newPopup:addChild(startYearInput)
    local startMonthInput = TextInput:new(x + 300, y * 5, 300, y)
    newPopup:addChild(startMonthInput)
    local positionInput = TextInput:new(x + 300, y *6, 300, y)
    newPopup:addChild(positionInput)

    local confirm = GraphicsButton.createButton(x + 100, y * 7 + 30, "확인")
    newPopup:addChild(confirm)
    confirm:setOnClick(
        function()
            local name = nameInput:returnText()
            local employmentYear = tonumber(employmentYearInput:returnText())
            local maxLeave = tonumber(maxLeaveInput:returnText())
            local startYear = tonumber(startYearInput:returnText())
            local startMonth = tonumber(startMonthInput:returnText())

            local position = "사원"

            local position_text = positionInput:returnText()
            if position_text and position_text:match("%S") then
                position = position_text
            end

            local error_check, validity = 
                EmployeeManager.addEmployee(name, employmentYear, maxLeave, startYear, startMonth, position)

            if error_check == ERROR_CHECK.SUCCESS then closePopup() func() end
            PopupManager.message_popup(validity)
        end
    )

    table.insert(PopupManager.activePopup, newPopup)
end

local function employeeLeaveData(EmployeeManager, name_pos, calculateUpToDateLeaves)
    local name = EmployeeManager.database[name_pos].name
    local employmentYear = EmployeeManager.database[name_pos].employmentYear
    local maxLeave = EmployeeManager.database[name_pos].maxLeave
    local leaveStartYear = EmployeeManager.database[name_pos].leaveStartYear
    local leaveStartMonth = EmployeeManager.database[name_pos].leaveStartMonth
    local position = EmployeeManager.database[name_pos].position

    local screen_x, screen_y = love.graphics.getDimensions()
    local popupWidth = screen_x
    local popupHeight = 300
    local newPopup = popup:new(popupWidth, popupHeight, closePopup)
    
    local boundaryWidth = popupWidth - 100
    local boundaryHeight = popupHeight - 100

    local boundary_x = (popupWidth - boundaryWidth) / 2
    local boundary_y = (popupHeight - boundaryHeight) / 2

    local boundary_cell = Cell:new(boundary_x, boundary_y, boundaryWidth, boundaryHeight)
    boundary_cell:disableLine()

    newPopup:addChild(boundary_cell)

    local cellWidth = boundaryWidth / 18
    local cellHeight = boundaryHeight / 2
    local labelHeight = Fonts.small:getHeight()
    local labelY = (cellHeight - labelHeight) / 2
    local labelY2 = (cellHeight - (labelHeight * 2)) / 2

    local top_boundary = Cell:new(0, 0, boundaryWidth, cellHeight)
    local name_label = Cell:new(0, 0, cellWidth, cellHeight)
    local name_button = Button:new(0, labelY, cellWidth, labelHeight, "이름")
    name_button:setFontSize(FONT_SIZE.small)
    name_label:addChild(name_button)
    local position_label = Cell:new(cellWidth, 0, cellWidth, cellHeight)
    local position_button = Button:new(0, labelY, cellWidth, labelHeight, "직책")
    position_button:setFontSize(FONT_SIZE.small)
    position_label:addChild(position_button)
    local max_leave_label = Cell:new(cellWidth * 2, 0, cellWidth, cellHeight)
    local max_leave_button = Button:new(0, labelY2, cellWidth, labelHeight, "연차")
    local max_leave_button2 = Button:new(0, labelY2 + labelHeight, cellWidth, labelHeight, "일수")
    max_leave_button:setFontSize(FONT_SIZE.small)
    max_leave_button2:setFontSize(FONT_SIZE.small)
    max_leave_label:addChild(max_leave_button)
    max_leave_label:addChild(max_leave_button2)
    local carried_label = Cell:new(cellWidth * 3, 0, cellWidth, cellHeight)
    local carried_button = Button:new(0, labelY, cellWidth, labelHeight, "이월")
    carried_button:setFontSize(FONT_SIZE.small)
    carried_label:addChild(carried_button)
    local top_label = Cell:new(cellWidth * 4, 0, cellWidth * 12, cellHeight / 2)
    local top_button = Button:new(0, labelY / 4, top_label.width, labelHeight,
                        "사 용 계 획   " .. leaveStartYear .. " ~ " .. (leaveStartYear + 1))
    top_button:setFontSize(FONT_SIZE.small)
    top_label:addChild(top_button)
    for i = 1, 12, 1 do
        local month = ((leaveStartMonth + (i - 1) - 1) % 12) + 1
        local month_button = Button:new(cellWidth * (i - 1), cellHeight / 2, cellWidth, cellHeight / 2, month .. " 월")
        month_button:setFontSize(FONT_SIZE.small)
        month_button:setDrawLine()
        top_label:addChild(month_button)
    end
    local used_leave_label = Cell:new(cellWidth * 16, 0, cellWidth, cellHeight)
    local used_leave_button = Button:new(0, labelY, cellWidth, labelHeight, "합계")
    used_leave_button:setFontSize(FONT_SIZE.small)
    used_leave_label:addChild(used_leave_button)
    local left_leave_label = Cell:new(cellWidth * 17, 0, cellWidth, cellHeight)
    local left_leave_button = Button:new(0, labelY, cellWidth, labelHeight, "잔여")
    left_leave_button:setFontSize(FONT_SIZE.small)
    left_leave_label:addChild(left_leave_button)
    top_boundary:addChild(name_label)
    top_boundary:addChild(position_label)
    top_boundary:addChild(max_leave_label)
    top_boundary:addChild(carried_label)
    top_boundary:addChild(top_label)
    top_boundary:addChild(used_leave_label)
    top_boundary:addChild(left_leave_label)
    boundary_cell:addChild(top_boundary)

    local bottom_boundary = Cell:new(0, cellHeight, boundaryWidth, cellHeight)
    local bottom_cell = {}
    for i = 1, 18, 1 do
        bottom_cell[i] = Cell:new(cellWidth * (i - 1), 0, cellWidth, cellHeight)
        bottom_boundary:addChild(bottom_cell[i])
    end
    local employeeName = Button:new(0, labelY2, cellWidth, labelHeight, name)
    employeeName:setFontSize(FONT_SIZE.small)
    local employed_year = Button:new(0, labelY2 + labelHeight, cellWidth, labelHeight, employmentYear)
    employed_year:setFontSize(FONT_SIZE.small)
    bottom_cell[1]:addChild(employeeName)
    bottom_cell[1]:addChild(employed_year)
    local employee_position = Button:new(0, labelY, cellWidth, labelHeight, position)
    employee_position:setFontSize(FONT_SIZE.small)
    bottom_cell[2]:addChild(employee_position)
    local employee_maxleave = Button:new(0, labelY, cellWidth, labelHeight, maxLeave)
    employee_maxleave:setFontSize(FONT_SIZE.small)
    bottom_cell[3]:addChild(employee_maxleave)
    local carry_button = Button:new(0, labelY, cellWidth, labelHeight)
    carry_button:setOnDoubleClick(
        function ()
            local carryPopup = popup:new(cellWidth, cellHeight)
            local x, y = love.mouse.getPosition()
            carryPopup:setPositionToClick(x, y)
            -- local carryInput = TextInput:new(0, labelY, cellWidth, cellHeight)
            -- local carry = tonumber(carryInput:returnText())
            -- if type(carry) == "number" then
            -- else
            -- end

            table.insert(PopupManager.activePopup, carryPopup)
        end
    )
    bottom_cell[4]:addChild(carry_button)

    
    boundary_cell:addChild(bottom_boundary)


    table.insert(PopupManager.activePopup, newPopup)
end

local function loopThroughPosition(EmployeeManager, value)
    local arr = {}
    for k, v in pairs(EmployeeManager.database) do
        if v.position == value then
            table.insert(arr, k)
        end
    end
    return arr
end

local function flattenArray(arr)
    local flat = {}
    for _, list in ipairs(arr) do
        for _, value in ipairs(list) do
            flat[#flat + 1] = value
        end
    end
    return flat
end

local function orderEmployeeByPosition(EmployeeManager)
    local arr = {}

    for i = 1, #POSITION, 1 do
        local key = loopThroughPosition(EmployeeManager, POSITION[i])
        if #key > 0 then
            table.sort(key, function (a, b)
                local dataA = EmployeeManager.database[a]
                local dataB = EmployeeManager.database[b]

                if dataA.employmentYear ~= dataB.employmentYear then
                    return dataA.employmentYear < dataB.employmentYear
                end
                
                return a < b
            end)
            table.insert(arr, key) 
        end
    end

    return flattenArray(arr)
end

function PopupManager.showEmployee(EmployeeManager, calendarChanged, calculateUpToDateLeaves)
    local newPopup = popup:new(230, 500)
    newPopup.is_scrollable = true
    local x, y = love.mouse.getPosition()
    local reverse = true
    newPopup:setPositionToClick(x, y, reverse)
    newPopup:setScrollWindow(220, 450)

    x = 50
    y = 25
    local width = 230
    local height = 50

    newPopup.itemStride = height

    local sortedNames = orderEmployeeByPosition(EmployeeManager)

    for i, name in ipairs(sortedNames) do
        local employee = Button:new(x, y + (height * (i - 1)), width, height, name)
        employee:setTextToLeft()
        employee.isStatic = false
        employee:setOnRightClick(
            function ()
                rightClickPopup( 
                    function ()
                        closePopup(1)
                        editEmployeePopup(name, EmployeeManager, calendarChanged)
                    end,
                    function ()
                        PopupManager.message_popup("삭제하시겠습니까?",
                            function ()
                                closePopup(1)
                                local error, message = EmployeeManager.deleteEmployee(name)
                                PopupManager.message_popup(message)
                                calendarChanged()
                            end
                        )
                    end
                )
            end
        )
        employee:setOnDoubleClick(
            function ()
                closePopup()
                employeeLeaveData(EmployeeManager, name, calculateUpToDateLeaves)
            end
        )
        newPopup:addChild(employee)
    end

    table.insert(PopupManager.activePopup, newPopup)
end

function PopupManager.message_popup(text, func)
    local width = Fonts.medium:getWidth(text)
    local height = Fonts.medium:getHeight()
    local popupWidth = width < 400 and 500 or width * 1.25
    local newPopup = popup:new(popupWidth, 200, closePopup)
    local x = (popupWidth - width) / 2
    local y = (200 - height) / 2

    if func then
        y = y - 20
    end

    local textMessage = Button:new(x, y, width, height, text)
    newPopup:addChild(textMessage)

    if func then
        local buttonWidth = 100
        local buttonHeight = 40
        local y = newPopup.height - buttonHeight - 10
        
        local confirm = Button:new(10, y, buttonWidth, buttonHeight, "예")
        confirm:setOnClick(
            function ()
                closePopup()
                if func then func() end
            end
        )
        local cancel = Button:new(newPopup.width - buttonWidth - 10, y, buttonWidth, buttonHeight, "아니요")
        cancel:setOnClick(
            function ()
                closePopup()
            end
        )
        newPopup:addChild(confirm)
        newPopup:addChild(cancel)
    end

    PopupManager.registerPopup(newPopup)
    return newPopup
end

return PopupManager