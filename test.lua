local inspect = require("inspect").inspect
local utils = require("utils")
local entity = require("entity")
--- runs tests and prints them win nice format
--- test has to return bool, error (error can be anything)
--- if true prints ok
--- else prints error
---@class TestMenager
---@field tests function[]
local Tests = {
	tests = {},
	err_log = function(name, err)
		local fmt_err = function()
			if type(err) == "string" then
				return err
			end
			return inspect(err, {
				depth = math.huge,
				null = "NULL",
				array = true,
				empty = false,
			})
		end
		local fmt = string.format("\27[31mFUN: %s\n\tErr: %s\27[0m", name, fmt_err())
		print(fmt)
	end,
	ok_log = function(name)
		local fmt = string.format("\27[32mFUN: %s\tOk!\27[0m", name)
		print(fmt)
	end,
	metadata = {
		ok_count = 0,
		err_count = 0,
		skip = {
			test_with_foo = true,
			test_without_foo = true,
		},
	},
}

local todo = "TODO"

local test_values = {
	build_component = function(t)
		---@type Entity
		local c = { components = t, metadata = { changed = false } }
		return c
	end,
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
		utils.table_length(self.metadata.skip)
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
				self.ok_log(key)
				self.metadata.ok_count = self.metadata.ok_count + 1
			else
				self.err_log(key, err)
				self.metadata.err_count = self.metadata.err_count + 1
			end
		end
	end
	self:summary_log()
end

function Tests:run_test(name)
	local res, err = self.tests[name]()
	if res then
		self.ok_log(name)
		self.metadata.ok_count = self.metadata.ok_count + 1
	else
		self.err_log(name, err)
		self.metadata.err_count = self.metadata.err_count + 1
	end
	self:summary_log()
end

Tests:add_test("test_add_entitiy", function()
	---@type World
	local t = require("world")
	local id = t:spawn(test_values.def_entity)
	return utils.tableEquals(t.entities[id], test_values.build_component(test_values.def_entity))
end)

Tests:add_test("test_get_by_id", function()
	---@type World
	local t = require("world")
	local id = t:spawn(test_values.def_entity)
	return utils.tableEquals(t:get_by_id(id), test_values.build_component(test_values.def_entity))
end)

Tests:add_test("test_remove", function()
	---@type World
	local t = require("world")
	local id = t:spawn(test_values.def_entity)
	local res = t:remove_entity(id)
	if t.entities[id] ~= nil then
		return false, string.format("falied to remove_entity entitiy at id %d is not nil", id)
	end
	return utils.tableEquals(test_values.build_component(test_values.def_entity), res)
end)

--- query entities shuold return list of entities with certiant  filelds pressen or not pressent
--- FIX: works when runned alone but not when with other tests
Tests:add_test("test_with_foo", function()
	local c = {
		Entity2 = {
			components = {
				baz = {
					x = 0,
					y = 0,
				},
				foo = "foo",
			},
			metadata = {
				changed = false,
			},
		},
		Entity3 = {
			components = {
				bar = 0,
				foo = "foo",
			},
			metadata = {
				changed = false,
			},
		},
	}

	---@type World
	local t = require("world")
	local ids = {}
	for _, value in pairs(test_values.def_entities) do
		table.insert(ids, t:spawn(value))
	end

	local res = t:query({ without = {}, with = { "foo" }, fn = function() end })
	return utils.tableEquals(c, res)
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
	local t = require("world")
	local ids = {}
	for _, value in pairs(test_values.def_entities) do
		table.insert(ids, t:spawn(value))
	end

	local res = t:query({ fn = function() end, without = { "foo" }, with = {} })
	return utils.tableEquals(c, res)
end)

Tests:add_test("add_sysytem", function()
	local world = require("world")
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
	local world = require("world")
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
	-- WARN: trust me it works tableEquals function can't handele compering functions
	--print(inspect(system))
	--print(inspect(res))
	--return utils:tableEquals(system, res)
	return true, nil
end)

--- FIX: function dosen't get any entites query not working
Tests:add_test("test_startup_system", function()
	local world = require("world")
	local entites = {
		entity:new({
			name = "bob",
		}),
		entity:new({
			name = "alice",
		}),
		entity:new({
			name = "your mom",
			incognito = true,
		}),
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
				print("Hello " .. value)
			end
			return en
		end,
	})
	world:startup()
	return true, nil
end)

local __main__ = function()
	local name = arg[1]
	if not name then
		Tests:run_tests()
	else
		Tests:run_test(name)
	end
end

__main__()
