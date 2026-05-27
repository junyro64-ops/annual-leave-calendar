local popup = require("popup")
local Button = require("button")

local PopupCell = setmetatable({}, {__index = popup})
PopupCell.__index = PopupCell

function PopupCell:new(width, height, year, month, day)
    local instance = popup:new(width, height)
    setmetatable(instance, PopupCell)

    instance.date = string.format("%02d/%02d/%02d", year, month, day)
    instance.employeesOnLeave = {}

    local addButton = Button:new(20, height - 50, 120, 40, "연차신청")
    addButton:setOnClick(
        function()
            
        end
    )
    addButton:setDrawLine()
    table.insert(instance.children, addButton)

    local setDate = Button:new(0, 0, 200, 50, instance.date)
    table.insert(instance.children, setDate)

    return instance
end

return PopupCell