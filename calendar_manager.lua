local Days = require("calculate_days_in_month")

local CalendarManager = {}
CalendarManager.calendarDataTree = {}
CalendarManager.startingWeekDayTable = {}
CalendarManager.daysInMonthTable = {}

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
        local startingWeekDay, daysInMonth = Days.calculateDays(year, month)
        
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
