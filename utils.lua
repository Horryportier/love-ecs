local inspect = require("inspect").inspect
---@class Utils
---@field tableEquals function(table, table)
local S = {}
-- Function to compare two tables
function S.tableEquals(table1, table2)
	--print("table1:\n" .. inspect(table1))
	--print("table2:\n" .. inspect(table2))
	-- Check if both are tables
	if type(table1) ~= "table" or type(table2) ~= "table" then
		return false,
			{ string.format("table1_type(%s) ~= table2_type(%s)", type(table1), type(table2)), table1, table2 }
	end

	-- Check if they have the same length
	if #table1 ~= #table2 then
		return false, { string.format("table1_size(%d) ~= table2_size(%d)", #table1, #table2), table1, table2 }
	end

	-- Check each element
	for key, value in pairs(table1) do
		if type(value) == "table" then
			return S.tableEquals(table2[key], value)
		else
			if table2[key] ~= value then
				return false,
					{
						string.format(
							"key(%s) table1_value(%s) ~= table2_value(%s)",
							key,
							inspect(table2[key]) .. type(table2[key]),
							inspect(value) .. type(value)
						),
						table1,
						table2,
					}
			end
		end
	end
	-- If all elements are equal
	return true
end

--- returns true if all key are present
---@param t table
---@param keys string[]
---@return boolean
function S:has_all(t, keys)
	if not keys then
		return true
	end
	for _, key in pairs(keys) do
		if t[key] == nil then
			return false
		end
	end
	return true
end

--- returns true if any of keys is present
---@param t any
---@param keys any
---@return boolean
function S:has_any(t, keys)
	if keys == nil then
		return false
	end
	for _, key in pairs(keys) do
		if t[key] ~= nil then
			return true
		end
	end
	return false
end

---- Example tables
--local tableA = { 1, 2, 3, { "a" } }
--local tableB = { 1, 2, 3, { "a" } }
--local tableC = { 1, 2, 4 }
--
---- Comparing tables
--print(Self:tableEquals(tableA, tableB)) -- Output: true
--print(Self:tableEquals(tableA, tableC)) -- Output: false

---@param t type
---@param table table
---@return any?
function S:find_by_type(t, table)
	for _, value in pairs(table) do
		if type(value) == t then
			return value
		end
	end
	return nil
end

function S.table_length(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

return S
