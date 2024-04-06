local masklib = require("src.mask")
local add_functions = require("src.common").add_functions

---@class Entity
---@field id number
---@field components any[]
---@field mask number

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
	return setmetatable(t, entity_meta)
end

return entitiylib
