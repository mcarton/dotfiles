local io = io
local string = string

module("volume")

local volume = {}

local function format(s)
    return string.gsub(s, ".*%[(.*)%%%].*%[(.*)%%%]", "%1, %2")
end

function volume:info()
    local f = io.popen("amixer get Master")

    f:read()
    f:read()
    f:read()
    f:read()
    f:read()

    local left  = f:read()
    local right = f:read()

    f:close()

    return {["{left}"] = format(left), ["{right}"] = format(right)}
end

return volume
