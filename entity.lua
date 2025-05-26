local Entity = {}
Entity.__index = Entity

function Entity:new(x, y)
  local instance = setmetatable({}, self)
  instance.x = x
  instance.y = y
  instance.radius = 3
  return instance
end

function Entity:mouse_in_bounds(mx, my)
  if mx >= self.x - self.radius and 
    mx <= self.x + self.radius and
    my >= self.y - self.radius and 
    my <= self.y + self.radius
  then
    return true
  else
    return false
  end
end

function Entity:draw()
  love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Entity:mousepressed(button, mx, my) 
  if button == 1 and self:mouse_in_bounds(mx, my) then
    print('entity at '.. self.x .. ', ' .. self.y)
    return true
  else
    return false
  end
end

return Entity