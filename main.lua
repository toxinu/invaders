local entity = require 'classes/entity'
local world = require 'classes/world'
local gui = require 'classes/gui'
local Tserial = require 'libs/Tserial'
local utils = require 'libs/utils'

local Mob = entity.Mob
local Player = entity.Player
local World = world.World
local Menu = gui.Menu
local Button = gui.Button


function love.load()
  love.window.setMode(600, 600, {vsync=true, resizable=false})
  love.filesystem.setIdentity("Invaders")

  global = {}
  global.fonts = {
    tiny = love.graphics.newFont('assets/fonts/superscript.ttf', 20),
    small = love.graphics.newFont('assets/fonts/superscript.ttf', 30),
    normal = love.graphics.newFont('assets/fonts/superscript.ttf', 50)}

  global.sounds = {
    shoot = love.audio.newSource('assets/sfx/shoot.wav', 'static'),
    explosion = love.audio.newSource('assets/sfx/explosion.wav', 'static'),
    music = love.audio.newSource('assets/sfx/music.mp3', 'stream')
  }

  global.sounds['music']:setLooping(true)
  love.audio.play(global.sounds['music'])

  love.window.setTitle('Invaders by socketubs')
  love.graphics.setFont(global.fonts['normal'])

  -- Save
  if not love.filesystem.exists("invaders.sav") then
    love.filesystem.write("invaders.sav", Tserial.pack({score=0}))
  end
  global.save = Tserial.unpack(love.filesystem.read("invaders.sav"))

  -- Gamestate
  global.gamestate = "menu"

  -- Menu
  global.menu = Menu:new(global)
  local play_callback = function ()
    -- World
    global.world = World:new(global)
    global.world:populate()
    global.world.start = true
    global.gamestate = "play"
  end
  local exit_callback = function ()
    love.event.quit()
  end
  global.menu:addButton(
    Button:new("Play", "play", global.fonts['small'], 100, 400, play_callback))
  global.menu:addButton(
    Button:new("Exit", "exit", global.fonts['small'], 100, 430, exit_callback))
  global.menu:addButton(
    Button:new(
      "Developed by socketubs",
      "about",
      global.fonts['tiny'],
      10, 570,
      function () utils.open_url('https://github.com/socketubs/invaders') end))
end

function love.update(dt)
  if love.keyboard.isDown("escape") and global.gamestate == "play" then
      global.gamestate = "overlay"
  end
  if global.gamestate == "menu" then
    global.menu:update(dt)
  else
    global.world:update(dt)
  end
end

function love.draw()
  if global.gamestate == "menu" then
    global.menu:draw()

  else
    global.world:draw()
  end
end

function love.keyreleased(key)
  if global.gamestate == "play" then
    global.world:keyreleased(key)
  end
end

function love.mousepressed(x, y)
  if global.gamestate == "menu" then
    global.menu:mousepressed(x, y)
  elseif global.gamestate == "overlay" then
    global.world:mousepressed(x, y)
  end
end
