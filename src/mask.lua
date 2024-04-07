local bit = require("bit")

local masklib = {}

---@alias Mask { with: number, without: number  }

--- generate_mask takes table of commponents and registry,
--- where registry is table of key == number
---@param table table
---@param registry table
---@return number
function masklib.generate_mask(table, registry)
	local mask = 0
	for key, _ in pairs(table) do
		if not registry[key] then
			error(string.format("key [%s] not in registry <%s>", key, tostring(registry)))
		end
		mask = mask + registry[key]
	end
	return mask
end

function masklib.generate_registry(list)
	local registry = {}
	for index, value in ipairs(list) do
		registry[value] = math.pow(2, index - 1)
	end
	return registry
end

function masklib.contains(m1, m2)
	if bit.band(m1, m2) == m1 then
		return true
	end
	return false
end

function masklib.dont_contain(m1, m2)
	if bit.band(m1, m2) == 0 then
		return true
	end
	return false
end

return masklib
