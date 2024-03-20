local inspect = require("inspect").inspect
local utils = require("utils")
local entity = require("entity")
local t = require("world")

--- runs tests and prints them win nice format
--- test has to return bool, error (error can be anything)
--- if true prints ok
--- else prints error
---@class TestMenager
---@field tests function[]
local Tests = {
	tests = {},
	metadata = {
		ok_count = 0,
		err_count = 0,
		skip_count = 0,
		skip = {
			test_with_foo = false,
			test_without_foo = false,
		},
	},
	---@enum
	log_levels = {
		quite = 0,
		verbose = 1,
	},
}
function Tests:info(x, force)
	local force_print = force or false
	if force_print or self.log_level == self.log_levels.verbose then
		if x.__tostring ~= nil then
			x = tostring(x)
		elseif type(x) ~= "string" then
			x = inspect(x)
		end
		local fmt = string.format("\27[32m%s\t\27[0m", x)
		print(fmt)
	end
end

function Tests:err(name, err, force)
	local force_print = force or false
	if force_print or self.log_level >= -1 then
		local fmt_err = function()
			if type(err) == "string" then
				return err
			end
			if err.__tostring ~= nil then
				return tostring(err)
			end
			return inspect({ name, err }, {
				depth = math.huge,
				null = "null",
				array = true,
				empty = false,
			})
		end
		local fmt = string.format("\27[31m%s\27[0m", fmt_err())
		print(fmt)
	end
end

function Tests:warn(x)
	print(string.format("\27[33mFUN: %s\n\tErr: %s\27[0m"), x)
end

local test_values = {
	def_entity = {
		foo = "foo",
		bar = 0.,
		baz = { x = 0., y = 0. },
	},
	def_entities = {
		{
			bar = 0.,
			baz = { x = 0., y = 0. },
		},
		{
			foo = "foo",
			baz = { x = 0., y = 0. },
		},
		{
			foo = "foo",
			bar = 0.,
		},
	},
}

function Tests:summary_log()
	local fmt = string.format(
		"Sumarry:\t\27[32mOk(%d)\27[0m\t\27[31mErr(%d)\27[0m\t\27[33mSkipped(%d)\27[0m",
		self.metadata.ok_count,
		self.metadata.err_count,
		self.metadata.skip_count
	)
	print(fmt)
end

---@param name string
---@param test function()
function Tests:add_test(name, test)
	self.tests[name] = test
end

function Tests:run_tests()
	for key, fn in pairs(self.tests) do
		if not self.metadata.skip[key] then
			local res, err = fn()
			if res then
				self:info(key)
				self.metadata.ok_count = self.metadata.ok_count + 1
			else
				self:err(key, err)
				self.metadata.err_count = self.metadata.err_count + 1
			end
		else
			self.metadata.skip_count = self.metadata.skip_count + 1
		end
	end
	self:summary_log()
end

function Tests:run_test(name)
	local res, err = self.tests[name]()
	if res then
		self:info(name)
		self.metadata.ok_count = self.metadata.ok_count + 1
	else
		self:err(name, err)
		self.metadata.err_count = self.metadata.err_count + 1
	end
	self:summary_log()
end

Tests:add_test("test_add_entitiy", function()
	---@type World

	local world = t:new()
	local id = world:spawn(test_values.def_entity)
	return utils.tableEquals(world.entities[id], entity:new(test_values.def_entity))
end)

Tests:add_test("test_get_by_id", function()
	---@type World

	local world = t:new()
	local id = world:spawn(test_values.def_entity)
	local res = world:get_by_id(id)
	return utils.tableEquals(res, entity:new(test_values.def_entity))
end)

Tests:add_test("test_remove", function()
	---@type World

	local world = t:new()
	local id = world:spawn(test_values.def_entity)
	local res = world:remove_entity(id)
	if world.entities[id] ~= nil then
		return false, string.format("falied to remove_entity entitiy at id %d is not nil", id)
	end
	return utils.tableEquals(entity:new(test_values.def_entity), res)
end)

--- query entities shuold return list of entities with certiant  filelds pressen or not pressent
Tests:add_test("test_with_foo", function()
	local correct = {
		Entity2 = {
			entity:new({ baz = {
				x = 0,
				y = 0,
			}, foo = "foo" }),
		},
		Entity3 = entity:new({
			bar = 0,
			foo = "foo",
		}),
	}

	---@type World

	local world = t:new()
	local ids = {}
	for _, value in pairs(test_values.def_entities) do
		table.insert(ids, world:spawn(value))
	end

	local res = world:query({ without = {}, with = { "foo" }, fn = function() end })
	return utils.tableEquals(correct, res)
end)

Tests:add_test("test_without_foo", function()
	local c = {
		Entity2 = entity:new({
			bar = 0,
			baz = {
				x = 0,
				y = 0,
			},
		}),
	}
	---@type World

	local world = t:new()
	local ids = {}
	for _, value in pairs(test_values.def_entities) do
		table.insert(ids, world:spawn(value))
	end
	Tests:info(c)
	local res = world:query({ fn = function() end, without = { "foo" }, with = {} })
	return utils.tableEquals(c, res)
end)

Tests:add_test("add_sysytem", function()
	local world = t:new()
	local err = world:add_system({
		function(en)
			return en
		end,
		type = "update",
		name = "hello_system",
		with = { "name" },
		without = { "cant_print" },
	})
	if err ~= nil then
		return false, err
	end
	return true, nil
end)
-- NOTE: should take system type and name and return QuerySpecificaton and err
Tests:add_test("remove_system", function()
	local world = t:new()
	local system = {
		function(en)
			return en
		end,
		type = "update",
		name = "hello_system",
		with = { "name" },
		without = { "cant_print" },
	}
	local err = world:add_system(system)
	if err ~= nil then
		return false, err
	end
	local res = {}
	res, err = world:remove_system("update", "hello_system")
	if err ~= nil then
		return false, err
	end
	if world.systems["update"]["hello_system"] ~= nil then
		return false, "falied to remove system"
	end
	return utils.tableEquals(system, res)
end)

Tests:add_test("test_startup_system", function()
	local world = t:new()
	local entites = {
		{
			name = "bob",
		},
		{
			name = "alice",
		},
		{
			name = "your mom",
			incognito = true,
		},
	}
	for _, value in pairs(entites) do
		world:spawn(value)
	end
	world:add_system({
		type = "startup",
		name = "greed",
		with = { "name" },
		without = { "incognito" },
		function(en)
			print("Hello World")
			for _, value in pairs(en) do
				print("Hello " .. value.name)
			end
			return en
		end,
	})
	world:startup()
	return true, nil
end)

Tests:add_test("test_mutable_system", function()
	local world = t:new()
	local entites = {
		{
			name = "bob",
		},
		{
			name = "alice",
		},
		{
			name = "your mom",
			incognito = true,
		},
	}
	for _, value in pairs(entites) do
		world:spawn(value)
	end
	world:add_system({
		type = "startup",
		name = "change_name",
		with = { "name" },
		without = { "incognito" },
		function(en)
			print("channig names")
			for key, value in pairs(en) do
				en[key].name = "Mr." .. value.name
			end
			return en
		end,
	})
	world:startup()
	return true, nil
end)

local __main__ = function()
	Tests.log_level = Tests.log_levels.quite
	local name = arg[1]
	if name == "q" then
		Tests.log_level = Tests.log_levels.quite
	elseif name == "v" then
		Tests.log_level = Tests.log_levels.verbose
	end
	if not name then
		Tests:run_tests()
	else
		Tests:run_test(name)
	end
end

__main__()
