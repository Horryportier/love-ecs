package.path = package.path .. ";../?.lua"
-- TODO:
-- DOCS/TYPES
local Ecs = require("ecs")
local circle = require("ecs").shape.circle
local rect = require("ecs").shape.rect

local inspect = require("inspect").inspect

local function random_cilcle()
	math.randomseed(os.clock())
	return {
		position = { x = math.random(100, 600), y = math.random(100, 500) },
		shape = math.random(1, 2) == 2 and circle.new("line", 40) or rect.new("line", 20, 40),
	}
end

local function with_color(t)
	t.color = {
		math.random(0.1, 0.9),
		math.random(0.1, 0.9),
		math.random(0.1, 0.9),
		1,
	}
	return t
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
	print(inspect(World.components_registry))

	for _ = 1, 1000, 1 do
		local circle = random_cilcle()
		circle = math.random(1, 2) == 1 and with_color(circle) or circle
		World:spawn(circle)
	end

	World:add_system("draw_shape", "draw", {
		position = true,
		shape = true,
	}, {}, function(world, ids)
		for _, value in pairs(ids) do
			local e = world.entities[value].components
			local r, g, b, a = love.graphics.getColor()
			if e.color then
				love.graphics.setColor(unpack(e.color))
			end
			e.shape:draw(e.position.x, e.position.y)
			if e.color then
				love.graphics.setColor(r, g, b, a)
			end
		end
	end)
	World:add_system(
		"move_shapes",
		"update",
		{ shape = true, position = true },
		{ color = true },
		function(world, ids, dt)
			for _, value in pairs(ids) do
				local old_pos = world.entities[value].components.position
				world.entities[value].components.position = {
					x = old_pos.x + math.random(-10, 10) * dt,
					y = old_pos.y + math.random(-10, 10) * dt,
				}
			end
		end
	)
	World:add_system("print_info", "draw", {}, {}, function(_, _)
		love.graphics.print(love.timer.getFPS())
	end)
end

function love.update(dt)
	World:update(dt)
end

function love.draw()
	World:draw()
end
