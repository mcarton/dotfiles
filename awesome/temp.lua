-- This does not use acpi as it does not work on my laptop.

local setmetatable = setmetatable
local string = { match = string.match }
local tonumber = tonumber
local io = require("io")

module("temp")

local temp = {}

local function infos(line)
    local name, current, high, crit
        = string.match(line, "(.+): +%+(.+)°C.*= (.+)°C.*= (.+)°C")
    return {
        name = name;
        current = tonumber(current);
        high = tonumber(high);
        crit = tonumber(crit);
    }
end

local function worker(format)
    local f = io.popen('sensors')

    f:read()
    f:read()

    local args = {}

    args.physical = infos(f:read())
    args.core0    = infos(f:read())
    args.core1    = infos(f:read())

    f:close()

    return args
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
