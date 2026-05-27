local popup = require("popup")
local Button = require("button")

local PopupCell = setmetatable({}, {__index = popup})
PopupCell.__index = PopupCell

function PopupCell:new(width, height, year, month, day)
    local instance = popup:new(width, height)
    setmetatable(instance, PopupCell)

    local obs = os.date("*t", os.time{year = year, month = month, day = day})
    instance.date = os.date("%Y/%m/%d")
    instance.employeesOnLeave = {}

    local addButton = Button:new(20, height - 50, 120, 40, "연차신청")
    addButton:setOnClick(
        function()
            
        end
    )
    addButton:setDrawLine()
    table.insert(instance.children, addButton)

    return instance
end

return PopupCell