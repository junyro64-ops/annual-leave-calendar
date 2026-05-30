local PopupManager = {}

local activePopup = {}

local popup = require("popup")
local Button = require("button")
local Fonts = require("constants").FONTS

function PopupManager.registerPopup(popup)
    table.insert(activePopup, popup)
end

local function closePopup()
    if #activePopup > 0 then
        table.remove(activePopup)
    end
end

function PopupManager.message_popup(text)
    local newPopup = popup:new(500, 200, closePopup)
    local width = Fonts.medium:getWidth(text)
    local height = Fonts.medium:getHeight()
    local x = (500 - width) / 2
    local y = (200 - height) / 2
    local textMessage = Button:new(x, y, width, height, text)
    newPopup:addChild(textMessage)
    table.insert(activePopup, newPopup)
    return newPopup
end

return PopupManager