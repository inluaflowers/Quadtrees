local t = require('tools')
local Node = {}
Node.__index = Node

Node.Pool ={}

function Node:new(x, y, w, h, lvl)
  instance = setmetatable({}, self)
  instance.x = x
  instance.y = y
  instance.w = w
  instance.h = h
  instance.lvl = lvl
  instance.children = {}
  instance.entities = {}
  instance.id = "ROOT"
  instance.child_num = 0
  instance.ent_num = 0
  instance.x_range = x .. '-' .. x + w
  instance.y_range = y .. '-' .. y + h
  instance.fill = 'line'
  return instance
end

for i = 1, 1 do
  table.insert(Node.Pool, Node:new(0, 0, 0, 0, 0))
end

function Node:set(x, y, w, h, lvl)
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.lvl = lvl
  self.x_range = x .. '-' .. x + w
  self.y_range = y .. '-' .. y + h
end

function Node:mouse_in_bounds(mx, my)
  if mx >= self.x and 
    mx <= self.x + self.w and
    my >= self.y and 
    my <= self.y + self.h
  then
    return true
  else
    return false
  end
end

function Node:is_in_bounds(entity)
  if entity.x + entity.radius >= self.x and 
    entity.x - entity.radius <= self.x + self.w and
    entity.y + entity.radius >= self.y and 
    entity.y - entity.radius <= self.y + self.h
  then
    return true
  else
    return false
  end
end

function Node:has_entity_space()
  local count = t.table_length(self.entities)
  if count < 4 then
    return true
  else
    return false
  end
end

function Node:has_children()
  if #self.children > 0 then
    return true
  else
    return false
  end
end

function Node:is_hovered(mx, my)
  if self:mouse_in_bounds(mx, my) then
    if self:has_children() then
      self.fill = 'line'
      for _, child_node in ipairs(self.children) do
        child_node:is_hovered(mx, my)
      end
      return false
    else 
      self.fill = "fill"
      return true
    end
  else
    self.fill = 'line'
    return false
  end
  
end


function Node:update(dt, mx, my)
  if self:is_hovered(mx, my) then
    if self.lvl == 0 then
      self.fill = 'line'
    end
    self.ent_num = #self.entities
    self.id ="Lvl: " .. tostring(self.lvl) .. ' Chld: ' .. self.child_num .. '/4' .. ' Ent: ' .. self.ent_num
    for _, node in ipairs(self.children) do
      node:update(dt, mx, my)
    end
  end
end

function Node:find_valid_node(entity)
  if self:is_in_bounds(entity) then
    if self:has_children() then
      for _, child_node in ipairs(self.children) do
        child_node:find_valid_node(entity)
      end
    end
    if not self:has_children() then
      if self:has_entity_space() then
        self:add_entity_to_node(entity)
        print(self.id, #self.entities)
      else
      self:add_entity_to_node(entity) 
      self:divide()
      end
    end
    return true
  else
    return false
  end
end

function Node:check_children(entity) 
  for idx, child_node in ipairs(self.children) do
    print(child_node:is_in_bounds(entity))
    if child_node:is_in_bounds(entity) then
      if child_node:has_children() then 
        child_node:check_children(entity)
      else
        child_node:add_entity_to_node(entity)
      end
    end
  end
end


function Node:divide()
  print('dividing')
  local x1 = self.x
  local x2 = self.x + self.w/2
  local y1 = self.y 
  local y2 = self.y + (self.h/2)
  local child_w = self.w/2
  local child_h = self.h/2
  local child_lvl = self.lvl + 1

  local xM = {x1, x2}
  local yM = {y1, y2}

  print(self.x, x1, x2, self.w/2)
  
  local child_count = 0
  for _, x in ipairs(xM) do
    for _, y in ipairs(yM) do
      child_count = child_count + 1
      local child_node = Node.allocate_node(x, y, child_w, child_h, child_lvl)
      for _, entity in ipairs(self.entities) do
        child_node:find_valid_node(entity)
      end
      child_node.child_num = child_count
      child_node.ent_num = #child_node.entities
      child_node.id ="Lvl: " .. tostring(child_lvl) .. ' Chld: ' .. child_count .. '/4' .. ' Ent: ' .. child_node.ent_num
      table.insert(self.children, child_node)
    end
  end
  self.entities = {}
  print('Number of Children: ' .. tostring(#self.children))
  local count = 0
  for _, child_node in ipairs(self.children) do
    count = count + 1
    print('Child # ' .. count)
    print(child_node.x, child_node.y)
  end
end

function Node:add_entity_to_node(entity)
  table.insert(self.entities, entity)
end

function Node.allocate_node(x, y, w, h, lvl)
  local node = table.remove(Node.Pool)
  if node then 
    node:set(x, y, w, h, lvl)
    return node
  else
    return Node:new(x, y, w, h, lvl)
  end
end

function Node.release_node(node)
  node.children = {}
  node.entities = {}
  table.insert(Node.Pool, node)
end

function Node:draw()

  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle(self.fill, self.x, self.y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
  for _, entity in pairs(self.entities) do
    entity:draw()
  end
  for _, node in pairs(self.children) do
    node:draw()
  end
  if self:has_children() then 
    love.graphics.setColor(0, 0, 0)
  end
  love.graphics.setColor(1, 1, 1)


  if self:has_children() then
    self.stringy = ''
  else
    self.stringy = self.id .. '\n' .. self.x_range .. '\n' .. self.y_range
  end
  love.graphics.print(self.stringy, self.x, self.y)

end

function Node:mousepressed(button, mx, my)
  if self:is_hovered(mx, my) then
    for _, entity in ipairs(self.entities) do
      entity:mousepressed(button, mx, my)
    end
  end
end

return Node
