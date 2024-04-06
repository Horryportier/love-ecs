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

function entitiylib.new_entity(t)
	t = add_functions(t, entity_functions)
	return setmetatable(t, entity_meta)
end

return entitiylib
