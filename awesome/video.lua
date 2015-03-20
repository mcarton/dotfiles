----------------------------------------------------
-- Licensed under the GNU General Public License v3
--  * (c) 2015, Martin Carton <martin@carton.im>
----------------------------------------------------

-- {{{ Grab environment
-- }}}

-- vicious.widget.video
local video = {}

-- {{{ video widget type
local function worker(format, warg)
    video["{video}"] = ''

    if os.execute("ls /dev/video*") then
        video["{video}"] = 'V'
    end

    return video
end
--- }}}

return setmetatable(video, { __call = function(_, ...) return worker(...) end })
