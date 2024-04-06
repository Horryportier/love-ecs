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

	for _ = 1, 10, 1 do
		World:spawn(random_cilcle())
	end

	World.systems.draw = {
		draw_shape = {
			mask = 26,
			---@param world World
			---@param ids number[]
			fn = function(world, ids)
				for _, value in pairs(ids) do
					local e = world.entities[value].components
					local r, g, b, a = love.graphics.getColor()
					love.graphics.setColor(unpack(e.color))
					love.graphics.circle(e.shape.mode, e.position.x, e.position.y, e.shape.radius)
					love.graphics.setColor(r, g, b, a)
				end
			end,
		},
	}
end

function love.update(dt)
	World:update(dt)
end

function love.draw()
	World:draw()
end
