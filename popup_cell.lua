local popup = require("popup")
local Button = require("button")

local PopupCell = setmetatable({}, {__index = popup})
PopupCell.__index = PopupCell

function PopupCell:new(x, y, width, height, year, month, day)
    local instance = popup:new(x, y, width, height)
    setmetatable(instance, PopupCell)

    local obs = os.date("*t", os.time{year = year, month = month, day = day})
    instance.date = os.date("%Y/%m/%d")
    instance.employeesOnLeave = {}

    local addButton = Button:new(width - 40, 5, 30, 30, "X")
    addButton:setOnClick(
        function()
            
        end
    )
    table.insert(instance.children, addButton)

    return instance
end

return PopupCell