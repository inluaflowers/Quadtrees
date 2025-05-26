local Quadtree = {}
Quadtree.__index = Quadtree

function Quadtree:new()
  local instance = setmetatable({}, self)
  return instance
end

return Quadtree