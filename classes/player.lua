local class = require 'libs/middleclass'

local entity = require 'classes/entity'

local Entity = entity.Entity
local Shot = entity.Shot

-- Player
local Player = class('Player', Entity)
function Player:initialize(global)
  Entity.initialize(self, global)
  self.x = 270
  self.y = 520
  self.speed = 150
  self.shots = {}

  self:addImage("assets/images/player.png", 29, 18, 0.1)
end
function Player:shot()
  local shot = Shot:new()
  self.total_shots = self.total_shots + 1
  shot.color = {255, 255, 255, 255}
  shot.height = 8
  shot.width = 3
  shot.x = self.x + self.width / 2
  shot.y = self.y
  table.insert(self.shots, shot)
  love.audio.play(self.global.sounds['shoot'])
end
function Player:keypressed(key)
  if key == " " then
    self:shot()
  end
end
function Player:update(dt)
  Entity.update(self, dt)

  if love.keyboard.isDown("left") then
    local x = self.x - self.speed * dt
    if x > 0 then
      self.x = x
    end
  elseif love.keyboard.isDown("right") then
    local x = self.x + self.speed * dt
    if x + self.width < self.global.world.width then
      self.x = x
    end
  end

  for k, v in pairs(self.shots) do
    v.y = v.y - v.speed * dt
    if v.y < 0 then
      table.remove(self.shots, k)
    end
  end
end
function Player:draw()
  Entity.draw(self)
  for k, v in pairs(self.shots) do
    v:draw()
  end
end

local exports = {}
exports.Player = Player

return exports
