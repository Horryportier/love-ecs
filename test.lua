local inspect     = require("inspect").inspect
local utils       = require("utils")
--- runs tests and prints them win nice format
--- test has to return bool, error (error can be anything)
--- if true prints ok
--- else prints error
---@class TestMenager
---@field tests function[]
local Tests       = {
    tests = {},
    err_log = function(name, err)
        local fmt = string.format("\27[31mFUN: %s\n\tErr: %s\27[0m", name, inspect(err, {
            depth = math.huge,
            null = "NULL",
            array = true,
            empty = false
        }))
        print(fmt)
    end,
    ok_log = function(name)
        local fmt = string.format("\27[32mFUN: %s\tOk!\27[0m", name)
        print(fmt)
    end,
    metadata = {
        ok_count = 0,
        err_count = 0,
    }
}

local todo        = "TODO: "

local test_values = {
    build_component = function (t)
        ---@type Entity
        local c = { components = t, metadata = { changed = false } }
        return c
    end,
    def_entity = {
            foo = "foo",
            bar = 0.,
            baz = { x = 0., y = 0. }
        },
    def_entities = {
            {
                bar = 0.,
                baz = { x = 0., y = 0. }
            },
            {
                foo = "foo",
                baz = { x = 0., y = 0. }
            },
            {
                foo = "foo",
                bar = 0.,
            },
    }
}

function Tests:summary_log()
    local fmt = string.format("Sumarry:    \27[32mOk(%d)\27[0m\t\27[31mErr(%d)\27[0m", self.metadata.ok_count,
        self.metadata.err_count)
    print(fmt)
end

---@param name string
---@param test function()
function Tests:add_test(name, test)
    self.tests[name] = test
end

function Tests:run_tests()
    for key, fn in pairs(self.tests) do
        local res, err = fn()
        if res then
            self.ok_log(key)
            self.metadata.ok_count = self.metadata.ok_count + 1
        else
            self.err_log(key, err)
            self.metadata.err_count = self.metadata.err_count + 1
        end
    end
    self:summary_log()
end

Tests:add_test("test_add_entitiy", function()
    ---@type World
    local t = require "world"
    local id = t:spawn(test_values.def_entity)
    return utils.tableEquals(t.entities[id], test_values.build_component( test_values.def_entity))
end)

Tests:add_test("test_get_by_id", function()
    ---@type World
    local t = require "world"
    local id = t:spawn(test_values.def_entity)
    return utils.tableEquals(t:get_by_id(id), test_values.build_component( test_values.def_entity))
end)

Tests:add_test("test_remove", function()
    ---@type World
    local t = require "world"
    local id = t:spawn(test_values.def_entity)
    local res = t:remove_entity(id)
    if t.entities[id] ~= nil then
        return false, string.format("falied to remove_entity entitiy at id %d is not nil", id)
    end
    return utils.tableEquals(test_values.build_component (test_values.def_entity), res)
end)

--- query entities shuold return list of entities with certiant  filelds pressen or not pressent
Tests:add_test("test_with_foo", function()
    local c = {
        Entity1 = {
            bar = 0,
            baz = {
                x = 0,
                y = 0
            },
            foo = "foo"
        },
        Entity4 = {
            baz = {
                x = 0,
                y = 0
            },
            foo = "foo"
        },
        Entity5 = {
            bar = 0,
            foo = "foo"
        }
    }

    ---@type World
    local t = require "world"
    local ids = {}
    for _, value in pairs(test_values.def_entities) do
        table.insert(ids, t:spawn(value))
    end

    local res = t:query({ "foo" })
    return utils:tableEquals(c, res)
end)



Tests:add_test("test_without_foo", function()
    local c = {
        Entity2 = {
            bar = 0,
            baz = {
                x = 0,
                y = 0
            }
        },
    }
    ---@type World
    local t = require "world"
    local ids = {}
    for _, value in pairs(test_values.def_entities) do
        table.insert(ids, t:spawn(value))
    end

    local res = t:query({}, { "foo" })
    return utils:tableEquals(c, res)
end)

Tests:add_test("add_sysytem", function()
    return false, todo
end)
Tests:add_test("remove_system", function()
    return false, todo
end)
Tests:add_test("run_system", function()
    return false, todo
end)

Tests:run_tests()
