--local inspect   = require("inspect").inspect
local utils = require "utils"
---@class Systems
---@field startup table
---@field update table
---@field draw table
---@class WorldMatadata
---@field last_id number
---@class World
---@field entities Entity[]
---@field systems Systems
---@field metadata WorldMatadata
---@field spawn function(entity)
---@field add_system function
local World = {
    entities = {},
    systems = {
        startup = {},
        update = {},
        draw = {}
    },
    metadata = {
        last_id = 0
    }
}

---@enum QueryType
local query_types = {
    startup = "startup",
    update = "update",
    draw = "draw",
}

--- takes entity and ands it to world returnig its id
---@param entity Entity
---@return string
function World:spawn(entity)
    local new_id = self.metadata.last_id + 1
    local formated_id = "Entity" .. tostring(new_id)
    local e = {
        components = entity,
        metadata = {
            changed = false
        }
    }
    self.entities[formated_id] = e
    self.metadata.last_id = new_id
    return formated_id
end

---@param id number
---@return Entity?
function World:get_by_id(id)
    return World.entities[id]
end

function World:remove_entity(id)
    local ret = self.entities[id]
    self.entities[id] = nil
    return ret
end

---@param with_ any
---@param without_ any
---@return Entity[]|nil
function World:query(with_, without_)
    local with = with_ or {}
    local without = without_ or {}
    local found = {}
    for key, value in pairs(self.entities) do
        if utils:has_all(value, with) and not utils:has_any(value, without) then
            found[key] = value
        end
    end
    return found
end

---@param type QueryType
---@param fn function(e Entitiy[]) Entitiy[]
---@param with string[]
---@param without string[]
function World:add_system(type, fn, with, without)
end

return World
