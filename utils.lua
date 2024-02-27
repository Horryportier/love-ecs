---local inspect     = require("inspect").inspect
---@class Utils
---@field tableEquals function(table, table)
local Self = {}
-- Function to compare two tables
function Self.tableEquals(table1, table2)
    -- Check if both are tables
    if type(table1) ~= "table" or type(table2) ~= "table" then
        return false, string.format("table1_type(%s) ~= table2_type(%s)", type(table1), type(table2))
    end

    -- Check if they have the same length
    if #table1 ~= #table2 then
        return false, string.format("table1_size(%d) ~= table2_size(%d)", #table1, #table2)
    end

    -- Check each element
    for key, value in pairs(table1) do
        if type(table2[key]) ~= 'function' and type(value) ~= 'function' then
            if type(value) == 'table' then
                return Self.tableEquals(table2[key], value)
            else
            if table2[key] ~= value then
                    return false,
                        string.format("key(%s) table1_value(%s) ~= table2_value(%s)", key, tostring(table1[key]),
                            tostring(value))
                end
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
function Self:has_all(t, keys)
    for _, key in pairs(keys) do
        if t[key] == nil then return false end
    end
    return true
end

--- returns true if any of keys is present
---@param t any
---@param keys any
---@return boolean
function Self:has_any(t, keys)
    for _, key in pairs(keys) do
        if t[key] ~= nil then return true end
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

return Self
