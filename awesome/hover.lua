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

    arg.box = nil

    widget:connect_signal(
        'mouse::enter',
        function ()
            if arg.enter ~= nil then
                arg.box = notify(arg.enter)
            end
            vicious.force({ widget })
        end
    )

    widget:connect_signal(
        'mouse::leave',
        function ()
            if arg.box ~= nil then
                naughty.destroy(arg.box)
            end
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
                        if arg.box ~= nil then
                            naughty.destroy(arg.box)
                        end
                        arg.box = notify(rule.fn)
                    end
                )
            )
        end

        widget:buttons(handlers)
    end
end

return hover
