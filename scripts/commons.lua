
local commons = {}

commons.prefix = "eups_saver"

local prefix = commons.prefix

local function png(name) return ('__energy_ups_saver__/graphics/%s.png'):format(name) end

commons.debug_mode = false
commons.png = png

local function np(name)
    return prefix .. "-" .. name
end

commons.circuit_connector_name = np("circuit_connector")
commons.energy_connector_name = np("energy_connector")

return commons

