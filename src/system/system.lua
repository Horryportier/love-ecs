local generate_mask = require("src.mask").generate_mask
local dont_contain = require("src.mask").dont_contain

---@class System
---@field type SystemType
---@field mask Mask
---@field fn fun(world: World, ids: number[])|fun(world: World, ids: number[], dt: number)
---@field name string
---@field after string?
---@field runned boolean

---@class SystemBuilder
---@field type SystemType
---@field query table<string, boolean>
---@field fn fun(world: World, ids: number[])|fun(world: World, ids: number[], dt: number)
---@field name string
---@field after string?

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

---@param system SystemBuilder
---@return System
function systemlib.new_system(system, component_registry)
	local with = {}
	for key, value in pairs(system.query) do
		if value then
			with[key] = true
		end
	end
	local without = {}
	for key, value in pairs(system.query) do
		if not value then
			without[key] = true
		end
	end
	local _with = generate_mask(with, component_registry)
	local _without = generate_mask(without, component_registry)
	if not dont_contain(_with, _without) then
		error("CONFLICTING MASK: make sure taht with and without mask do not contain same keys")
	end

	return {
		type = system.type,
		name = system.name,
		after = system.after,
		mask = { with = _with, without = _without },
		fn = system.fn,
		runned = false,
	}
end

return systemlib
