local classes = require 'classes'
local gui = require 'gui'

local Mob = classes.Mob
local World = classes.World
local Player = classes.Player

local Menu = gui.Menu
local Button = gui.Button


function love.load()
  global = {}
  global.fonts = {
    normal = love.graphics.newFont('assets/fonts/superscript.ttf', 50)}

  love.window.setTitle('Invaders by socketubs')
  love.graphics.setFont(global.fonts['normal'])

  -- Gamestate
  -- menu/play
  global.gamestate = "menu"

  -- Menu
  global.menu = Menu:new(global)
  local play_callback = function ()
    -- World
    global.world = World:new()
    global.world:populate()
    global.gamestate = "play"
  end
  local exit_callback = function ()
    love.event.quit()
  end
  global.menu:addButton(
    Button:new("Play", "play", global.fonts['normal'], 100, 400, play_callback))
  global.menu:addButton(
    Button:new("Exit", "exit", global.fonts['normal'], 100, 450, exit_callback))
end

function love.update(dt)
  if love.keyboard.isDown("escape") then
    if global.gamestate == "play" then
      global.gamestate = "overlay"
    else
      global.gamestate = "menu"
    end
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
  end
end
