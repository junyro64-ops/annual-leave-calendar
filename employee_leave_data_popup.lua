local EmployeeLeaveDataPopup = {}

local Cell = require("cell")
local popup = require("popup")
local Button = require("button")
local TextInput = require("text_input")

local Fonts = require("constants").FONTS
local FONT_SIZE = require("constants").FONT_SIZE

local LEAVE_AMOUNT = require("constants").LEAVE_AMOUNT

local screen_x, screen_y = love.graphics.getDimensions()
local popupWidth = screen_x
local popupHeight = 300
    
local boundaryWidth = popupWidth - 100
local boundaryHeight = popupHeight - 100

local boundary_x = (popupWidth - boundaryWidth) / 2
local boundary_y = (popupHeight - boundaryHeight) / 2

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

local function topBoundary(leaveStartYear, leaveStartMonth)
    local boundary = Cell:new(0, 0, boundaryWidth, cellHeight)

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

                        leavesLeft:setText(employee.maxLeave - carry - totalUsedLeave)

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


    
local calculateMonthUsedLeave = function (data, year, month)
    local usedLeave = 0
    data.leaveDates[year] = data.leaveDates[year] or {}
    data.leaveDates[year][month] = data.leaveDates[year][month] or {}
    if data.leaveDates[year][month] then
        for day, amount in pairs(data.leaveDates[year][month]) do
            for _, v in pairs(data.leaveDates[year][month][day]) do
                usedLeave = usedLeave + LEAVE_AMOUNT[v]
            end
        end
    end
    return usedLeave
end

local function gotoCalendar()
end

local function bottomBoundary(PopupManager, employee, setYearMonth, closePopup)
    local boundary = Cell:new(0, 0, boundaryWidth, cellHeight)

    local carryText = employee.carriedLeave and employee.carriedLeave or ""
    local totalUsedLeave = 0
    local leavesLeft

    local bottom_boundary_left = {
        name = createCellWithLabel(employee.name, employee.employmentYear),
        position = createLabelWithSmallFont(employee.position),
        maxLeave = createLabelWithSmallFont(employee.maxLeave),
        carry = setCarryInput(PopupManager, employee, carryText, leavesLeft, totalUsedLeave)
    }
    local bottom_boundary_middle = {}
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
        table.insert(bottom_boundary_middle, monthlyLeaves)
    end
    local totalUsed = createLabelWithSmallFont(totalUsedLeave, "RED")
    leavesLeft = createLabelWithSmallFont(employee.maxLeave - employee.carriedLeave - totalUsedLeave, "RED")

    local bottom_cell = {}
    for i = 1, 18, 1 do
        bottom_cell[i] = Cell:new(cellWidth * (i - 1), 0, cellWidth, cellHeight)
        boundary:addChild(bottom_cell[i])
    end

    return boundary
end

local function setContainers(closePopup)
    local boundary = Cell:new(boundary_x, boundary_y, boundaryWidth, boundaryHeight)
    boundary:disableLine()

    return boundary
end

function EmployeeLeaveDataPopup.employee(EmployeeManager, PopupManager, name_pos, setYearMonth, closePopup)
    local employee = {
        name = EmployeeManager.database[name_pos].name,
        employmentYear = EmployeeManager.database[name_pos].employmentYear,
        maxLeave = EmployeeManager.database[name_pos].maxLeave,
        leaveStartYear = EmployeeManager.database[name_pos].leaveStartYear,
        leaveStartMonth = EmployeeManager.database[name_pos].leaveStartMonth,
        position = EmployeeManager.database[name_pos].position,
    
        carriedLeave = EmployeeManager.database[name_pos].carriedLeave or 0
    }

    local leavesLeft

    local newPopup = popup:new(popupWidth, popupHeight, closePopup)

    local boundary = setContainers(closePopup)

    newPopup:addChild(boundary)

    local top_boundary = topBoundary(employee.leaveStartYear, employee.leaveStartMonth)

    boundary:addChild(top_boundary)

    local bottom_boundary = bottomBoundary(PopupManager, employee, setYearMonth, closePopup)
    
    local totalButton = Button:new(0, labelY, cellWidth, labelHeight, totalUsedLeave)
    totalButton:setFontSize(FONT_SIZE.small)
    totalButton:setFontColor("RED")
    bottom_cell[17]:addChild(totalButton)
    leavesLeft = Button:new(0, labelY, cellWidth, labelHeight, maxLeave - carriedLeave - totalUsedLeave)
    leavesLeft:setFontSize(FONT_SIZE.small)
    leavesLeft:setFontColor("RED")
    bottom_cell[18]:addChild(leavesLeft)
    
    boundary:addChild(bottom_boundary)


    table.insert(PopupManager.activePopup, newPopup)
end

return EmployeeLeaveDataPopup