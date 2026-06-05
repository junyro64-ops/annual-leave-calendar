local Constants = {}

Constants.ERROR_CHECK = {
    SUCCESS = "SUCCESS",
    FAILED = "FAILED",
    MAX_REACHED = "MAX_REACHED",
    NOT_FOUND = "NOT_FOUND",
    DATA_EXIST = "DATA_EXIST",
    CRASHED = "SYSTEM_CRASHED",
    INVALID_DATA = "INVALID_DATA"
}

Constants.CELL_TYPE = {
    YEAR = "YEAR",
    MONTH = "MONTH",
    DAY = "DAY",
    WEEKDAY = "WEEKDAY",
    PREVIOUS_MONTH_CELL = "PREVIOUS_MONTH_CELL",
    NEXT_MONTH_CELL = "NEXT_MONTH_CELL",
    LEAVE_SELECTION = "LEAVE_SELECTION"
}

Constants.SCREEN_SIZE = {
    width = 1320,
    height = 950
}

Constants.POP_UP = {
    width = 400,
    height = 200
}

Constants.MARGIN = {
    x = 65,
    y = 20,
    indent = 5
}

Constants.CELL_SIZE = {
    YEAR = { width = 170, height = 90 },
    MONTH = { width = 1020, height = 90 },
    DAY = { width = 170, height = 120 },
    WEEKDAY = { width = 170, height = 40 }
}

Constants.CELL_COUNT = 42

Constants.FONTS = {
	large = love.graphics.newFont("font/NanumGothic.ttf", 45),
	medium = love.graphics.newFont("font/NanumGothic.ttf", 26),
	small = love.graphics.newFont("font/NanumGothic.ttf", 16),
    extra_small = love.graphics.newFont("font/NanumGothic.ttf", 12)
}

Constants.FONT_SIZE = {
    large = "LARGE",
    medium = "MEDIUM",
    small = "SMALL",
    extra_small = "EXTRA_SMALL"
}

Constants.FONT_COLOR = {
    RED = "RED",
    BLUE = "BLUE",
    WHITE = "WHITE",
    BLACK = "BLACK"
}

Constants.LEAVE_AMOUNT = {
    LEAVE_AM_QUARTER = 0.25,
    LEAVE_PM_QUARTER = 0.25,
    LEAVE_AM_HALF = 0.5,
    LEAVE_PM_HALF = 0.5,
    LEAVE_ONE_DAY = 1
}

Constants.LEAVE_NAME = {
    LEAVE_AM_QUARTER = "오전반반차",
    LEAVE_PM_QUARTER = "오후반반차",
    LEAVE_AM_HALF = "오전반차",
    LEAVE_PM_HALF = "오후반차",
    LEAVE_ONE_DAY = "연차"
}

Constants.ButtonGraphics = {
    idle = love.graphics.newImage("ui/button_idle.png"),
    hover = love.graphics.newImage("ui/button_hover.png"),
    click = love.graphics.newImage("ui/button_click.png")
}

return Constants