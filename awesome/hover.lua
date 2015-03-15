local capi = {
    mouse = mouse,
    screen = screen
}
local pairs = pairs
local require = require
local setmetatable = setmetatable
local string = string

local awful = require("awful")
local naughty = require("naughty")
local vicious = require("vicious")

module("hover")

local hover = {}

local function notify(fn)
    return naughty.notify{
        text = string.format('<span font_desc="monospace">%s</span>', fn()),
        timeout = 0,
        hover_timeout = 0,
        screen = capi.mouse.screen
    }
end

function hover.install(arg)
    local widget = arg.widget
    local buttons = arg.buttons

    widget:connect_signal(
        'mouse::enter',
        function ()
            arg.box = notify(arg.enter)
            vicious.force({ widget })
        end
    )

    widget:connect_signal(
        'mouse::leave',
        function ()
            naughty.destroy(arg.box)
            vicious.force({ widget })
        end
    )

    if buttons then
        local handlers
        for _, rule in pairs(buttons) do
            handlers = awful.util.table.join(
                handlers,
                awful.button(
                    rule.modifier, rule.button,
                    function ()
                        naughty.destroy(arg.box)
                        arg.box = notify(rule.fn)
                    end
                )
            )
        end

        widget:buttons(handlers)
    end
end

return hover
