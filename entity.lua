local inspect = require("inspect").inspect
---@class EntityMetadata
---@field changed boolean
---@class Entity
---@field components any[]
---@field metadata EntityMetadata
local Self = {
	components = {},
	metadata = {
		changed = false,
	},
}

Self.mt = {
	__tostring = function(self)
		return inspect(self)
	end,
}

function Self:strip()
	return self.components
end

---@param components any[]
---@return Entity
function Self.dress(components)
	return setmetatable({
		components = components,
		metadata = {
			changed = true,
		},
		strip = Self.strip,
	}, Self.mt)
end

---comment
---@param components any
---@return Entity
function Self:new(components)
	local e = self.dress(components)
	e.metadata.changed = false
	return e
end

return Self
