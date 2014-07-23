local class = require 'libs/middleclass'
local shapes = require 'libs/hardoncollider.shapes'

-- Build
local Build = class('Build')
function Build:initialize(x, y)
  self.x = x
  self.y = y
  self.width = 80
  self.height = 50
  self.color = {255, 255, 255, 255}
  self.vertices = {
    20, 30,
    30, 20,
    60, 20,
    70, 30,
    70, 60,
    60, 60,
    60, 50,
    50, 40,
    40, 40,
    30, 50,
    30, 60,
    20, 60
  }
  self.shape = shapes.newPolygonShape(unpack(self.vertices))
  self.shape:move(self.x, self.y)
end
function Build:draw()
  love.graphics.setColor(self.color)
  love.graphics.translate(self.x, self.y)
  local triangles = love.math.triangulate(self.vertices)
  for k, v in pairs(triangles) do
    love.graphics.polygon('fill', v)
  end
  love.graphics.translate(-self.x, -self.y)
end
function Build:collide(entity)
  local entityShape = shapes.newPolygonShape(
    entity.x, entity.y,
    entity.x + entity.width, entity.y,
    entity.x + entity.width, entity.y + entity.height,
    entity.x, entity.y + entity.height)
  if self.shape:collidesWith(entityShape) then
    return true
  else
    return false
  end
end

local exports = {}
exports.Build = Build
return exports
