local inspect = require("inspect").inspect
local generate_registry = require("src.mask").generate_registry
local contains = require("src.mask").contains
local dont_contain = require("src.mask").dont_contain
local add_functions = require("src.common").add_functions
local new_entity = require("src.entity.entity").new_entity
local new_system = require("src.system.system").new_system
local system_type = require("src.system.system").system_type

---@class World
---@field last_id  number
---@field entities Entity[]
---@field components_registry table
---@field systems Systems
---@field query fun(self: World, mask: Mask)
---@field spawn fun(self: World, components: table)
---@field register_types fun(self: World, list: string[])
---@field add_system fun(self: World, name: string, type: SystemType, query: table<string, boolean>, fn: fun(world: World, ids: number[]))
---@overload fun(self: World, name: string, type: SystemType, with: any[], without: any[], fn: fun(world: World, ids: number[], dt: number))
---@field draw  fun(self: World)
---@field load fun(self: World)
---@field update fun(self: World, dt: number)

---@class worldlib
---@field new_world fun(): World
local worldlib = {}

local world_meta = {
	--- returns pretty formated World with format of: World(e[<number of entities>])
	---@param self World
	---@return string
	__tostring = function(self)
		return string.format("World(E[%d])", #self.entities)
	end,
}

--- Registers types assing them to components_registry
---@param self World
---@param list string[]
local function register_types(self, list)
	self.components_registry = generate_registry(list)
end

---@param self World
---@param components table
---@return Entity
local function spawn(self, components)
	local new_id = self.last_id + 1
	self.entities[new_id] = new_entity(new_id, components, self.components_registry)
	self.last_id = new_id
	return self.entities[new_id]
end
---@param self World
---@param mask Mask
---@return number[]
local function query_ids(self, mask)
	local ids = {}
	for id, value in pairs(self.entities) do
		if value.mutated then
			value:update_mask(self.components_registry)
		end
		if contains(mask.with, value.mask) and dont_contain(mask.without, value.mask) then
			table.insert(ids, id)
		end
	end
	return ids
end

--- adds system to world pass SystemType ("load"|"draw"|"update") to specify what system is it
---@param self World
---@param name string
---@param type SystemType
---@param query table<boolean>
---@param fn fun(world: World, ids: number[])
---@overload fun(self: World, name: string, type: SystemType, query: table<boolean>, fn: fun(world: World, ids: number[], dt: number))
local function add_system(self, name, type, query, fn)
	local with = {}
	for key, value in pairs(query) do
		if value then
			with[key] = true
		end
	end
	local without = {}
	for key, value in pairs(query) do
		if not value then
			without[key] = true
		end
	end

	local system = new_system(type, with, without, fn, self.components_registry)
	if type == system_type.load then
		self.systems.load[name] = system
	end
	if type == system_type.draw then
		self.systems.draw[name] = system
	end
	if type == system_type.update then
		self.systems.update[name] = system
	end
end

local function draw(self)
	for _, system in pairs(self.systems.draw) do
		local ids = self:query_ids(system.mask)
		system.fn(self, ids)
	end
end
local function update(self, dt)
	for _, system in pairs(self.systems.update) do
		local ids = self:query_ids(system.mask)
		system.fn(self, ids, dt)
	end
end

local function load(self)
	for _, system in pairs(self.systems.load) do
		local ids = self:query_ids(system.mask)
		system.fn(self, ids)
	end
end

local world_functions = {
	register_types = register_types,
	update = update,
	load = load,
	draw = draw,
	spawn = spawn,
	query_ids = query_ids,
	add_system = add_system,
}

function worldlib.new_world()
	local t = add_functions({
		last_id = 0,
		entities = {},
		systems = {
			draw = {},
			load = {},
			update = {},
		},
	}, world_functions)
	return setmetatable(t, world_meta)
end

return worldlib
