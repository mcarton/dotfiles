local wibox = require("wibox")
local naughty = require("naughty")
local io = require("io")

local capi = { timer = timer }
local tonumber = tonumber
local tostring = tostring
local string = string
local os = os
local math = math
local setmetatable = setmetatable

module("fraxbat")

-- Globals used by fraxbat
local fraxbat_st= nil
local fraxbat_ts= nil
local fraxbat_ch= nil
local fraxbat_now = nil
local fraxbat_est= nil

tbw = nil
-- Function for updating fraxbat
function hook_fraxbat (tbw)
   bat = 'BAT1'

   -- Battery Present?
   --[[
    local fh= io.open("/sys/class/power_supply/"..bat.."/present", "r")
    if fh == nil then
      return("No Bat")
    end
    local stat= fh:read()
    fh:close()
    if tonumber(stat) < 1 then
      return("Bat Not Present")
    end
   ]]

   -- Status (Charging, Full or Discharging)
   fh= io.open("/sys/class/power_supply/"..bat.."/status", "r")
   if fh == nil then
      return("N/S")
   end
   stat= fh:read()
   fh:close()
   if stat == 'Full' then
      return("100%")
   end
   stat= string.upper(string.sub(stat, 1, 1))

   begin_tag = ''
   end_tag = ''

   -- Remaining + Estimated (Dis)Charging Time
   local charge
   fh= io.open("/sys/class/power_supply/"..bat.."/charge_full", "r")
   if fh ~= nil then
      local full= fh:read()
      fh:close()
      full= tonumber(full)
      if full ~= nil then
        fh= io.open("/sys/class/power_supply/"..bat.."/charge_now", "r")
        if fh ~= nil then
           local now= fh:read()
           local est=""
           fh:close()
           if fraxbat_st == stat then
              delta= os.difftime(os.time(),fraxbat_ts)
              est= math.abs(fraxbat_ch - now)
              if delta > 30 and est > 0 then
                 est= delta/est
                 if now == fraxbat_now then
                    est= fraxbat_est
                 else
                    fraxbat_est= est
                    fraxbat_now= now
                 end
                 if stat == 'D' then
                    est= now*est

                    if est < 15*60 then -- at minus 15min time is printed red
                        begin_tag = '<span color="red">'
                        end_tag = '</span>'
                    end

                    if est < 5*60 then
                       naughty.notify({ preset = naughty.config.presets.critical,
                                        title = "Low battery!",
                                        text = "Battery is very low!" })
                    end
                 else
                    est= (full-now)*est
                 end

                 local h= math.floor(est/3600)
                 est= est - h*3600
                 est= string.format(', %02d:%02d',h,math.floor(est/60))
              end
           else
              fraxbat_st= stat
              fraxbat_ts= os.time()
              fraxbat_ch= now
              fraxbat_now= nil
              fraxbat_est= nil
           end
           charge=':'..begin_tag..tostring(math.ceil((100*now)/full))..'%'..est..end_tag
        end
      end
   end

   return stat..charge
end

function getFraxbatWidget(timeout)
    local tbw = wibox.widget.textbox("fraxbox")

    local bat_timer = capi.timer({ timeout=timeout })
    bat_timer:connect_signal("timeout", function() tbw:set_markup(hook_fraxbat()) end)
    bat_timer:start()
    bat_timer:emit_signal("timeout")

    return tbw
end
