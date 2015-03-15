-- original code made by Bzed and published on
--      http://awesome.naquadah.org/wiki/Calendar_widget
-- modified by Marc Dequènes (Duck) <Duck@DuckCorp.org> (2009-12-29), under the same licence,
-- and with the following changes:
--   + transformed to module
--   + the current day formating is customizable

local os = os
local string = string
local tostring = tostring
local beautiful = require("beautiful")

module("calendar")

local calendar = {}
local current_day_format = string.format(
    '<span foreground="%s" background="%s">%s</span>',
    beautiful.fg_focus, beautiful.bg_focus, "%s"
)

function calendar.displayMonth(month, year, weekStart)
    local weekStart = weekStart or 2
    local d = os.date("*t", os.time{year=year, month=month+1, day=0})
    local mthDays = d.day
    local stDay = (d.wday-d.day-weekStart+1)%7

    local lines

    lines = os.date("%B %Y\n\n    ", os.time{year=year, month=month, day=1})

    for x=0, 6 do
        lines = lines .. os.date("%a ", os.time{year=2006, month=1, day=x+weekStart})
    end

    lines = lines .. os.date("\n %V", os.time{year=year, month=month, day=1})

    local writeLine = 1
    while writeLine < (stDay + 1) do
        lines = lines .. "    "
        writeLine = writeLine + 1
    end

    today = os.date("%Y-%m-%d")

    for d=1, mthDays do
        local x = d
        local t = os.time{year=year, month=month, day=d}

        if writeLine == 8 then
            writeLine = 1
            lines = lines .. os.date("\n %V", t)
        end

        if today == os.date("%Y-%m-%d", t) then
            x = d
            if (#(tostring(d)) == 1) then
                x = " " .. x
            end
            x = string.format(current_day_format, x)
        elseif (#(tostring(d)) == 1) then
            x = " " .. x
        end
        lines = lines .. "  " .. x
        writeLine = writeLine + 1
    end

    return lines
end

function calendar.displayer(c, delta)
    return function ()
        if not c.currentdate or not delta then
            c.currentdate = {
                year=os.date('%Y'),
                month=os.date('%m'),
            }
        end

        if delta then
            c.currentdate.month = c.currentdate.month + delta
        end

        return calendar.displayMonth(c.currentdate.month, c.currentdate.year)
    end
end

return calendar
