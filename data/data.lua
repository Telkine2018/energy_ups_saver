local commons = require("scripts.commons")

local prefix = commons.prefix
local png = commons.png

local function np(name)
    return prefix .. "-" .. name
end

---@generic K
---@generic V
---@param table_list table<K,V>[]
---@return table<K,V>
local function table_merge(table_list)
    local result = {}
    for _, t in ipairs(table_list) do
        if t then for name, value in pairs(t) do result[name] = value end end
    end
    return result
end

---@param table table
---@param map table<string, string>
local function replace(table, map)
    local filename = table.filename
    if filename then
        table.filename = map[filename] or filename
    end

    for k, v in pairs(table) do
        if type(v) == "table" then
            replace(v, map)
        end
    end
end

local circuit_connector_item = {

    -- Item
    {
        type = 'item',
        name = commons.circuit_connector_name,
        icon_size = 64,
        icon = png("icons/connector"),
        group = "logistics",
        subgroup = 'circuit-network',
        order = 'zzz',
        place_result = commons.circuit_connector_name,
        stack_size = 50
    },

    -- Recipe
    {
        type = 'recipe',
        name = commons.circuit_connector_name,
        enabled = true,
        ingredients = {
            { 'electronic-circuit', 10 },
            { 'iron-plate',         20 },
            { 'copper-plate',       20 },
            { 'steel-plate',        4 }
        },
        result = commons.circuit_connector_name
    },

}

data:extend(circuit_connector_item)


local circuit_connector = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
circuit_connector = table_merge {
    circuit_connector,
    {
        name                      = commons.circuit_connector_name,
        item_slot_count           = 1,
        circuit_wire_max_distance = 64,
        fast_replaceable_group    = nil,
        placeable_by              = nil,
        minable                   = { mining_time = 1, result = commons.circuit_connector_name }
    }
}
local circuit_connector_map = {

    ["__base__/graphics/entity/combinator/constant-combinator.png"] = "__energy_ups_saver__/graphics/entity/connector/connector.png"
    ,
    ["__base__/graphics/entity/combinator/hr-constant-combinator.png"] = "__energy_ups_saver__/graphics/entity/connector/hr-connector.png"
    ,
    ["__base__/graphics/entity/combinator/constant-combinator-shadow.png"] = "__energy_ups_saver__/graphics/entity/connector/connector-shadow.png"
    ,
    ["__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png"] = "__energy_ups_saver__/graphics/entity/connector/hr-connector-shadow.png"
}
replace(circuit_connector, circuit_connector_map)

data:extend { circuit_connector }

-------------------------------------------------------

local energy_connector_item = {

    -- Item
    {
        type = 'item',
        name = commons.energy_connector_name,
        icon_size = 64,
        icon = png("icons/energy-connector"),
        subgroup = "energy-pipe-distribution",
        order = "a[energy]-e[substation]",
        place_result = commons.energy_connector_name,
        stack_size = 10
    },

    -- Recipe
    {
        type = 'recipe',
        name = commons.energy_connector_name,
        enabled = true,
        ingredients = {
            { "steel-plate",      40 },
            { "advanced-circuit", 10 },
            { "copper-plate",     10 }
        },
        result = commons.energy_connector_name
    },

}

data:extend(energy_connector_item)

local energy_connector = table.deepcopy(data.raw["electric-pole"]["substation"])
energy_connector = table_merge {
    energy_connector,
    {
        name = commons.energy_connector_name,
        minable = { mining_time = 1, result = commons.energy_connector_name }
    }
}
local energy_connector_map = {

    ["__base__/graphics/entity/substation/substation.png"] = "__energy_ups_saver__/graphics/entity/energy-connector/energy-connector.png"
    ,
    ["__base__/graphics/entity/substation/hr-substation.png"] = "__energy_ups_saver__/graphics/entity/energy-connector/hr-energy-connector.png"
    ,
    ["__base__/graphics/entity/substation/substation-shadow.png"] = "__energy_ups_saver__/graphics/entity/energy-connector/energy-connector-shadow.png"
    ,
    ["__base__/graphics/entity/substation/hr-substation-shadow.png"] = "__energy_ups_saver__/graphics/entity/energy-connector/hr-energy-connector-shadow.png"
}
replace(energy_connector, energy_connector_map)

data:extend { energy_connector }

