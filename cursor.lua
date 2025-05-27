local Cursor = {}
Cursor.__index = Cursor

function Cursor:new()
  local instance = setmetatable({}, self)
  instance.e_type = 'point'
  instance.x = 0
  instance.y = 0
  return instance
end

function Cursor:update()
  self.x, self.y = love.mouse.getPosition()
end

function Cursor:bound_check_info()
  return self.x, self.y
end

return Cursor