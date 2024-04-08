---@param self Arc
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
	love.graphics.arc(self.mode, self.arc_type, _x, _y, self.radius, self.angle1, self.angle2, self.segments)
end

---@class Arc: Shape
---@field radius number
---@field angle1 number
---@field angle2 number
---@field segments number
---@field arc_type love.ArcType
---@field mode love.DrawMode
local Arc = {
	---@type fun(self, x: number, y: number)
	---@overload fun(self, pos: { x: number, y: number})
	draw = draw,

	---@type fun(mode: love.DrawMode,arc_type: love.ArcType , radius : number, angle1: number, angle2: number, segments: number?): Arc
	new = function(mode, arc_type, radius, angle1, angle2, segments)
		return {
			arc_type = arc_type,
			mode = mode,
			radius = radius,
			angle1 = angle1,
			angle2 = angle2,
			segments = segments,
			draw = draw,
		}
	end,
}

return Arc
