local class = require 'libs/middleclass'
local gui = require 'classes/gui'

local Menu = gui.Menu
local Button = gui.Button

-- Entity
local Entity = class('Entity')
function Entity:initialize(global)
  self.global = global
  self.height = 30
  self.width = 15
  self.x = 300
  self.y = 450 - self.height
  self.speed = 100
  self.color = {255, 255, 0, 255}
end
function Entity:draw()
  if self.image and self.quad then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.image, self.quad, self.x, self.y)
  else
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(255, 255, 255, 255)
  end
end
function Entity:addImage(image_path)
  self.image = love.graphics.newImage(image_path)
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
  self.quad = love.graphics.newQuad(
    0, 0,
    self.image:getWidth(),
    self.image:getHeight(),
    self.image:getWidth(),
    self.image:getHeight())
end
function Entity:collide(entity)
  return  self.x < entity.x + entity.width and
          entity.x < self.x + self.width and
          self.y < entity.y + entity.height and
          entity.y < self.y + self.height
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
  self.show_counter = 0
  self:addImage("assets/images/mob.png")
end
function Mob:randomMove(dt)
  -- Delete this shit
  local horizontal_move = math.random(1, 2)
  if horizontal_move == 1 then
    self.x = self.x - self.speed * dt
  elseif horizontal_move == 2 then
    self.x = self.x + self.speed * dt
  end
  local vertical_move = math.random(1, 2)
  if vertical_move == 1 then
    self.y = self.y - self.speed * dt
  elseif vertical_move == 2 then
    self.y = self.y + self.speed * dt
  end

  self.y = self.y + self.speed * dt
end
function Mob:update(dt, direction)
  for k, v in pairs(self.shots) do
    v.y = v.y + v.speed * dt
    if v.y + v.height > self.global.world.ground then
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

  self.show_counter = self.show_counter + dt

  if self.show_counter >= 2 then
    if math.random(1, 4) == 1 then
      self:shot()
    end
    self.show_counter = 0
  end

  if self.y + self.height >= 550 then
    self.global.world.loose = true
  end
end
function Mob:shot()
  local shot = Shot:new()
  shot.color = {255, 0, 0, 255}
  shot.height = 8
  shot.width = 3
  shot.x = self.x + self.width / 2
  shot.y = self.y
  table.insert(self.shots, shot)
end
function Mob:draw()
  if not self.dead then
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
