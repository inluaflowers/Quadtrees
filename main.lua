SCREEN = {
  WIDTH = 1000,
  HEIGHT = 1000
}

ENTITIES_COUNT = 0
math.randomseed(os.time())

local Quadtree = require('quadtree')
local Entity = require('entity')
local Node = require('node')
local g = require('geometry')
local Cursor = require('cursor')

local spawn_timer = 0

local function random_coordinate(axis)
  return math.random(0, SCREEN[axis])
end

local function random_dimension()
  return math.random(5, 20)
end

local entity_count = 0

ROOT = Node.allocate_node(0, 0, SCREEN.WIDTH, SCREEN.HEIGHT, 0)

local function add_entity()
  local eX = random_coordinate('WIDTH')
  local eY = random_coordinate('HEIGHT')
  local eW = random_dimension()
  local eH = random_dimension()
  local eR = random_dimension()

  if entity_count == 0 then
    entity = Entity:newRectangle(eX, eY, eW, eH)
    entity_count = 1
  elseif entity_count == 1 then
    entity = Entity:newCircle(eX, eY, eR)
    entity_count = 0
  end
  ENTITIES_COUNT = ENTITIES_COUNT + 1
  ROOT:add_action_to_queue(function(self)
    self:find_valid_node(entity)
  end)
  print(ROOT:total_child_entities(), ENTITIES_COUNT)
end

function love.load()
  CURSOR = Cursor:new()
end

function love.update(dt)
  CURSOR:update()
  ROOT:update()
end

function love.draw()
  ROOT:draw()
end

function love.keypressed(key)
  if key == "space" then

    add_entity(ROOT)
  end
end

function love.mousepressed(_, _, button)
  ROOT:mouse_handler(button)
end