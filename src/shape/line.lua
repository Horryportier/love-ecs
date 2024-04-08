---@param self Line
local function draw(self)
	love.graphics.line(self.points)
end

---@class Line: Shape
---@field points number[]
local Line = {
	---@type fun(self)
	draw = draw,

	---@type fun(points: number[]): Line
	new = function(points)
		return {
			points = points,
			draw = draw,
		}
	end,
}

return Line
