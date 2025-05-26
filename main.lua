SCREEN = {
  WIDTH = 1000,
  HEIGHT = 1000
}

math.randomseed(os.time())

local Quadtree = require('quadtree')
local Entity = require('entity')
local Node = require('node')

local spawn_timer = 0

local function randomCoordinates()
  local x, y = math.random(0, SCREEN.WIDTH), math.random(0, SCREEN.HEIGHT)
  return x, y
end

local function add_entity(ROOT, is_edge_case)
  if is_edge_case then
    entity = Entity:new(500, math.random(0, SCREEN.HEIGHT))
  else
    entity = Entity:new(randomCoordinates())
  end
  ROOT:find_valid_node(entity)

end

function love.load()
ROOT = Node.allocate_node(0, 0, SCREEN.WIDTH, SCREEN.HEIGHT, 0)
end


function love.update(dt)
  local mx, my = love.mouse.getPosition()
  ROOT:update(dt, mx, my)
end

function love.draw()
  ROOT:draw()
end

function love.keypressed(key)
  if key == "right" then
    add_entity(ROOT, true)
  end
  if key == "space" then
    add_entity(ROOT, false)
  end
end

function love.mousepressed(mx, my, button)
  if button == 1 then 
    ROOT:mousepressed(button, mx, my)
  end
end