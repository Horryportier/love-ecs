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
---@field add_system fun(self: World, system : SystemBuilder)
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
---@param system SystemBuilder
local function add_system(self, system)
	local system = new_system(system, self.components_registry)

	if system.type == system_type.load then
		self.systems.load[system.name] = system
	end
	if system.type == system_type.draw then
		self.systems.draw[system.name] = system
	end
	if system.type == system_type.update then
		self.systems.update[system.name] = system
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
