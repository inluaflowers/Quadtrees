local t = require('tools')
local g = require('geometry')
local Node = {}
Node.__index = Node

Node.Pool ={}

function Node:new(x, y, w, h, lvl)
  instance = setmetatable({}, self)
  instance.type = "rectangle"
  instance.x = x
  instance.y = y
  instance.w = w
  instance.h = h
  instance.lvl = lvl
  instance.children = {}
  instance.entities = {}
  instance.child_num = 0
  instance.ent_count = 0
  instance.fill = 'line'
  instance.action_queue = {}
  instance.color = {0, 0, 0}
  instance.been_divided = false
  return instance
end

function Node:set(x, y, w, h, lvl)
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.lvl = lvl
end

for i = 1, 1 do
  table.insert(Node.Pool, Node:new(0, 0, 0, 0, 0))
end

function Node.allocate_node(x, y, w, h, lvl)
  local node = table.remove(Node.Pool)
  if node then 
    node:set(x, y, w, h, lvl)
    print(node.id)
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


function Node:is_root()
  return self.lvl == 0
end

function Node:has_entities()
  return #self.entities > 0
end

function Node:has_children()
  return #self.children > 0
end

function Node:is_empty()
  return not self:is_root() and not self:has_children()
end

function Node:is_lowest_level_node()
  return  not self:has_children()
end

function Node:is_mouse_in_bounds()
  return self:is_in_bounds(CURSOR)
end

function Node:loop_through_children(function_name, ...)
  for _, child_node in ipairs(self.children) do
    child_node[function_name](child_node, ...)
  end
end

function Node:loop_through_entities(function_name, ...)
  for _, entity in ipairs(self.entities) do
    entity[function_name](entity, ...)
  end
end

function Node:clear_action_queue()
  self.action_queue = {}
end
function Node:add_action_to_queue(action)
  table.insert(self.action_queue, action)
end

function Node:are_actions()
  return #self.action_queue > 0
end

function Node:take_action()
  if self:are_actions() then
    for idx, action in ipairs(self.action_queue) do
      action(self)
    end
  end
  self:clear_action_queue()
end


function Node:is_point_in_bounds(x, y)
  return g.is_point_in_rect(x, y, self.x, self.y, self.w, self.h)
end

function Node:is_rect_in_bounds(x, y, w, h)
  return g.is_rect_in_rect(x, y, w, h, self.x, self.y, self.w, self.h)
end

function Node:is_circle_in_bounds(cX, cY, cR)
  return g.is_circ_in_rect(cX, cY, cR,self.x, self.y, self.w, self.h)
end

function Node:is_in_bounds(item)
  if item.e_type == 'point' then
   return self:is_point_in_bounds(item:bound_check_info())
  elseif item.e_type == 'rectangle' then
    return self:is_rect_in_bounds(item:bound_check_info()) 
  elseif item.e_type == 'circle' then
    return self:is_circle_in_bounds(item:bound_check_info())
  else
    print('there is no e_type')
  end
end

function Node:childen_are_empty()
  local entity_count = 0
  for _, child_node in ipairs(self.children) do
    if child_node:has_entities() then
      entity_count = entity_count + #child_node.entities
    end
  end
  return entity_count < 5
end

function Node:all_descendants_are_empty()
  for _, child in ipairs(self.children) do
    if child:childen_are_empty() then
      return false
    end
    if not child:all_descendants_are_empty() then
      return false
    end
  end
  return true
end

function Node:has_entity_space()
  return #self.entities < 5
end

function Node:total_child_entities()
  local entity_count = 0
  for _, child_node in ipairs(self.children) do
    if child_node:has_entities() then
      entity_count = entity_count + #child_node.entities
    end
  end
  return entity_count
end

function Node:find_valid_node(entity)
  if self:is_in_bounds(entity) then
    if self:has_children() then
      for _, child_node in ipairs(self.children) do
        child_node:find_valid_node(entity)
      end
      return
    end
    if self:is_lowest_level_node() then
      self:add_entity_to_node(entity)
    end 
  end
end

function Node:add_entity_to_node(entity)
  table.insert(self.entities, entity)
  local data = string.format([[
  Level %s
  ChildCount %d
  EntityCount %s
  ]], self.lvl, #self.children, #self.entities)
  self.ent_count = #self.entities
end

function Node:remove_entity_from_node()
  for i = #self.entities, 1, -1 do
    if self.entities[i].to_delete then
      print('removing')
      table.remove(self.entities, i)
      self.ent_count = #self.entities
    end
  end
end

function Node:pass_entity_to_child(child_node)
  for _, entity in ipairs(self.entities) do
    child_node:find_valid_node(entity)
  end
end

function Node:divide()
  print('start divide')
  local x1 = self.x
  local x2 = self.x + self.w/2
  local y1 = self.y 
  local y2 = self.y + (self.h/2)
  local child_w = self.w/2
  local child_h = self.h/2
  local child_lvl = self.lvl + 1

  local xM = {x1, x2}
  local yM = {y1, y2}
  
  local child_num = 0
  local test_count = self.ent_count
  for _, x in ipairs(xM) do
    for _, y in ipairs(yM) do
      child_num = child_num + 1
      local child_node = Node.allocate_node(x, y, child_w, child_h, child_lvl)
      self:pass_entity_to_child(child_node)
      child_node.child_num = child_num
      child_node.ent_count = #child_node.entities
      table.insert(self.children, child_node)
      print('add child ', child_num, #self.children)
    end
  end
  local duplicate_count = 0
  local duplicate_list = {}
  for _, child_node in ipairs(self.children) do
    for _, entity in ipairs(child_node.entities) do
      if value_in_list(duplicate_list, entity) then
        duplicate_count = duplicate_count + 1
      else
        table.insert(duplicate_list, entity)
      end
    end
  end
  print('number of duplicates: ', duplicate_count)
  print('start: ', test_count, 'end ', self:total_child_entities())
  print('end divide')
  self.been_divided = true
end

function value_in_list(list, value)
  for _, v in ipairs(list) do
    if v == value then
      return true
    end
  end
  return false
end

function Node:merge()
  print('merging', #self.children .. 'children', self:total_child_entities() .. 'entities')
  for _, child_node in ipairs(self.children) do
    for i = #child_node.entities, 1, -1 do
      table.insert(self.entities, table.remove(child_node.entities, i))
    end
    Node.release_node(child_node)
  end
  self.children = {}
end

function Node:update()
  if not self:is_lowest_level_node() and self:all_descendants_are_empty() then

    print('Merging Added to Queue: ', self:total_child_entities())
    self:add_action_to_queue(
      function(self)
        print('merger', self.been_divided)
        self:merge()
        self.ent_count = #self.entities
      end
      )
  elseif not self:has_entity_space() then
    print('Dividing Added to Queue: ', self.ent_count)
    self:add_action_to_queue(
      function(self)
        print('dividing', self.been_divided)
        self:divide()
        print('removing all entities')
        self.entities = {}
        self.ent_count = 0
      end
      )
  end
  self:take_action()
  if self:is_lowest_level_node() then
    self.id ="Lvl: " .. tostring(self.lvl) .. ' Chld: ' .. self.child_num .. '/4' .. ' Ent: ' .. self.ent_count
  end
  self:remove_entity_from_node()
  self:loop_through_children('remove_entity_from_node')
  self:loop_through_children('update')
end

function Node:draw()
  self:loop_through_entities('draw')
  self:loop_through_children('draw')
  love.graphics.setColor(1, 0 ,0)
  love.graphics.rectangle(self.fill, self.x, self.y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
  if self:is_lowest_level_node() then
    love.graphics.print(self.id or 'nil', self.x, self.y)
  end
end

function Node:mouse_handler(button)
  if not self:is_in_bounds(CURSOR) then 
    self:loop_through_entities('mouse_handler', button, {1, 1, 1})
  return
  end
  if self:is_lowest_level_node() then
    self:loop_through_entities('mouse_handler', button, {1, 0, 0})
  else
    self:loop_through_children('mouse_handler', button)
  end
end

return Node
