---@param self Ellipse
---@param x {x: number, y: number}|number
---@param y number
local function draw(self, x, y)
	local _x, _y = nil, nil
	if type(x) == "table" then
		_x, _y = x.x, x.y
	else
		_x = x
		_y = y
	end
	love.graphics.ellipse(self.mode, _x, _y, self.radiusx, self.radiusy, self.segments)
end

---@class Ellipse: Shape
---@field radiusx number
---@field radiusy number
---@field segments number
---@field arc_type love.ArcType
---@field mode love.DrawMode
local Arc = {
	---@type fun(self, x: number, y: number)
	---@overload fun(self, pos: { x: number, y: number})
	draw = draw,

	---@type fun(mode: love.DrawMode, radiusx : number, radiusy : number, segments: number?): Ellipse
	new = function(mode, radiusx, radiusy, segments)
		return {
			mode = mode,
			radiusx = radiusx,
			radiusy = radiusy,
			segments = segments,
			draw = draw,
		}
	end,
}

return Arc
