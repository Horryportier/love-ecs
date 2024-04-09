local generate_mask = require("src.mask").generate_mask
local dont_contain = require("src.mask").dont_contain

---@alias System { type: SystemType, mask: Mask, fn: fun(world: World, ids: number[]) }
---@class Systems
---@field draw System[]
---@field update System[]
---@field load System[]

local systemlib = {}

---@enum SystemType
systemlib.system_type = {
	draw = "draw",
	update = "update",
	load = "load",
}

---@param with any[]
---@param without any[]
---@param fn fun(world: World, ids: number[])
---@return System
function systemlib.new_system(type, with, without, fn, component_registry)
	local _with = generate_mask(with, component_registry)
	local _without = generate_mask(without, component_registry)
	if not dont_contain(_with, _without) then
		error("CONFLICTING MASK: make sure taht with and without mask do not contain same keys")
	end
	return {
		type = type,
		mask = {
			with = generate_mask(with, component_registry),
			without = generate_mask(without, component_registry),
		},
		fn = fn,
	}
end

local systems = {
	system_a = {},
	system_b = {},
	{
		system_c = {},
		system_d = {},
	},
}

return systemlib
