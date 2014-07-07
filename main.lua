local classes = require 'classes'
local Mob = classes.Mob
local World = classes.World
local Player = classes.Player

function love.load()
    love.window.setTitle('Invaders by socketubs')
    font = love.graphics.newFont('assets/fonts/superscript.ttf', 50)
    love.graphics.setFont(font)

    -- World
    global = {}
    global.world = World:new()

    -- Player
    global.world:addEntity(Player:new(global.world))

    -- Mobs
    for i=1,8 do
        local mob = Mob:new(global.world)
        mob.width = 40
        mob.height = 20
        mob.x = i * (mob.width + 25) + 100
        mob.y = mob.height + 100
        mob.color = {0, 255, 255, 255}
        global.world:addEntity(mob)
    end
end

function love.update(dt)
    global.world:update(dt)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.draw()
    global.world:draw()
end

function love.keyreleased(key)
    global.world:keyreleased(key)
end
