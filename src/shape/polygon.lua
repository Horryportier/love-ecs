---@param self Polygon
local function draw(self)
	love.graphics.polygon(self.mode, self.points)
end

---@class Polygon: Shape
---@field points number[]
---@field mode love.DrawMode
local Polygon = {
	---@type fun(self)
	draw = draw,

	---@type fun(mode: love.DrawMode, points: number[]): Polygon
	new = function(mode, points)
		return {
			mode = mode,
			points = points,
			draw = draw,
		}
	end,
}

return Polygon
