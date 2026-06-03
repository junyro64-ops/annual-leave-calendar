local PopupManager = {}

PopupManager.activePopup = {}

local EmployeeManager = require("employee_manager")

local popup = require("popup")
local Button = require("button")
local TextInput = require("text_input")
local GraphicsButton = require("graphics_button")
local ERROR_CHECK = require("constants").ERROR_CHECK

local CELL_TYPE = require("constants").CELL_TYPE
local Fonts = require("constants").FONTS
local FONT_COLOR = require("constants").FONT_COLOR
local ButtonGraphics = require("constants").ButtonGraphics

function PopupManager.registerPopup(popup)
    table.insert(PopupManager.activePopup, popup)
end

local function closePopup()
    if #PopupManager.activePopup > 0 then
        table.remove(PopupManager.activePopup)
    end
end

function PopupManager.confirmCancelPopup(width, height, func)
    local _popup = popup:new(width, height, closePopup)
    return _popup
end

local function openApplyLeavePopup()
    local applyLeavePopup = popup:new(300, 200, closePopup)

    -- NEED TO IMPLEMENT POPUP FOR EMPLOYEE'S APPLYING LEAVE

    table.insert(PopupManager.activePopup, applyLeavePopup)
end

function PopupManager.setCellPopup(cell, width, height, year, month, day, checkHoliday)
    cell:setOnClick(
        function()
            if cell.type == CELL_TYPE.YEAR or cell.type == CELL_TYPE.MONTH then return end

            local popupCell = popup:new(width, height, closePopup)
            
            local date = string.format("%02d/%02d/%02d", year, month, day)
            local setDate = Button:new(0, 0, 200, 50, date)

            local isHoliday = checkHoliday()
            if isHoliday then setDate:setFontColor(FONT_COLOR.RED) end
            popupCell:addChild(setDate)

            popupCell.employeesOnLeave = {}
            
            local applyLeaveButton = Button:new(20, height - 50, 120, 40, "연차신청")
            applyLeaveButton:setOnClick(
                function()
                    openApplyLeavePopup()
                end
            )
            applyLeaveButton:setDrawLine()
            popupCell:addChild(applyLeaveButton)

            PopupManager.registerPopup(popupCell)
        end
    )
end

local function smallSelectionPopup(start, selections, type, onSelect)
    local newPopup = popup:new(200, 300, closePopup)
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

    table.insert(PopupManager.activePopup, newPopup)
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

local function setInputTitles(popup, x, y, text)
    local width = 300
    local height = 100
    local inputTitle = Button:new(x, y, width, height, text)
    inputTitle:setTextToLeft()
    popup:addChild(inputTitle)
end

function PopupManager.addEmployee()
    local newPopup = popup:new(800, 600, closePopup)
    local x = 50
    local y = 90
    setInputTitles(newPopup, x, y,     "이름")
    setInputTitles(newPopup, x, y * 2, "총 연차 횟수")
    setInputTitles(newPopup, x, y * 3, "연차 시작 연도")
    setInputTitles(newPopup, x, y * 4, "연차 시작 월")
    local nameInput = TextInput:new(x + 300, y, 300, 90)
    newPopup:addChild(nameInput)
    local maxLeaveInput = TextInput:new(x + 300, y * 2, 300, 90)
    newPopup:addChild(maxLeaveInput)
    local startYearInput = TextInput:new(x + 300, y * 3, 300, 90)
    newPopup:addChild(startYearInput)
    local startMonthInput = TextInput:new(x + 300, y * 4, 300, 90)
    newPopup:addChild(startMonthInput)

    local confirm = GraphicsButton.createButton(x + 100, y * 5 + 40, "확인")
    newPopup:addChild(confirm)
    confirm:setOnClick(
        function()
            local name = nameInput:returnText()
            local maxLeave = tonumber(maxLeaveInput:returnText())
            local startYear = tonumber(startYearInput:returnText())
            local startMonth = tonumber(startMonthInput:returnText())

            local error_check, validity = EmployeeManager.addEmployee(name, maxLeave, startYear, startMonth)

            local message
            if error_check == ERROR_CHECK.INVALID_DATA or error_check == ERROR_CHECK.DATA_EXIST then
                message = validity
            elseif error_check == ERROR_CHECK.SUCCESS then
                message = "성공"
            else
                message = "문제가 발생했습니다."
            end

            local success_popup = PopupManager.message_popup(message)
        end
    )

    table.insert(PopupManager.activePopup, newPopup)
end

function PopupManager.showEmployee()
    local newPopup = popup:new(800, 600, closePopup)
    newPopup.is_scrollable = true
    newPopup:setScrollWindow(700, 500)

    local x = 50
    local y = 50
    local width = 300
    local height = 100

    newPopup.itemStride = height

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
                
            end
        )
        newPopup:addChild(employee)
    end

    table.insert(PopupManager.activePopup, newPopup)
end

function PopupManager.message_popup(text, func)
    local newPopup = popup:new(500, 200, closePopup)
    local width = Fonts.medium:getWidth(text)
    local height = Fonts.medium:getHeight()
    local x = (500 - width) / 2
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