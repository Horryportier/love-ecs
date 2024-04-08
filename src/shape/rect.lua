---@param self Rect
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
	love.graphics.rectangle(self.mode, _x, _y, self.width, self.height)
end

---@class Rect: Shape
---@field width number
---@field height number
---@field mode love.DrawMode
local Rect = {
	---@type fun(self, x: number, y: number)
	---@overload fun(self, pos: { x: number, y: number})
	draw = draw,

	---@type fun(mode: love.DrawMode, width : number, height): Rect
	new = function(mode, width, height)
		return {
			mode = mode,
			width = width,
			height = height,
			draw = draw,
		}
	end,
}

return Rect
