local generate_mask = require("src.mask").generate_mask

---@alias System { mask: number, fn: fun(world: World, ids: number[]) }
---@class Systems
---@field draw System[]
---@field update System[]
---@field load System[]

local systemlib = {}

---@enum SysetemType
systemlib.system_type = {
	draw = "draw",
	update = "update",
	load = "load",
}

---comment
---@param components any[]
---@param fn fun(world: World, ids: number[])
---@return System
function systemlib.new_system(components, fn, component_registry)
	return { mask = generate_mask(components, component_registry), fn = fn }
end

return systemlib
