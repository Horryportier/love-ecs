---@param self Circle
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
	love.graphics.circle(self.mode, _x, _y, self.radius)
end

---@class Circle: Shape
---@field radius number
---@field mode "fill"|"line"
local circle = {
	---@type fun(self, x: number, y: number)
	---@overload fun(self, pos: { x: number, y: number})
	draw = draw,

	---@type fun(mode: "fill"|"line", radius: number): Circle
	new = function(mode, radius)
		return {
			mode = mode,
			radius = radius,
			draw = draw,
		}
	end,
}

return circle
