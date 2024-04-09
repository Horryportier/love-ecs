package.path = package.path .. ";../../?.lua"
local ecs = require("ecs")
local shape_bundle = require("ecs").shape.shape_bundle
local rect = require("ecs").shape.rect
local circle = require("ecs").shape.circle
local arc = require("ecs").shape.arc
local line = require("ecs").shape.line
local point = require("ecs").shape.point
local ellipse = require("ecs").shape.ellipse
local polygon = require("ecs").shape.polygon
local render_shape_bundle = require("ecs").shape.render_shape_bundle

function love.load()
	World = ecs.world.new_world()
	World:register_types({
		"shape",
		"position",
		"color",
	})
	World:add_system("spawn_shapes", "load", {}, function(world, _)
		World:spawn(shape_bundle({ shape = circle.new("line", 50), position = { x = 100, y = 100 } }))
		World:spawn(shape_bundle({ shape = circle.new("fill", 50), position = { x = 100, y = 200 } }))
		World:spawn(shape_bundle({ shape = rect.new("line", 150, 80), position = { x = 200, y = 50 } }))
		World:spawn(shape_bundle({ shape = rect.new("fill", 150, 80), position = { x = 200, y = 150 } }))
		World:spawn(shape_bundle({
			shape = arc.new("line", "open", 50, 0, math.pi / 2),
			position = { x = 400, y = 100 },
		}))
		World:spawn(shape_bundle({
			shape = arc.new("line", "pie", 50, 0, math.pi / 2),
			position = { x = 400, y = 200 },
		}))
		World:spawn(shape_bundle({
			shape = arc.new("line", "closed", 50, 0, math.pi / 2),
			position = { x = 400, y = 300 },
		}))

		World:spawn(shape_bundle({ shape = ellipse.new("line", 20, 40), position = { x = 600, y = 50 } }))
		World:spawn(shape_bundle({ shape = ellipse.new("fill", 20, 40), position = { x = 600, y = 150 } }))
		World:spawn(shape_bundle({ shape = line.new({ 600, 40, 400, 20 }) }))
		World:spawn(shape_bundle({ shape = point.new({ 600, 20, 300, 20 }) }))
		World:spawn(shape_bundle({ shape = polygon.new("fill", { 600, 40, 400, 20, 32, 44 }) }))
		World:spawn(shape_bundle({ shape = polygon.new("line", { 600, 20, 300, 20, 24, 443 }) }))
	end)

	World:add_system("draw_shapes", "draw", { shape = true, position = true, color = true }, render_shape_bundle)

	World:load()
end

function love.draw()
	World:draw()
end

function love.update(dt)
	World:update(dt)
end
