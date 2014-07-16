local class = require 'libs/middleclass'
local Tserial = require 'libs/Tserial'
local utils = require 'libs/utils'

local gui = require 'classes/gui'
local entity = require 'classes/entity'
local player = require 'classes/player'

local Mob = entity.Mob
local Player = player.Player
local Menu = gui.Menu
local Button = gui.Button

-- World
local World = class('World')
function World:initialize(global)
  self.global = global
  self.overlay = Menu:new(global)
  self.mobs = {}
  self.player = nil
  self.color = {29, 30, 26, 255}
  self.ground_color = {255, 255, 255, 255}
  self.width = 600
  self.ground = 550
  self.height = 600
  self.stop = false
  self.win = false
  self.border = 20
  self.elapsed_time = 0

  -- Level settings
  self.score = 0
  self.speed_step = 1
  self.mob_number = 35
  -- self.mob_number = 0
  self.mob_speed = 60
  self.mob_score = 50

  self.directions = {"left", "down", "right", "down"}
  self.direction = 1
  self.direction_step = 0

  self.overlay:addButton(
    Button:new(
      "Resume",
      "resume",
      global.fonts['small'],
      250,
      300,
      function() global.gamestate = "play" end))
  self.overlay:addButton(
    Button:new(
      "Menu",
      "menu",
      global.fonts['small'],
      250,
      330,
      function() global.gamestate = "menu" end))
  self.overlay:addButton(
    Button:new(
      "Quit",
      "quit",
      global.fonts['small'],
      250,
      360,
      function() love.event.quit() end))
  self.overlay.background_color = {0, 0, 0, 200}
end
function World:populate()
  -- Player
  self.player = Player:new(self.global)
  self.player.score = 0
  self.player.total_shots = 0
  -- Mobs
  local x_offset = 50
  local y_offset = 70
  local column = 1
  for i = 1, self.mob_number do
    local mob = Mob:new(self.global)
    mob.speed = self.mob_speed
    mob.score = self.mob_score
    mob.x = column * (mob.width + x_offset)
    if mob.x > self.width - (self.border * 2) then
      column = 1
      y_offset = y_offset + mob.width
      mob.x = column * (mob.width + x_offset)
    end
    mob.y = mob.height + y_offset
    mob.color = {0, 255, 255, 255}
    self:addEntity(mob)
    column = column + 1
  end
end
function World:addEntity(entity)
  table.insert(self.mobs, entity)
end
function World:draw()
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", 0, 0, self.width, self.height)

  love.graphics.setColor(self.ground_color)
  love.graphics.rectangle("fill", 0, self.ground, self.width, self.height)

  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.setFont(self.global.fonts['tiny'])
  love.graphics.print(
    'Score: ' .. self.player.score .. '  ' ..
    'Best: ' .. self.global.save.score .. '  ' ..
    'Shots: ' .. self.player.total_shots .. '  ',
    10,
    self.height - 35)

  love.graphics.setColor(255, 255, 255, 255)

  if self.loose then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('You loose!', 10, 20)
    love.graphics.setColor(self.color)
  end

  if self.win then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(self.global.fonts['normal'])
    love.graphics.print('You win!', 100, 200)
    love.graphics.setFont(self.global.fonts['tiny'])
    local msg = 'Total score: ' .. self.player.score ..
      '-' .. self.player.total_shots .. 'x2' ..
      '-' .. math.floor(self.elapsed_time) ..
      '=' .. self.total_score .. '!'
    love.graphics.print(msg, 100, 250)
    love.graphics.setColor(self.color)
  end

  -- Mobs
  for k, v in pairs(self.mobs) do
    v:draw()
  end
  -- Player
  self.player:draw()

  if self.global.gamestate == "overlay" then
    self.overlay:draw()
  end
end
function World:getBorderMobs()
  local left_mob = self.mobs[1]
  local right_mob = self.mobs[1]

  for k, v in pairs(self.mobs) do
    if v.x > right_mob.x then
      right_mob = v
    end
    if v.x < left_mob.x then
      left_mob = v
    end
  end
  return left_mob, right_mob
end
function World:update(dt)
  if self.global.gamestate == "overlay" then
    self.overlay:update(dt)
    return
  end

  if self.loose or self.win then
    return
  end

  -- Mobs
  local left, right = self:getBorderMobs()
  -- Touch left
  if left and left.x <= self.border and (self.direction == 1 or self.direction == 2) then
    if self.direction + 1 > table.getn(self.directions) then
      self.direction = 1
    else
      self.direction = self.direction + 1
    end
  -- Touch right
  elseif right and (right.x + right.width >= self.width - self.border) and (self.direction == 3 or self.direction == 4) then
    if self.direction + 1 > table.getn(self.directions) then
      self.direction = 1
    else
      self.direction = self.direction + 1
    end
  end

  for k, v in pairs(self.mobs) do
    v:update(dt, self.directions[self.direction])
    -- Check if entity have shots
    if v.shots then
      -- Interate on all entity shots
      for kk, shot in pairs(v.shots) do
        if self.player:collide(shot) then
          self.loose = true
        end
      end
    end
  end

  -- Player
  self.player:update(dt)
  if self.player.shots then
    for k, shot in pairs(self.player.shots) do
        --- Interate on all entities
        for kk, v in pairs(self.mobs) do
          if not v.dead and v:collide(shot) then
            -- table.remove(self.mobs, kk)
            v.dead = true
            table.remove(self.player.shots, k)
            self.player.score = self.player.score + v.score
            love.audio.play(self.global.sounds['explosion'])
            -- Change mobs speed
            for kk, vv in pairs(self.mobs) do
              vv.speed = vv.speed + self.speed_step
            end
           end
        end
      end
  end

  -- Increment elapsed time
  self.elapsed_time = self.elapsed_time + dt

  local count = 0
  for k, v in ipairs(self.mobs) do
    if not v.dead then
      count = count + 1
    end
  end
  if (count == 0) then
    self.win = true
    self.total_score = self.player.score - self.player.total_shots * 2 - math.floor(self.elapsed_time)
    if self.total_score < 0 then
      self.total_score = 0
    end
    local save = {}
    save.score = self.total_score
    save.time = self.elapsed_time
    save.shots = self.player.total_shots
    love.filesystem.write("invaders.sav", Tserial.pack(save))
    self.global.save = Tserial.unpack(love.filesystem.read("invaders.sav"))
  end
end
function World:keyreleased(key)
  if not self.loose and not self.win then
    self.player:keyreleased(key)
  end
end
function World:mousepressed(x, y)
  self.overlay:mousepressed(x, y)
end

-- Exports
local exports = {}
exports.World = World

return exports
