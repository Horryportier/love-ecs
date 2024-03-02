local utils = require("utils")
local inspect = require("inspect").inspect
-- TODO: create system menager / decied how sysetem will be created
-- NOTE: maybe adding system would look something like this
--       world:add_system {
--          function (e Entity[]) returns Entity[],
--          name = "system name", -- optional
--          with = { "a", "b", "c" },
--          without = { "d" }
--       } returns error|nil

---@enum QueryType
local _ = {
	startup = "startup",
	update = "update",
	draw = "draw",
}

---@class Query
---@field fn function
---@field with string[]
---@field without string[]

---@class SystemError
---@field msg string
---@field info table

---@class QuerySpecification
---@field type QueryType
---@field name string?
---@field with string[]?
---@field without string[]?

return {
	---@param World World
	---@return World
	init_system_funcitons = function(World)
		--- adds system to world
		--- world:add_system {
		---        function (enities Entity[]) returns Entity[],
		---         type = QueryType,
		---         name = "system name",
		---         with = { "a", "b", "c" },
		---         without = { "d" }
		---      }
		---@param t QuerySpecification
		---@return SystemError?
		function World:add_system(t)
			local fn = utils:find_by_type("function", t)
			if fn == nil then
				---@type SystemError
				local err = { msg = "no function speciifed", info = { system_name = t.name } }
				return err
			end
			local required_fields = {
				"type",
				"name",
				"with",
				"without",
			}
			if not utils:has_all(t, required_fields) then
				---@type SystemError
				local err = { msg = "no required type found", info = required_fields }
				return err
			end
			local add_to_system = function(s)
				s[t.name] = {
					fn = fn,
					with = t.with,
					without = t.without,
				}
				return s
			end
			if t.type == "startup" then
				self.systems.startup = add_to_system(self.systems.startup)
			end
			if t.type == "update" then
				self.systems.update = add_to_system(self.systems.update)
			end
			if t.type == "draw" then
				self.systems.draw = add_to_system(self.systems.draw)
			end
			return nil
		end

		---@param type QueryType
		---@param name string
		---@return QuerySpecification?, SystemError?
		function World:remove_system(type, name)
			local system = self.systems[type][name]
			if not system then
				return nil, { msg = "can't find system", info = { type = type, name = name } }
			end
			self.systems[type][name] = nil
			return {
				    system.fn,
				    name = name,
				    with = system.with,
				    without = system.without,
				    type = type,
			    },
			    nil
		end

		---@class World
		---@field startup function
		function World:startup()
			--print(inspect(self.entities))
			for key, system in pairs(self.systems.startup) do
				print("runnig startup system:  " .. key)
				local entities = self:query(system)
				local mutated = system.fn(entities)
				for k, mut in pairs(mutated) do
					self.entities[k] = mut
				end
			end
		end

		return World
	end,
}
