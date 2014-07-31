local entity = require 'classes.entity'
local world = require 'classes.world'
local gui = require 'classes.gui'
local save = require 'classes.save'
local utils = require 'libs.utils'

local Save = save.Save
local Mob = entity.Mob
local Player = entity.Player
local World = world.World
local Menu = gui.Menu
local Button = gui.Button

local version = "0.1.0"

global = {}
math.randomseed(os.time())

function love.load()
  global.save = Save:new()
  global.save:load()

  global.version = version

  global.fonts = {
    tiny = love.graphics.newFont('assets/fonts/superscript.ttf', 20),
    small = love.graphics.newFont('assets/fonts/superscript.ttf', 30),
    normal = love.graphics.newFont('assets/fonts/superscript.ttf', 50)}

  global.sounds = {
    shoot = love.audio.newSource('assets/sfx/shoot.wav', 'static'),
    explosion = love.audio.newSource('assets/sfx/explosion.wav', 'static'),
    music = love.audio.newSource('assets/sfx/music.mp3', 'stream')
  }

  if not global.save.content.sound then
    love.audio.setVolume(0)
  end
  global.sounds['music']:setLooping(true)
  love.audio.play(global.sounds['music'])

  love.graphics.setFont(global.fonts['normal'])

  -- Gamestate
  global.gamestate = "menu"

  ----------
  -- Menu --
  ----------
  global.menu = Menu:new(global)
  local play_callback = function ()
    -- World
    global.world = World:new(global)
    global.world:populate()
    global.world.start = true
    global.gamestate = "play"
  end
  local quit_callback = function ()
    love.event.quit()
  end
  global.menu:addButton(
    Button:new("Play", "play", global.fonts['small'], 100, 400, play_callback))
  global.menu:addButton(
    Button:new("Quit", "quit", global.fonts['small'], 100, 430, quit_callback))
  global.menu:addButton(
    Button:new(
      "Developed by socketubs",
      "about",
      global.fonts['tiny'],
      10, 570,
      function () utils.open_url('https://github.com/socketubs/invaders') end))
  local sound_button = Button:new("Sound: ", "sound", global.fonts['tiny'], 450, 570)
  sound_button.active = global.save.content.sound
  sound_button.text = "Sound: " .. (sound_button.active and "on" or "off")
  sound_button.callback = function (self)
    self.active = not self.active
    global.save.content.sound = self.active
    global.save:save()
    self.text = "Sound: " .. (self.active and "on" or "off")
    if not self.active then
      love.audio.setVolume(0)
    else
      love.audio.setVolume(1)
    end
  end
  global.menu:addButton(sound_button)
  -- End Menu --
end

function love.update(dt)
  if global.gamestate == "menu" then
    love.mouse.setVisible(true)
    global.menu:update(dt)
  elseif global.gamestate == "play" then
    if not love.window.hasFocus() then
      global.gamestate = "overlay"
    else
      love.mouse.setVisible(false)
      global.world:update(dt)
    end
  elseif global.gamestate == "overlay" then
    love.mouse.setVisible(true)
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

function love.keypressed(key, isrepeat)
  if global.gamestate == "play" or global.gamestate == "overlay" then
    global.world:keypressed(key, isrepeat)
  elseif global.gamestate == "menu" then
    if key == "escape" then
      love.event.quit()
    end
  end
end

function love.mousepressed(x, y)
  if global.gamestate == "menu" then
    global.menu:mousepressed(x, y)
  elseif global.gamestate == "overlay" then
    global.world:mousepressed(x, y)
  end
end
