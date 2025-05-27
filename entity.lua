local g = require('geometry')
local Entity = {}
Entity.__index = Entity

function Entity:newPoint(x, y)
  local instance = setmetatable({}, self)
  instance.e_type = 'point'
  instance.x = x
  instance.y = y
  instance.to_delete = false
  instance.color = {0, 0, 0}
  instance.graphic = function(self)
    return
  end
  instance.check_info = function(self)
    return self.x, self.y
  end
  instance.is_in_bounds = function(self)
    return
  end
  return instance
end

function Entity:newCircle(x, y, r)
  local instance = setmetatable({}, self)
  instance.e_type = 'circle'
  instance.x = x
  instance.y = y
  instance.r = r
  instance.to_delete = false
  instance.color = {1, 1, 1}
  instance.graphic = function(self)
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.r)
    love.graphics.setColor(1, 1, 1)
  end
  instance.check_info = function(self)
    return self.x, self.y, self.r
  end
  instance.is_in_bounds = function(self)
    local mx, my = CURSOR:bound_check_info()
    return g.is_point_in_circ(mx, my, self.x, self.y, self.r)
  end
  return instance
end

function Entity:newRectangle(x, y, w, h)
  local instance = setmetatable({}, self)
  instance.e_type = 'rectangle'
  instance.x = x
  instance.y = y
  instance.w = w
  instance.h = h
  instance.to_delete = false
  instance.color = {1, 1, 1}
  instance.graphic = function(self)
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1)
  end
  instance.check_info = function(self)
    return self.x, self.y, self.w, self.h
  end
  instance.is_in_bounds = function(self)
    local mx, my = CURSOR:bound_check_info()
    return g.is_point_in_rect(mx, my, self.x, self.y, self.w, self.h)
  end
  return instance
end


function Entity:is_mouse_in_bounds()
   return self.is_in_bounds(self)
end

function Entity:bound_check_info()
  return self.check_info(self)
end

function Entity:draw()
  self.graphic(self)
end

function Entity:mouse_handler(button, color) 
  self.color = color
  if button == 1 and self:is_mouse_in_bounds() then
    self:on_Click()
  end
end

function Entity:on_Click()
  self.to_delete = true
end


return Entity