---@class EntityMetadata
---@field changed boolean
---@class Entity
---@field components any[]
---@field metadata EntityMetadata
local Self = {
    components = {},
    metadata = {
        changed = false
    }
}

return Self
