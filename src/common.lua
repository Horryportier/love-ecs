local commonlib = {}

--- takes table and table of functions and appends them to t.
--- warning! will overwrite keys in t  if they arledy exist.
---@param t table
---@param ft table
---@return table
function commonlib.add_functions(t, ft)
	for key, value in pairs(ft) do
		t[key] = value
	end
	return t
end

return commonlib
