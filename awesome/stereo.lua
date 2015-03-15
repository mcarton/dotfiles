----------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2015, Martin Carton <martin@carton.im>
----------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
local math = { max = math.max }
-- }}}


-- Volume: provides volume levels and state of requested ALSA mixers
-- vicious.widgets.volume
local volume = {}


-- {{{ Volume widget type
local function worker(format, warg)
    if not warg then return end

    local mixer_state = {
        ["{lmute}"] = "",
        ["{rmute}"] = "",
        ["{left}"]  = 0,
        ["{right}"] = 0,
        ["{mute}"] = "",
        ["{volume}"] = 0,
    }

    -- Get mixer control contents
    -- local f = io.popen("amixer -M get " .. helpers.shellquote(warg))
    local f = io.popen("amixer -M get " .. warg)
    local mixer = f:read("*all")
    f:close()

    -- Capture mixer control state:                       [  5    %  ] . [  on]
    local left,  lmute = string.match(mixer,  "Left:[^[]*%[([%d]+)%%%].*%[([%l]*)")
    local right, rmute = string.match(mixer, "Right:[^[]*%[([%d]+)%%%].*%[([%l]*)")

    mixer_state["{left}"]  = left
    mixer_state["{right}"] = right

    -- Handle mixers without mute
    lmute = lmute == "" and left  == "0" or lmute == "off"
    rmute = rmute == "" and right == "0" or rmute == "off"

    if lmute then
       mixer_state["{lmute}"] = "M"
    end
    if rmute then
       mixer_state["{rmute}"] = "M"
    end
    if lmute and rmute then
        mixer_state["{mute}"] = "M"
    end

    if left and right then
        mixer_state["{volume}"] = math.max(left, right)
    end

    return mixer_state
end
-- }}}

return setmetatable(volume, { __call = function(_, ...) return worker(...) end })
