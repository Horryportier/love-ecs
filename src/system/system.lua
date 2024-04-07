local generate_mask = require("src.mask").generate_mask

---@alias System { mask: Mask, fn: fun(world: World, ids: number[]) }
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
---@param with any[]
---@param without any[]
---@param fn fun(world: World, ids: number[])
---@return System
function systemlib.new_system(with, without, fn, component_registry)
	return {
		mask = {
			with = generate_mask(with, component_registry),
			without = generate_mask(without, component_registry),
		},
		fn = fn,
	}
end

return systemlib
