local CalendarManager = {}

CalendarManager.calendarDataTree = {}
CalendarManager.startingWeekDayTable = {}
CalendarManager.daysInMonthTable = {}

local function calculateDays(year, month)
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

-- loops through a 1 month calendar and does "func" operation
function CalendarManager.loopThroughCalendar(year, month, func)
    local days = CalendarManager.daysInMonthTable[year][month]

    for d=1, days do
        func(d)
    end
end

-- used for creating calendar for 1 year
function CalendarManager.createYearTree(year)
    
    CalendarManager.calendarDataTree[year] = {}
    CalendarManager.startingWeekDayTable[year] = {}
    CalendarManager.daysInMonthTable[year] = {}

    for month=1, 12 do
        local startingWeekDay, daysInMonth = calculateDays(year, month)
        
        CalendarManager.calendarDataTree[year][month] = {}
        CalendarManager.startingWeekDayTable[year][month] = startingWeekDay
        CalendarManager.daysInMonthTable[year][month] = daysInMonth
        
        CalendarManager.loopThroughCalendar(year, month, 
            function(day)
                CalendarManager.calendarDataTree[year][month][day] = { 
                        isHoliday = false, 
                        employees = {} 
                    }
            end
        )
    end
end

function CalendarManager.destroyYearTree(year)
    CalendarManager.calendarDataTree[year] = nil
    CalendarManager.startingWeekDayTable[year] = nil
    CalendarManager.daysInMonthTable[year] = nil
end

return CalendarManager
