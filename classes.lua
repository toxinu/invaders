local class = require 'libs/middleclass'
local gui = require 'gui'

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

-- Player
local Player = class('Player', Entity)
function Player:initialize(global)
  Entity.initialize(self, global)
  self.x = 200
  self.y = 520
  self.speed = 150
  self.shots = {}

  self:addImage("assets/images/player.png")
end
function Player:shot()
  local shot = Shot:new()
  shot.color = {255, 255, 255, 255}
  shot.height = 8
  shot.width = 2
  shot.x = self.x + self.width / 2
  shot.y = self.y
  table.insert(self.shots, shot)
end
function Player:keyreleased(key)
  if key == " " then
    self:shot()
  end
end
function Player:update(dt)
  if love.keyboard.isDown("left") then
    self.x = self.x - self.speed * dt
  elseif love.keyboard.isDown("right") then
    self.x = self.x + self.speed * dt
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

-- Mob
local Mob = class('Mob', Entity)
function Mob:initialize(global)
  Entity.initialize(self, global)
  self.speed = 40

  self:addImage("assets/images/mob.png")
end
function Mob:randomMove(dt)
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
function Mob:update(dt)
  -- self.y = self.y + self.speed * dt
  self:randomMove(dt)

  if self.y + self.height >= 550 then
    self.world.loose = true
  end
end

-- World
local World = class('World')
function World:initialize(global)
  self.global = global
  self.overlay = Menu:new(global)
  self.entities = {}
  self.color = {255, 255, 255, 255}
  self.width = 800
  self.ground = 550
  self.height = 600
  self.stop = false
  self.win = false

  self.overlay:addButton(
    Button:new(
      "Resume",
      "resume",
      global.fonts['normal'],
      200,
      400,
      function() global.gamestate = "play" end))
  self.overlay:addButton(
    Button:new(
      "Quit",
      "quit",
      global.fonts['normal'],
      200,
      450,
      function() love.event.quit() end))
  self.overlay.background_color = {255, 255, 255, 40}
end
function World:populate()
  -- Player
  self:addEntity(Player:new(self.global.world))
  -- Mobs
  local x_offset = 20
  local y_offset = 50
  local column = 1
  for i = 1, 24 do
    local mob = Mob:new(self.global.world)
    mob.width = 40
    mob.height = 20
    mob.x = column * (mob.width + x_offset)
    if mob.x > self.width - mob.width then
        column = 1
        y_offset = y_offset + mob.width
        mob.x = column * (mob.width + x_offset) + x_offset
    end
    mob.y = mob.height + y_offset
    mob.color = {0, 255, 255, 255}
    self:addEntity(mob)
    column = column + 1
  end
end
function World:addEntity(entity)
  table.insert(self.entities, entity)
end
function World:draw()
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", 0, self.ground, self.width, self.height)
  love.graphics.setColor(255, 255, 255, 255)

  if self.loose then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('You loose!', 10, 20)
    love.graphics.setColor(0, 0, 0, 255)
    return
  end

  if self.win then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('You win!', 10, 20)
    love.graphics.setColor(0, 0, 0, 255)
    return
  end

  for k, v in pairs(self.entities) do
    v:draw()
  end

  if self.global.gamestate == "overlay" then
    self.overlay:draw()
  end
end
function World:update(dt)
  if self.global.gamestate == "overlay" then
    self.overlay:update(dt)
    return
  end

  -- Interate on all entities
  for k, v in pairs(self.entities) do
    v:update(dt)
    -- Check if entity have shots
    if v.shots then
      -- Interate on all entity shots
      for kk, shot in pairs(v.shots) do
        --- Interate on all entities
        for kkk, vv in pairs(self.entities) do
          if kkk ~= k then
            if vv:collide(shot) then
              table.remove(self.entities, kkk)
              table.remove(v.shots, kk)
            end
          end
        end
      end
    end
  end
  if (table.getn(self.entities) - 1 == 0) then
    self.win = true
  end
end
function World:keyreleased(key)
  for k, v in pairs(self.entities) do
    if v.keyreleased then
      v:keyreleased(key)
    end
  end
end
function World:mousepressed(x, y)
  self.overlay:mousepressed(x, y)
end

-- Exports
local exports = {}
exports.Mob = Mob
exports.World = World
exports.Player = Player
exports.Entity = Entity

return exports
