-- original code made by Bzed and published on http://awesome.naquadah.org/wiki/Calendar_widget
-- modified by Marc Dequènes (Duck) <Duck@DuckCorp.org> (2009-12-29), under the same licence,
-- and with the following changes:
--   + transformed to module
--   + the current day formating is customizable

local string = string
local tostring = tostring
local os = os
local capi = {
    mouse = mouse,
    screen = screen
}
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
module("calendar2")

local calendar = {}
local current_day_format = string.format('<span foreground="%s" background="%s">%s</span>', beautiful.fg_focus, beautiful.bg_focus, "%s")

function displayMonth(month,year,weekStart)
    local t,wkSt=os.time{year=year, month=month+1, day=0},weekStart or 1
    local d=os.date("*t",t)
    local mthDays,stDay=d.day,(d.wday-d.day-wkSt+1)%7

    local lines = "    "

    for x=0,6 do
        lines = lines .. os.date("%a ",os.time{year=2006,month=1,day=x+wkSt})
    end

    lines = lines .. os.date("\n %V",os.time{year=year,month=month,day=1})

    local writeLine = 1
    while writeLine < (stDay + 1) do
        lines = lines .. "    "
        writeLine = writeLine + 1
    end

    today = os.date("%Y-%m-%d")

    for d=1,mthDays do
        local x = d
        local t = os.time{year=year,month=month,day=d}
        if writeLine == 8 then
            writeLine = 1
            lines = lines .. os.date("\n %V",t)
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
    local header = os.date("%B %Y\n",os.time{year=year,month=month,day=1})

    return header .. "\n" .. lines
end

function switchNaughtyMonth(switchMonths)
    if (#calendar < 3) then return end
    local swMonths = switchMonths or 1
    calendar[1] = calendar[1] + swMonths

    naughty.destroy(calendar[3])
    calendar[3] = naughty.notify({
        text = string.format('<span font_desc="monospace">%s</span>', displayMonth(calendar[1], calendar[2], 2)),
        timeout = 0,
        hover_timeout = 0.5,
        screen = capi.mouse.screen
    })
end

function addCalendarToWidget(mywidget, custom_current_day_format)
  if custom_current_day_format then current_day_format = custom_current_day_format end

  mywidget:connect_signal('mouse::enter', function ()
    local month, year = os.date('%m'), os.date('%Y')
        calendar = { month, year,
            naughty.notify({
                    text = string.format('<span font_desc="monospace">%s</span>', displayMonth(month, year, 2)),
                    timeout = 0,
                    hover_timeout = 0.5,
                    screen = capi.mouse.screen
            })
        }
  end)
  mywidget:connect_signal('mouse::leave', function () naughty.destroy(calendar[3]) end)

  mywidget:buttons(awful.util.table.join(
    awful.button({ },         3, function() switchNaughtyMonth(-1)  end),
    awful.button({ },         1, function() switchNaughtyMonth(1)   end),
    awful.button({ 'Shift' }, 3, function() switchNaughtyMonth(-12) end),
    awful.button({ 'Shift' }, 1, function() switchNaughtyMonth(12)  end)
  ))
end

