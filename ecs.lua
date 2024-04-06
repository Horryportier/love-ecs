local ecslib = {
	world = require("src.world.world"),
	entity = require("src.entity.entity"),
}

---Gets the current running version of LÖVE-ECS.
---
---@return number major
---@return number minor
---@return number revision
---@return string codename
function ecslib.getVersion()
	return 0, 0, 1, "Genesis"
end

return ecslib
