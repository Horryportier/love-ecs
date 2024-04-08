local add_functions = require("src.common").add_functions

---@class Shape
---@overload fun(self,  x: number, y: number )
---@field draw fun(self, pos: { x: number, y: number })
---@field new fun(any...): Shape

local shape_bundle_meta = {
	---@param self ShapeBundle
	---@return string
	__tostring = function(self)
		return string.format(
			"ShapeBundle(Shape(%s), Position(%s), Color(%s))",
			tostring(self.shape),
			tostring(self.position),
			tostring(self.color)
		)
	end,
}

local shape_bundle_functions = {
	---@param self ShapeBundle
	---@param pos number|{x:number, y:number}
	---@param y number
	with_position = function(self, pos, y)
		if type(pos) == "table" then
			self.position = pos
		else
			self.position = { x = pos, y = y }
		end
	end,
	---@param self ShapeBundle
	---@param color number[]
	with_color = function(self, color)
		self.color = color
	end,
}
---@param world World
---@param ids number[]
local function render_shape_bundle(world, ids)
	for _, value in pairs(ids) do
		local e = world.entities[value].components
		local r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(unpack(e.color))
		e.shape:draw(e.position.x, e.position.y)
		love.graphics.setColor(r, g, b, a)
	end
end

---@class ShapeBundle
---@field shape Shape
---@field position { x: number, x: number}
---@field color number[]

---@class shapelib
---@field circle Circle
---@field rect Rect
---@field shape_bundle  fun(t: {shape: Shape?, position: {x: number, y: number}?, color: number[]?}): ShapeBundle
---@field render_shape_bundle fun(world: World, ids: number[])
local shapelib = {
	circle = require("src.shape.circle"),
	rect = require("src.shape.rect"),
	arc = require("src.shape.arc"),
	ellipse = require("src.shape.ellipse"),
	line = require("src.shape.line"),
	point = require("src.shape.point"),
	polygon = require("src.shape.polygon"),
	---@type fun(t: {shape: Shape?, position: {x: number, y: number}?, color: number[]?}): ShapeBundle
	shape_bundle = function(t)
		local sb = setmetatable({
			shape = t.shape or require("src.shape.circle").new("line", 50),
			position = t.position or { x = 0, y = 0 },
			color = t.color or { 1, 1, 1, 1 },
		}, shape_bundle_meta)
		--- BUG: can't  add anytihng to components than's not in registry maybe return entity
		--sb = add_functions(sb, shape_bundle_functions)
		return sb
	end,
	render_shape_bundle = render_shape_bundle,
}

return shapelib
