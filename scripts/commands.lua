local commons = require("scripts.commons")

--local newpole_name = "constant-combinator"
local connector_name = commons.circuit_connector_name
local consumption_checked = true

local pole_names = {

    "small-electric-pole",
    "medium-electric-pole",
    "big-electric-pole",
    "substation"
}

local added

---@param surface LuaSurface
---@param force LuaForce
---@return integer
---@return integer
---@return integer
local function replace_poles(surface, force)
    local total = 0
    local removed = 0
    local changed = 0

    if not added and game.active_mods["space-exploration"] then
        table.insert(pole_names, "se-pylon-substation")
        table.insert(pole_names, "se-pylon")
        added = true
    end

    local poles = surface.find_entities_filtered { name = pole_names, force = force }
    if poles and #poles > 0 then
        for _, pole in pairs(poles) do
            local neighbours = pole.neighbours
            local no_energy = not neighbours["copper"] or #neighbours["copper"] == 0
            if not no_energy and consumption_checked then
                local statistics = pole.electric_network_statistics
                no_energy = not next(statistics.output_counts) and not next(statistics.input_counts)
            end

            if no_energy then
                local connections = pole.circuit_connection_definitions

                if not connections or #connections == 0 then
                    pole.destroy { raise_destroy = true }
                    removed = removed + 1
                else
                    local position = pole.position
                    pole.destroy { raise_destroy = true }
                    local x = math.floor(position.x) + 0.5
                    local y = math.floor(position.y) + 0.5
                    local newpole = surface.create_entity { name = connector_name, position = { x = x, y = y }, force = force }
                    if newpole then
                        for _, connection in pairs(connections) do
                            newpole.connect_neighbour({
                                wire = connection.wire,
                                target_entity = connection.target_entity,
                                target_circuit_id = connection.target_circuit_id
                            })
                        end
                    end
                    changed = changed + 1
                end
            end
            total = total + 1
        end
    end
    return total, removed, changed
end

---@param p CustomCommandData
local function eups_saver_replace(p)
    local player = game.players[p.player_index]
    local all = p.parameter == "all"

    local surface = player.surface
    local force = player.force
    ---@cast force LuaForce
    local total, removed, changed = 0, 0, 0

    if not all then
        total, removed, changed = replace_poles(surface, force)
    else
        for _, surface in pairs(game.surfaces) do
            local etotal, eremoved, echanged = replace_poles(surface, force)
            total = total + etotal
            removed = removed + eremoved
            changed = changed + echanged
        end
    end
    player.print("Energy ups")
    player.print("total=" .. tostring(total))
    player.print("removed=" .. tostring(removed))
    player.print("changed=" .. tostring(changed))
end

commands.add_command("eups_saver_replace", { "eups_saver_replace" }, eups_saver_replace)

-----------------------

local entity_filter = {
    { filter = 'name', name = commons.energy_connector_name }
}

local surface_name = "___energy_sharing___"

local entity_destroyed_filter = entity_filter
local max_x = 200

---@param e EventData.on_built_entity | EventData.on_robot_built_entity | EventData.script_raised_built
local function on_built(e)
    ---@type LuaEntity?
    local entity = e.created_entity or e.entity
    if not entity then return end

    local sname = surface_name .. "_" .. tostring(entity.force.index)
    local surface = game.surfaces[sname]
    if not surface then
        surface = game.create_surface(sname, {
            width = 2 * max_x,
            height = 6,
            default_enable_all_autoplace_controls = false,
            peaceful_mode=true
        })
        surface.always_day = true
        surface.show_clouds = false
        surface.request_to_generate_chunks({0, 0}, max_x)
        surface.force_generate_chunk_requests()
        surface.destroy_decoratives({})
        
        for _, entity in ipairs(surface.find_entities()) do
            if entity.valid and entity.type ~= "character" then
                entity.destroy()
            end
        end
    end

    local x = -max_x
    local connectors = surface.find_entities_filtered { name = commons.energy_connector_name }
    local found
    for _, connector in pairs(connectors) do

        local wires = connector.neighbours["copper"]
        if not wires or table_size(wires) < 4 then
            connector.connect_neighbour(entity)
            return    
        end
        if connector.position.x > x then
            x = connector.position.x
        end
    end

    x = x + 2
    local connector = surface.create_entity { name = commons.energy_connector_name, force = entity.force, position = { x, 0 } }
    if connector then
        connector.connect_neighbour(entity)
    end
end

script.on_event(defines.events.on_built_entity, on_built, entity_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, entity_filter)
script.on_event(defines.events.script_raised_built, on_built, entity_filter)
script.on_event(defines.events.script_raised_revive, on_built, entity_filter)
