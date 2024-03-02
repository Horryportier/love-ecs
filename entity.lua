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

---comment
---@param components any
---@return Entity
function Self:new(components)
	return {
		components = components,
		metadata = {
			changed = false,
		},
	}
end

return Self
