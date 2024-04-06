local inspect = require("inspect").inspect
local generate_registry = require("src.mask").generate_registry
local contains = require("src.mask").contains
local add_functions = require("src.common").add_functions
local new_entity = require("src.entity.entity").new_entity
local new_system = require("src.system.system").new_system
local system_type = require("src.system.system").system_type

---@class World
---@field last_id  number
---@field entities Entity[]
---@field components_registry table
---@field systems Systems
---@field query fun(self: World, mask: number)

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
--- max size for now is 64
---@param self World
---@param list string[]
local function register_types(self, list)
	self.components_registry = generate_registry(list)
end

---@param self World
---@param components table
local function spawn(self, components)
	local new_id = self.last_id + 1
	self.entities[new_id] = new_entity(new_id, components, self.components_registry)
	self.last_id = new_id
end
---@param self World
---@param mask number
---@return number[]
local function query(self, mask)
	local ids = {}
	for id, value in pairs(self.entities) do
		if contains(mask, value.mask) then
			table.insert(ids, id)
		end
	end
	return ids
end

---@param self World
---@param name string
---@param type SysetemType
---@param components any[]
---@param fn fun(world: World, ids: number[])
local function add_system(self, name, type, components, fn)
	local system = new_system(components, fn, self.components_registry)
	print(inspect(system))
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
		local ids = self:query(system.mask)
		system.fn(self, ids)
	end
end
local function update(self)
	for _, system in pairs(self.systems.update) do
		local ids = self:query(system.mask)
		system.fn(self, ids)
	end
end

local function load(self)
	for _, system in pairs(self.systems.load) do
		local ids = self:query(system.mask)
		system.fn(self, ids)
	end
end

local world_functions = {
	register_types = register_types,
	update = update,
	load = load,
	draw = draw,
	spawn = spawn,
	query = query,
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
