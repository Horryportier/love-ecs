---@param self Point
local function draw(self)
	love.graphics.points(self.points)
end

---@class Point: Shape
---@field points number[]
local Point = {
	---@type fun(self)
	draw = draw,

	---@type fun(points: number[]): Point
	new = function(points)
		return {
			points = points,
			draw = draw,
		}
	end,
}

return Point
