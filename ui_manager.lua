local UIManager = {
    elements = {}
}

local Button = require("button")

local function register(element)
    table.insert(UIManager.elements, element)
end

function UIManager.createButton(x, y, width, height)
    local button = Button:new(x, y, width, height)
    register(button)
    return button
end

function UIManager.mousePressed(x, y, mouseButton)
    if mouseButton == 1 then
        for i = #UIManager.elements, 1, -1 do
            local element = UIManager.elements[i]
            if x >= element.x and x <= (element.x + element.width) and
                y >= element.y and y <= (element.y + element.height) then
                if element.onclick then
                    element:onclick()
                end

                return true
            end
        end
    end
    return false
end

function UIManager.draw()
    for _, element in ipairs(UIManager.elements) do
        if element.draw then
            element:draw()
        end
    end
end

return UIManager