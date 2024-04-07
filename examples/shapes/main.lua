package.path = package.path .. ";../../?.lua"
local ecs = require("ecs")
local shape_bundle = require("ecs").shape.shape_bundle
local rect = require("ecs").shape.rect
local circle = require("ecs").shape.circle
local render_shape_bundle = require("ecs").shape.render_shape_bundle

function love.load()
	World = ecs.world.new_world()
	World:register_types({
		"shape",
		"position",
		"color",
	})
	World:add_system("spawn_shapes", "load", {}, {}, function(world, _)
		World:spawn(shape_bundle({ shape = circle.new("line", 50), position = { x = 100, y = 100 } }))
		World:spawn(shape_bundle({ shape = circle.new("fill", 50), position = { x = 100, y = 200 } }))
		World:spawn(shape_bundle({ shape = rect.new("line", 150, 80), position = { x = 200, y = 50 } }))
		World:spawn(shape_bundle({ shape = rect.new("fill", 150, 80), position = { x = 200, y = 150 } }))
	end)

	World:add_system("draw_shapes", "draw", { shape = true, position = true, color = true }, {}, render_shape_bundle)

	World:load()
end

function love.draw()
	World:draw()
end

function love.update(dt)
	World:update(dt)
end
