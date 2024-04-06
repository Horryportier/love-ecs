local generate_registry = require("src.mask").generate_registry
local contains = require("src.mask").contains
local add_functions = require("src.common").add_functions
local new_entity = require("src.entity.entity").new_entity

---@class World
---@field last_id  number
---@field entities Entity[]
---@field components_registry table
---@field systems Systems
---@field query fun(self: World, mask: number)

local worldlib = {}

local world_meta = {
	--- returns pretty formated World with format of: World(e[<number of entities>])
	---@param self World
	---@return string
	__tostring = function(self)
		return string.format("World(E[%d])", #self.entities)
	end,
}

--- Registers types assing them to components_registry
--- max size for now is 64
---@param self World
---@param list string[]
local function register_types(self, list)
	self.components_registry = generate_registry(list)
end

---@param self World
---@param components table
local function spawn(self, components)
	local new_id = self.last_id + 1
	self.entities[new_id] = new_entity(new_id, components, self.components_registry)
	self.last_id = new_id
end
---@param self World
---@param mask number
---@return number[]
local function query(self, mask)
	local ids = {}
	for id, value in pairs(self.entities) do
		if contains(mask, value.mask) then
			table.insert(ids, id)
		end
	end
	return ids
end

local world_functions = {
	register_types = register_types,
	update = function() end,
	---@param self World
	draw = function(self)
		for key, system in pairs(self.systems.draw) do
			local ids = self:query(system.mask)
			system.fn(self, ids)
		end
	end,
	spawn = spawn,
	query = query,
}

function worldlib.new_world()
	local t = add_functions({ last_id = 0, entities = {}, systems = {} }, world_functions)
	return setmetatable(t, world_meta)
end

return worldlib
