local class = require 'libs.middleclass'
local shapes = require 'libs.hardoncollider.shapes'

-- Build
local Build = class('Build')
function Build:initialize(x, y)
  self.x = x
  self.y = y
  self.color = {255, 255, 255, 255}
  self.bitmap = {
    0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
  }
  self.lineLength = 17
  self.explosionRadius = 3
  self.scale = 5
  self.scaledBitMap = self:getScaledBitMap()

  local x, y = self:getScaledBitMapPoint(table.getn(self.scaledBitMap))
  self.height = x - self.x
end
function Build:getScaledBitMap()
  local scaledArray = {}
  for k, v in ipairs(self.bitmap) do
    local c = 0
    while (c < self.scale) do
      table.insert(scaledArray, v)
      c = c + 1
    end
  end
  return scaledArray
end
function Build:getScaledBitMapPoint(i)
  local x = (i - 1) % (self.lineLength * self.scale)
  local y = ((i - 1) - x) / (self.lineLength)
  x = x + self.x
  y = y + self.y
  return x, y
end
function Build:draw()
  love.graphics.setColor(self.color)
  for k, v in ipairs(self.scaledBitMap) do
    local x, y = self:getScaledBitMapPoint(k)
    if v == 1 then
      love.graphics.rectangle('fill', x, y, 1 * self.scale, 1 * self.scale )
    end
  end
end
function Build:explode(x, y)
  local circleShape = shapes.newCircleShape(
    x, y, self.explosionRadius * (self.scale / 2))
  love.graphics.setColor(255, 0, 255, 255)
  circleShape:draw()
  for k, v in ipairs(self.scaledBitMap) do
    if v == 1 then
      if circleShape:contains(self:getScaledBitMapPoint(k)) then
        self.scaledBitMap[k] = 0
      end
    end
  end
end
function Build:collide(entity)
  local entityShape = shapes.newPolygonShape(
    entity.x, entity.y,
    entity.x + entity.width, entity.y,
    entity.x + entity.width, entity.y + entity.height,
    entity.x, entity.y + entity.height)

  for k, v in ipairs(self.scaledBitMap) do
    if v == 1 then
      local x, y = self:getScaledBitMapPoint(k)
      if entityShape:contains(x, y) then
        self:explode(x, y)
        return true
      end
    end
  end
  return false
end

local exports = {}
exports.Build = Build
return exports
