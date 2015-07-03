-- Standard awesome library
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local vicious = require("vicious")
local hover = require('hover')
local helpers = require("vicious.helpers")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminator"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  names = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b" },
  layout = { layouts[8], layouts[8], layouts[2],
             layouts[2], layouts[2], layouts[2],
             layouts[2], layouts[2], layouts[2],
             layouts[2], layouts[2]
           }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
mymainmenu = awful.menu(
  { items = {
    { "restart awesome", awesome.restart },
    { "close session", {{ "I mean it", awesome.quit }} },
    { "suspend",   {
        { "but don't lock", function() awful.util.spawn("sudo pm-suspend") end },
        { "and lock", function() awful.util.spawn_with_shell("i3lock && sudo pm-suspend") end }
    } },
    { "hibernate", {{ "I mean it", function() awful.util.spawn("sudo pm-hibernate") end }} },
    { "shutdown",  {{ "I mean it", function() awful.util.spawn("systemctl poweroff") end }} },
    { "restart",   {{ "I mean it", function() awful.util.spawn("systemctl reboot") end }} }
  }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Volume Widget
myvolwidget = wibox.widget.textbox()
local stereo = require('stereo')
vicious.register(myvolwidget, stereo, "♫${mute}${volume}%", 11, 'Master')
local cmus = require('cmus')
hover.install{
    widget=myvolwidget, box={},
    enter=function()
        result = '<b>Global:</b>\n'
              .. 'Left:  ${left} <b>${lmute}</b>\n'
              .. 'Right: ${right} <b>${rmute}</b>\n\n'
              .. '<b>cmus:</b> ${status}\n'
              .. 'Artist: ${artist}\n'
              .. 'Title:  ${title}\n'
              .. 'Album:  ${album}\n'
              .. 'Date:   ${date}\n'
              .. 'Genre:  ${genre}\n'
              .. 'Volume: ${vol_left} — ${vol_right}\n'
              .. 'File:   ${file}'

        result = helpers.format(result, stereo('', 'Master'))
        result = helpers.format(result, cmus())
        return result
    end,
    buttons = {
        { modifier={}, button=1, fn=cmus.next   },
        { modifier={}, button=2, fn=cmus.pause  },
        { modifier={}, button=3, fn=cmus.prev   },
        { modifier={}, button=4, fn=stereo.up   },
        { modifier={}, button=5, fn=stereo.down },
    }
}

-- Battery widget
mybatwidget = wibox.widget.textbox()
vicious.register(
    mybatwidget, vicious.widgets.bat,
    function (widget, args)
        -- args = {state, percent, time, wear}
        local state, percent, time, wear = unpack(args)
        r = '↯'

        if time ~= 'N/A' and state ~= '+' then
            r = r .. '<span color="red">-</span>'
        end

        if percent < 15 then
                r = r .. '<span color="red">' .. percent .. '</span>'
        elseif	percent < 25 then
                r = r .. '<span color="orange">' .. percent .. '</span>'
        elseif  percent < 35 then
                r = r .. '<span color="yellow">' .. percent .. '</span>'
        else
                r = r .. percent
        end

        r = r .. '%'

        -- notification if need to load
        if state == '−' and percent < 15 then
            naughty.notify{
                preset = naughty.config.presets.critical,
                title = "Low battery!",
                text = "Battery is very low!",
                timeout = 15
            }
        end

        return r
    end,
    97, 'BAT0'
)
hover.install{
    widget=mybatwidget, box={},
    enter=function ()
        local state, percent, time, wear = unpack(vicious.widgets.bat(nil, 'BAT0'))
        return string.format(
            'State    : %5s\nPercent  : %5s\nTime     : %5s\nWear     : %5s',
            state, percent .. '%', time, wear .. '%'
        )
    end
}

-- Network Widget
mynetwidget = wibox.widget.textbox()
mynetwidget:set_font('fontawesome-webfont ' .. tostring(theme.fontsize))
vicious.register(mynetwidget, vicious.widgets.net,
    function (widget, args)
        r = ''
        if args['{enp3s0f1 carrier}'] == 1 then
            r = r .. '\239\135\166' -- fa-plug
        end
        if args['{wlp2s0 carrier}'] == 1 then
            r = r .. '\239\135\171' -- fa-wifi
        end
        if r == ''  then
            r = ' '
        end
        return r
    end, 17
)
hover.install{widget=mynetwidget, box={}}

-- CPU Temperature Widget
local function color_temp(temp)
    temp = math.floor(temp)
    if temp < 61 then
        return temp
    elseif  temp < 76 then
        return '<span color="orange">' .. temp .. '</span>'
    else
        return '<span color="red">'    .. temp .. '</span>'
    end
end

local temp = require('temp')
mytempwidget = wibox.widget.textbox()
vicious.register(mytempwidget, temp,
    function (widget, args)
        return color_temp(args.physical.current) .. '°C'
    end, 61
)
hover.install{
    widget=mytempwidget, box={},
    enter=function ()
        temps = temp()
        return string.format(
            "%-15s: %s°C\n%-15s: %s°C\n%-15s: %s°C",
            temps.physical.name, color_temp(temps.physical.current),
            temps.core0.name, color_temp(temps.core0.current),
            temps.core1.name, color_temp(temps.core1.current)
        )
    end
}

-- Video Widget
myvideowidget = wibox.widget.textbox()
myvideowidget:set_font('fontawesome-webfont ' .. tostring(theme.fontsize))
local video = require('video')
vicious.register(myvideowidget, video,
    function (widget, args)
        if args["{video}"] == 'V' then
            return "<span color='red'>\239\128\176</span>" -- fa-camera
        else
            return ' '
        end
    end,
    7, ''
)
hover.install{widget=myvideowidget, box={}}

-- Create a textclock widget
mytextclock = awful.widget.textclock("%a %b %d, %H:%M")
calendar = require('calendar')
hover.install{
    widget=mytextclock, box={},
    enter=calendar.timezones({
        {"Japan     ", "Asia/Tokyo"},
        {"Singapore ", "Asia/Singapore"},
        {"UTC       ", "UTC"},
        {"Martinique", "America/Martinique"},
        {"LA        ", "America/Los_Angeles"},
    })
}
hover.install{
    widget=mytextclock, box={},
    enter=calendar.displayer(calendar),
    buttons = {
        { modifier={         }, button=3, fn=calendar.displayer(calendar, - 1) },
        { modifier={         }, button=1, fn=calendar.displayer(calendar,   1) },
        { modifier={ 'Shift' }, button=3, fn=calendar.displayer(calendar, -12) },
        { modifier={ 'Shift' }, button=1, fn=calendar.displayer(calendar,  12) },
    }
}

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end

    mywidgets = {
        mytempwidget,
        myvolwidget,
        mynetwidget,
        mybatwidget,
        myvideowidget,
    }

    separator = wibox.widget.textbox()
    separator:set_text('|')

    for i = 1, #mywidgets do
        right_layout:add(mywidgets[i])
        right_layout:add(separator)
    end

    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Shift"   }, ",", awful.client.restore),

    -- Screen
    awful.key({ modkey,           }, "F1",    function () awful.screen.focus(1) end        ),
    awful.key({ modkey,           }, "F2",    function () awful.screen.focus(2) end        ),
    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    awful.key({ modkey }, "f", function () awful.util.spawn_with_shell("firefox") end),
    awful.key({ modkey }, "n", function () awful.util.spawn_with_shell("nautilus --no-desktop") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, ",",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, #tags.names do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     size_hints_honor = false,
                     buttons = clientbuttons } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
