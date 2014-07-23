local class = require 'libs/middleclass'
local gui = require 'classes/gui'
local AnAL = require('libs/AnAL')

local Menu = gui.Menu
local Button = gui.Button

-- Entity
local Entity = class('Entity')
function Entity:initialize()
  self.height = 30
  self.width = 15
  self.x = 300
  self.y = 450 - self.height
  self.speed = 100
  self.color = {255, 255, 255, 255}
end
function Entity:draw()
  if self.animation then
    love.graphics.setColor(self.color)
    self.animation:draw(self.x, self.y)
  elseif self.image and self.quad then
    love.graphics.setColor(self.color)
    love.graphics.draw(self.image, self.quad, self.x, self.y)
  else
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  end
end
function Entity:addImage(image_path, width, height, delay, nbFrames)
  local nbFrames = nbFrames or 0
  self.image = love.graphics.newImage(image_path)
  self.animation = newAnimation(self.image, width, height, delay, nbFrames)
  self.width = width
  self.height = height
  self.quad = love.graphics.newQuad(0, 0, width, height, width, height)
end
function Entity:collide(entity)
  return  self.x < entity.x + entity.width and
          entity.x < self.x + self.width and
          self.y < entity.y + entity.height and
          entity.y < self.y + self.height
end
function Entity:update(dt)
  if self.animation then
    self.animation:update(dt)
  end
end

-- Shot
local Shot = class('Shot', Entity)

-- Mob
local Mob = class('Mob', Entity)
function Mob:initialize(global)
  Entity.initialize(self, global)

  self.speed = 20
  self.shots = {}

  self.dead = false
  self.dead_counter = 0
  self.dead_timer = 0.1

  self.shot_counter = 0
  self.shot_delay = 3
  self:addImage("assets/images/mob.png", 24, 18, 0.5, 2)
end
function Mob:setDead(value)
  self.dead = value
  if self.animation and self.animation:getCurrentFrame() ~= 3 then
    self.animation:addFrame(48, 0, 24, 18, 0.5)
    self.animation:seek(3)
  end
end
function Mob:update(dt, direction)
  -- Update dead counter if dead
  if self.dead then
    self.dead_counter = self.dead_counter + dt
  -- Or just update entity
  else
    Entity.update(self, dt)
  end

  for k, v in pairs(self.shots) do
    v:update(dt)
    v.y = v.y + v.speed * dt
    if v.y + v.height > global.world.ground then
      table.remove(self.shots, k)
    end
  end

  if self.dead then
    return
  end

  if direction == "right" then
    self.x = self.x + self.speed * dt
  elseif direction == "left" then
    self.x = self.x - self.speed * dt
  elseif direction == "down" then
    self.y = self.y + (self.speed * 7) * dt
  end

  self.shot_counter = self.shot_counter + dt

  if self.shot_counter >= self.shot_delay then
    if math.random(1, 4) == 1 then
      self:shot()
    end
    self.shot_counter = 0
  end

  if self.y + self.height >= 550 then
    global.world.loose = true
  end
end
function Mob:shot()
  local shot = Shot:new()
  shot:addImage('assets/images/shot.png', 6, 12, 0.3, 0)
  shot.x = self.x + self.width / 2
  shot.y = self.y
  table.insert(self.shots, shot)
end
function Mob:draw()
  -- If not dead of dead_counter drawing not reach
  if not self.dead or (self.dead and self.dead_counter < self.dead_timer) then
    Entity.draw(self)
  end
  for k, v in pairs(self.shots) do
    v:draw()
  end
end

-- Exports
local exports = {}
exports.Mob = Mob
exports.Shot = Shot
exports.Entity = Entity

return exports
