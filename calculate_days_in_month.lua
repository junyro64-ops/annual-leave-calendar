local Days = {}

function Days.calculateDays(year, month)
    local startingWeekday = os.date(
        "*t", 
        os.time({year = year, month = month, day = 1})
    ).wday
    local daysInMonth = os.date(
        "*t", 
        os.time({year = year, month = month + 1, day = 0})
    ).day

    return startingWeekday, daysInMonth
end

return Days