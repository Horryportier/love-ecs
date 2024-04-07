local masklib = require("src.mask")
local add_functions = require("src.common").add_functions
local inspect = require("inspect").inspect

---@class Entity
---@field id number
---@field components table
---@field mask number
---@field mutated boolean
---@field update_mask fun(self: Entity, component_registry: table)
---@field remove fun(self: Entity, key: string)
---@field insert fun(self: Entity, t: table)
---@field get_id fun(self: Entity): number

local entitiylib = {}

local entity_meta = {
	--- Pretty prints Entity in fromat: Entity(<Entity.id>,<Entity.mask>)
	---@param self Entity
	---@return string
	__tostring = function(self)
		return string.format("Entity(%d, %d)", self.id, self.mask)
	end,
}

local entity_functions = {
	---@param self Entity
	---@return number
	get_id = function(self)
		return self.id
	end,

	--- use this for inserting components for entity
	--- if not used mask *won't* be updated.
	---@param self Entity
	---@param t table|any
	insert = function(self, t)
		for key, value in pairs(t) do
			self.components[key] = value
		end
		self.mutated = true
	end,
	--- use this for removing components from entity
	--- if not used mask *won't* be updated
	---@param self Entity
	---@param key string
	remove = function(self, key)
		self.components[key] = nil
		self.mutated = true
	end,
	---@param self Entity
	---@param components_registry table
	update_mask = function(self, components_registry)
		self.mask = masklib.generate_mask(self.components, components_registry)
		self.mutated = false
	end,
}

--- Creates Entity from components and generates mask
--- Don't use this use World:spawn()
---@param id number
---@param components any[]
---@param component_registry table
---@return Entity
function entitiylib.new_entity(id, components, component_registry)
	---@type Entity
	local t = add_functions({}, entity_functions)
	t.components = components
	t.mask = masklib.generate_mask(components, component_registry)
	t.id = id
	t.mutated = false

	return setmetatable(t, entity_meta)
end

return entitiylib
