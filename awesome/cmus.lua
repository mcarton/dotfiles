----------------------------------------------------
-- Licensed under the GNU General Public License v3
--  * (c) 2015, Martin Carton <martin@carton.im>
----------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch }
local helpers = require("vicious.helpers")
-- }}}


-- cmus: provides C* Music Player information
-- vicious.widgets.cmus
local cmus = {}

-- {{{ cmus widget type
local function worker(format, warg)
    local cmus_state  = {
        ["{album}"]  = "N/A",
        ["{artist}"] = "N/A",
        ["{date}"] = "N/A",
        ["{file}"] = "N/A",
        ["{genre}"]  = "N/A",
        ["{status}"]  = "N/A",
        ["{title}"]  = "N/A",
        ["{vol_left}"]  = "N/A",
        ["{vol_right}"]  = "N/A",
    }

    -- Get data from cmus-remote
    local f = io.popen("cmus-remote -Q")

    for line in f:lines() do
        for k, v in string.gmatch(line, "([%w]+) (.*)$") do
             if     k == "status" then cmus_state["{"..k.."}"] = helpers.capitalize(v)
             elseif k == "file" then cmus_state["{"..k.."}"] = helpers.escape(v)
             end
        end
        for k, v in string.gmatch(line, "... ([%w_]+) (.*)$") do -- tag or set
             cmus_state["{"..k.."}"] = helpers.escape(v)
        end
    end
    f:close()

    return cmus_state
end
-- }}}

return setmetatable(cmus, { __call = function(_, ...) return worker(...) end })
