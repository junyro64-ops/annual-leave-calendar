local EmployeeLeaveDataPopup = {}

local Cell = require("cell")
local popup = require("popup")
local Button = require("button")
local TextInput = require("text_input")

local Fonts = require("constants").FONTS
local FONT_SIZE = require("constants").FONT_SIZE

local LEAVE_AMOUNT = require("constants").LEAVE_AMOUNT

local popupWidth = 1320
local popupHeight = 300
local popupHeightAll = 900
    
local boundaryWidth = 1200
local boundaryHeight = 200
local boundaryHeightAll = 800

local cellWidth = boundaryWidth / 18
local cellHeight = boundaryHeight / 2
local labelHeight = Fonts.small:getHeight()
local labelY = (cellHeight - labelHeight) / 2
local labelY2 = (cellHeight - (labelHeight * 2)) / 2

local function setMonthLabels(container, leaveStartMonth)
    for i = 1, 12, 1 do
        local month = ((leaveStartMonth + (i - 1) - 1) % 12) + 1
        local label = Button:new(cellWidth * (i - 1), cellHeight / 2, cellWidth, cellHeight / 2, month .. " 월")
        label:setFontSize(FONT_SIZE.small)
        label:setDrawLine()
        container:addChild(label)
    end
end

local function topYearMonthCell(x, y, leaveStartYear, leaveStartMonth)
    local top = Cell:new(x, y, cellWidth * 12, cellHeight / 2)
    local top_label = Button:new(0, labelY / 4, top.width, labelHeight,
                        "사 용 계 획   " .. leaveStartYear .. " ~ " .. (leaveStartYear + 1))
    top_label:setFontSize(FONT_SIZE.small)
    top:addChild(top_label)
    setMonthLabels(top, leaveStartMonth)
    return top
end

local function createCellWithLabel(x, y, text, text2)
    local label_y = text2 and labelY2 or labelY
    local container = Cell:new(x, y, cellWidth, cellHeight)
    local label = Button:new(0, label_y, cellWidth, labelHeight, text)
    label:setFontSize(FONT_SIZE.small)
    container:addChild(label)

    if text2 then
        local label2 = Button:new(0, label_y + labelHeight, cellWidth, labelHeight, text2)
        label2:setFontSize(FONT_SIZE.small)
        container:addChild(label2)
    end

    return container
end

local function topBoundary(x, y, leaveStartYear, leaveStartMonth)
    local boundary = Cell:new(x, y, boundaryWidth, cellHeight)

    local top_boundary = {
        name = createCellWithLabel(0, 0, "이름"),
        position = createCellWithLabel(cellWidth, 0, "직책"),
        max_leave = createCellWithLabel(cellWidth * 2, 0, "연차", "일수"),
        carry = createCellWithLabel(cellWidth * 3, 0, "이월"),
        top = topYearMonthCell(cellWidth * 4, 0, leaveStartYear, leaveStartMonth),
        total = createCellWithLabel(cellWidth * 16, 0, "합계"),
        left_leave = createCellWithLabel(cellWidth * 17, 0, "잔여")
    }
    
    for _,v in pairs(top_boundary) do
        boundary:addChild(v)
    end

    return boundary
end

local function setCarryInput(PopupManager, employee, carryText, leavesLeft, totalUsedLeave)
    local carry_button = Button:new(0, 0, cellWidth, cellHeight, carryText)
    carry_button:setFontSize(FONT_SIZE.small)
    carry_button:setFontColor("RED")
    carry_button:setOnDoubleClick(
        function ()
            local carryPopup = popup:new(cellHeight, cellWidth)
            local x, y = love.mouse.getPosition()
            carryPopup:setPositionToClick(x, y)
            local carryInput = TextInput:new(0, 0, cellHeight, cellWidth)
            carryInput:activate()
            carryInput:setOnEnter(
                function ()
                    local carry = tonumber(carryInput:returnText())
                    if carry ~= nil and carry % 0.25 == 0 then
                        carry_button:setText(carry)
                        employee.carriedLeave = carry

                        leavesLeft:setText(employee.maxLeave + carry - totalUsedLeave)

                        table.remove(PopupManager.activePopup)
                    else
                        PopupManager.message_popup("잘못된 입력입니다.")
                    end
                end
            )
            carryPopup:addChild(carryInput)

            table.insert(PopupManager.activePopup, carryPopup)
        end
    )
    return carry_button
end

local function createLabelWithSmallFont(text, color, func)
    local label = Button:new(0, labelY, cellWidth, labelHeight, text)
    label:setFontSize(FONT_SIZE.small)
    if color then label:setFontColor(color) end
    if func then
        label:setOnDoubleClick(
            function ()
                func()
            end
        )
    end
    return label
end


    
local function calculateMonthUsedLeave(data, year, month)
    local usedLeave = 0
    if data.leaveDates then
        if data.leaveDates[year] then
            if data.leaveDates[year][month] then
                for day, dayLeaves in pairs(data.leaveDates[year][month]) do
                    for _, v in pairs(dayLeaves) do
                        usedLeave = usedLeave + LEAVE_AMOUNT[v]
                    end
                end
            end
        end
    end
    return usedLeave
end

local function bottomBoundary(x, y, PopupManager, employee, setYearMonth, closePopup)
    local boundary = Cell:new(x, y, boundaryWidth, cellHeight)

    local carryText = employee.carriedLeave and employee.carriedLeave or ""
    local totalUsedLeave = 0
    local monthlyData = {}
    for i = 1, 12, 1 do
        local month = ((employee.leaveStartMonth + (i - 1) - 1) % 12) + 1
        local year = ((12 - employee.leaveStartMonth) < (i - 1)) and employee.leaveStartYear + 1 or employee.leaveStartYear
        local usedLeave = calculateMonthUsedLeave(employee, year, month)
        totalUsedLeave = totalUsedLeave + usedLeave
        local monthlyLeaves = createLabelWithSmallFont(usedLeave, "BLACK",
            function ()
                closePopup()
                setYearMonth(year, month)
            end
        )
        table.insert(monthlyData, monthlyLeaves)
    end
    local leavesLeft = createLabelWithSmallFont(employee.maxLeave + employee.carriedLeave - totalUsedLeave, "RED")

    local label_list = {}
    local bottom_boundary_left = {
        createCellWithLabel(0, 0, employee.name, employee.employmentYear),
        createLabelWithSmallFont(employee.position),
        createLabelWithSmallFont(employee.maxLeave),
        setCarryInput(PopupManager, employee, carryText, leavesLeft, totalUsedLeave)
    }
    for _, v in ipairs(bottom_boundary_left) do
        table.insert(label_list, v)
    end
    for _, v in ipairs(monthlyData) do
        table.insert(label_list, v)
    end
    local totalUsed = createLabelWithSmallFont(totalUsedLeave, "RED")
    leavesLeft:setText(employee.maxLeave + employee.carriedLeave - totalUsedLeave)
    table.insert(label_list, totalUsed)
    table.insert(label_list, leavesLeft)

    local bottom_cell = {}
    for i = 1, 18, 1 do
        bottom_cell[i] = Cell:new(cellWidth * (i - 1), 0, cellWidth, cellHeight)
        bottom_cell[i]:addChild(label_list[i])
        boundary:addChild(bottom_cell[i])
    end

    return boundary
end

local function setContainers(x, y, width, height)
    local boundary = Cell:new(x, y, width, height)
    boundary:disableLine()

    return boundary
end

function EmployeeLeaveDataPopup.employee(EmployeeManager, PopupManager, name_pos, setYearMonth, closePopup)
    local employee = EmployeeManager.database[name_pos]
    employee.carriedLeave = employee.carriedLeave or 0

    local newPopup = popup:new(popupWidth, popupHeight, closePopup)

    local x = (popupWidth - boundaryWidth) / 2
    local y = (popupHeight - boundaryHeight) / 2

    local boundary = setContainers(x, y, boundaryWidth, boundaryHeight)

    local top_boundary = topBoundary(0, 0, employee.leaveStartYear, employee.leaveStartMonth)
    local bottom_boundary = bottomBoundary(0, cellHeight, PopupManager, employee, setYearMonth, closePopup)
    
    newPopup:addChild(boundary)
    boundary:addChild(top_boundary)
    boundary:addChild(bottom_boundary)

    table.insert(PopupManager.activePopup, newPopup)
end

function EmployeeLeaveDataPopup.allEmployees(
        EmployeeManager, PopupManager, setYearMonth, closePopup, orderEmployeeByPosition
    )
    
    for _, employee in pairs(EmployeeManager.database) do
        employee.carriedLeave = employee.carriedLeave or 0
    end

    local newPopup = popup:new(popupWidth, popupHeightAll, closePopup)

    local x = (popupWidth - boundaryWidth) / 2
    local y = (popupHeightAll - boundaryHeightAll) / 2

    local sortedNames = orderEmployeeByPosition(EmployeeManager)
    local leaveTable = {}
    local yearMonthKey = {}

    for _, name in ipairs(sortedNames) do
        local employee = EmployeeManager.database[name]

        local year = employee.leaveStartYear
        local month = employee.leaveStartMonth

        if year and month then
            local key = string.format("%04d-%02d", year, month)
            if not leaveTable[key] then
                leaveTable[key] = {
                    year = year,
                    month = month,
                    employees = {}
                }
                table.insert(yearMonthKey, key)
            end
            table.insert(leaveTable[key].employees, employee)
        end
    end

    local index = 0
    for _, key in ipairs(yearMonthKey) do
        local group = leaveTable[key]
        local top_boundary = topBoundary(x, y + (index * cellHeight), group.year, group.month)
        top_boundary.isStatic = false
        newPopup:addChild(top_boundary)
        index = index + 1
        for _, employee in ipairs(group.employees) do
            local bottom_boundary = bottomBoundary(x, y + (index * cellHeight), PopupManager, employee, setYearMonth, closePopup)
            bottom_boundary.isStatic = false
            newPopup:addChild(bottom_boundary)
            index = index + 1
        end
        index = index + 1
    end

    newPopup:setScrollWindow(boundaryWidth, boundaryHeightAll)
    newPopup.itemStride = cellHeight
    newPopup.is_scrollable = true

    table.insert(PopupManager.activePopup, newPopup)
end

return EmployeeLeaveDataPopup