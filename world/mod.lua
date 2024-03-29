local inspect = require("inspect").inspect
local utils = require("utils")
local Entity = require("entity")
---@class Systems
---@field startup Query[]
---@field update Query[]
---@field draw Query[]
---@class WorldMatadata
---@field last_id number
---@class World
---@field entities Entity[]
---@field systems Systems
---@field metadata WorldMatadata
---@field spawn function(entity)
---@field add_system function
---@field remove_system function
local World = {
	entities = {},
	systems = {
		startup = {},
		update = {},
		draw = {},
	},
	metadata = {
		last_id = 0,
	},
}
World.mt = {
	__tostring = function(self)
		return inspect(self)
	end,
}

function World:new()
	local t = {
		entities = {},
		systems = {
			startup = {},
			update = {},
			draw = {},
		},
		metadata = {
			last_id = 0,
		},
	}

	for key, value in pairs(self) do
		if type(value) == "function" then
			t[key] = value
		end
	end
	setmetatable(t, self.mt)
	return t
end

--- takes entity and ands it to world returnig its id
---@param entity Entity
---@return string
function World:spawn(entity)
	local new_id = self.metadata.last_id + 1
	local formated_id = "Entity" .. tostring(new_id)
	self.entities[formated_id] = Entity:new(entity)
	self.metadata.last_id = new_id
	return formated_id
end

---@param id number
---@return Entity?
function World:get_by_id(id)
	return self.entities[id]
end

function World:remove_entity(id)
	local ret = self.entities[id]
	self.entities[id] = nil
	return ret
end

---@param system Query
---@return Entity[]
function World:query(system)
	local found = {}
	for key, entity in pairs(self.entities) do
		local has = utils:has_all(entity.components, system.with)
		local has_any = utils:has_any(entity.components, system.without)
		if has and not has_any then
			found[key] = entity
		end
	end
	return found
end

require("world.systems").init_system_funcitons(World)

return World
