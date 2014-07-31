local class = require 'libs.middleclass'

local entity = require 'classes.entity'

local Entity = entity.Entity
local Shot = entity.Shot

-- Player
local Player = class('Player', Entity)
function Player:initialize()
  Entity.initialize(self)
  self.x = 285
  self.y = 520
  self.speed = 150
  self.shots = {}
  self.score = 0
  self.total_shots = 0
  self.life_remaining = 0

  self.untouchable = false
  self.untouchable_counter = 0
  self.untouchable_time = 3
  self.untouchable_blink_delay = 0.2
  self.untouchable_blink_counter = 0
  self.untouchable_blink_color = global.world.color
  self.initial_color = self.color

  self:addImage("assets/images/player.png", 29, 18, 0.1)
end
function Player:touched()
  self.untouchable = true
  self.untouchable_counter = 0
  self.untouchable_blink_counter = 0
  self.life_remaining = self.life_remaining - 1 or 0
end
function Player:isDead()
  if self.life_remaining <= 0 then
    return true
  end
  return false
end
function Player:isTouchable()
  if self.untouchable and self.untouchable_counter <= self.untouchable_time then
    return false
  end
  return true
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
  love.audio.play(global.sounds['shoot'])
end
function Player:keypressed(key)
  if key == " " then
    self:shot()
  end
end
function Player:swapTouchableColors()
  if self.color == self.untouchable_blink_color then
    self.color = self.initial_color
  else
    self.color = self.untouchable_blink_color
  end
end
function Player:update(dt)
  Entity.update(self, dt)

  if self.untouchable and self.untouchable_counter <= self.untouchable_time then
    if self.untouchable_blink_counter > self.untouchable_blink_delay then
      self.untouchable_blink_counter = 0
      self:swapTouchableColors()
    end
    self.untouchable_blink_counter = self.untouchable_blink_counter + dt
    self.untouchable_counter = self.untouchable_counter + dt
  else
    self.untouchable = false
    self.untouchable_counter = 0
    self.untouchable_blink_counter = 0
    self.color = self.initial_color
  end

  if love.keyboard.isDown("left") then
    local x = self.x - self.speed * dt
    if x > 0 then
      self.x = x
    end
  elseif love.keyboard.isDown("right") then
    local x = self.x + self.speed * dt
    if x + self.width < global.world.width then
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
  --
  Entity.draw(self)
  for k, v in pairs(self.shots) do
    v:draw()
  end
end

local exports = {}
exports.Player = Player

return exports
