local Constants = {}

Constants.ERROR_CHECK = {
    SUCCESS = "SUCCESS",
    FAILED = "FAILED",
    MAX_REACHED = "MAX_REACHED"
}

Constants.CELL_TYPE = {
    YEAR = "YEAR",
    MONTH = "MONTH",
    DAY = "DAY",
    WEEKDAY = "WEEKDAY",
    PREVIOUS_MONTH_CELL = "PREVIOUS_MONTH_CELL",
    NEXT_MONTH_CELL = "NEXT_MONTH_CELL"
}

Constants.SCREEN_SIZE = {
    width = 1320,
    height = 950
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

return Constants