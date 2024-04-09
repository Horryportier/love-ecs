package.path = package.path .. ";../../?.lua"
local ecs = require("ecs")

function love.load()
	--- This is how you can Create world instance
	World = ecs.world.new_world()
	--- Every type (key of entity components) needs to be registerd.
	--- WARNING: querring uses bit mask under the hood so,
	--- there is limit on how many types you can have  which is *(63)*. -- will try  to solve it in the near future
	--- for now the best way of combating this is to create high level type like shape and choose sub type in code.
	World:register_types({
		"shape",
		"position",
		"color",
	})

	-- adding system to draw loop
	-- this system will run in draw loop
	-- NOTE: if you happend to specify conflicting mask for `with` and `without` code will errror
	World:add_system("draw_shape", "draw", { shape = true, position = true, color = true }, function(world, ids)
		for _, value in pairs(ids) do
			local e = world.entities[value].components
			local r, g, b, a = love.graphics.getColor()
			love.graphics.setColor(unpack(e.color))
			love.graphics.circle(e.shape.mode, e.position.x, e.position.y, e.shape.radius)
			love.graphics.setColor(r, g, b, a)
		end
	end)

	-- adding system to load group
	-- this system will run on load
	World:add_system("spawn_circle", "load", {}, function(world, _)
		world:spawn({
			position = { x = 200, y = 200 },
			shape = {
				radius = 40,
				mode = "fill",
			},
			color = {
				0.1,
				0.5,
				0.2,
				1,
			},
		})
	end)

	--- NOTE: call `World:load()` at the end of  `love.load()` for load systems to work
	World:load()
end

--- NOTE: call `World:draw()` in `love.draw()` for draw systems to work
function love.draw()
	World:draw()
end

--- NOTE: call `World:update()` in `love.update()` for update systems to work
function love.update(dt)
	World:update(dt)
end
