local Ecs = require("ecs")

local inspect = require("inspect").inspect

function love.load()
	print("love version:", love.getVersion())
	print("love-ecs version:", Ecs.getVersion())
	print(inspect(Ecs))
end

function love.update() end

function love.draw() end
