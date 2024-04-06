local mask = require("src.mask")
local inspect = require("inspect").inspect

local test_registry = {
	transform = 1,
	sprite = 2,
	weapon = 4,
	material = 8,
}

local function test_generate_mask()
	assert(
		11 == mask.generate_mask({ transform = {}, sprite = "somesprite", material = 1 }, test_registry),
		"generate_mask dosen't equall 11"
	)
	print("OK!")
end

local function test_generate_registry()
	local list = {
		"transform",
		"material",
		"sprite",
		"weapon",
	}

	local new_registry = mask.generate_registry(list)
	print(inspect(new_registry))
end

local function test_contains()
	local m1 = mask.generate_mask({ transform = "", sprite = "" }, test_registry)
	local m2 = mask.generate_mask({ transform = "", sprite = "", weapon = "" }, test_registry)
	assert(mask.contains(m1, m2))
end

test_generate_mask()
test_generate_registry()
test_contains()
