-- TODO:
-- DOCS/TYPES
local Ecs = require("ecs")

local inspect = require("inspect").inspect

local function random_cilcle()
	math.randomseed(os.clock())
	return {
		position = { x = math.random(100, 600), y = math.random(100, 500) },
		shape = {
			radius = math.random(10, 40),
			mode = math.random(1, 2) == 2 and "fill" or "line",
		},
		color = {
			math.random(0.1, 0.9),
			math.random(0.1, 0.9),
			math.random(0.1, 0.9),
			1,
		},
	}
end

function love.load()
	love.window.setTitle("LUA-ECS")
	print("love version:", love.getVersion())
	print("love-ecs version:", Ecs.getVersion())

	World = Ecs.world.new_world()
	World:register_types({
		"sprite",
		"color",
		"material",
		"position",
		"shape",
	})
	print(inspect(World))

	for _ = 1, 100, 1 do
		World:spawn(random_cilcle())
	end
	local shape_components = {
		position = true,
		color = true,
		shape = true,
	}

	World:add_system("draw_shape", "draw", shape_components, function(world, ids)
		for _, value in pairs(ids) do
			local e = world.entities[value].components
			local r, g, b, a = love.graphics.getColor()
			love.graphics.setColor(unpack(e.color))
			love.graphics.circle(e.shape.mode, e.position.x, e.position.y, e.shape.radius)
			love.graphics.setColor(r, g, b, a)
		end
	end)
	World:add_system("move_shapes", "update", { shape = true, position = true }, function(world, ids, dt)
		for _, value in pairs(ids) do
			local old_pos = world.entities[value].components.position
			world.entities[value].components.position = {
				x = old_pos.x + math.random(-1, 1),
				y = old_pos.y + math.random(-1, 1),
			}
		end
	end)
end

function love.update(dt)
	World:update(dt)
end

function love.draw()
	World:draw()
end
