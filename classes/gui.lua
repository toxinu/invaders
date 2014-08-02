local class = require 'libs.middleclass'

-- Button
local Button = class('Button')
function Button:initialize(text, slug, font, x, y, callback)
  self.text = text
  self.slug = slug
  self.font = font
  self.x = x
  self.y = y
  self.callback = callback
  self:unhover()
end
function Button:draw()
  love.graphics.setFont(self.font)
  love.graphics.setColor(self.color)
  love.graphics.print(self.text, self.x, self.y)
end
function Button:getWidth()
  return self.font:getWidth(self.text)
end
function Button:getHeight()
  return self.font:getHeight(self.text)
end
function Button:pressed()
  return self.callback(self)
end
function Button:hover()
  self.color = {58, 102, 80, 255}
end
function Button:unhover()
  self.color = {255, 255, 255, 255}
end

-- Menu
local Menu = class('Menu')
function Menu:initialize()
  self.buttons = {}
  self.background_color = {29, 30, 26, 255}
end
function Menu:addButton(button)
  table.insert(self.buttons, button)
end
function Menu:draw()
  if table.getn(self.background_color) == 4 then
    love.graphics.setColor(self.background_color)
    love.graphics.rectangle("fill", 0, 0, 600, 600)
  end
  for i, v in ipairs(self.buttons) do
    v:draw()
  end

  if global.gamestate == "menu" then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(global.fonts['normal'])
    love.graphics.print("Invaders!", 100, 300)
  elseif global.gamestate == "overlay" then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(global.fonts['normal'])
    love.graphics.print("-- Pause --", 150, 200)
  end
end
function Menu:update(dt)
  for i, button in ipairs(self.buttons) do
    if  love.mouse:getX() < button.x + button:getWidth() and
        button.x < love.mouse:getX() and
        love.mouse:getY() < button.y + button:getHeight() and
        button.y < love.mouse:getY() then
      button:hover()
    else
      button:unhover()
    end
  end
end
function Menu:mousepressed(x, y)
  for i, button in ipairs(self.buttons) do
    if  x < button.x + button:getWidth() and
        button.x < x and
        y < button.y + button:getHeight() and
        button.y < y then
      button:pressed()
    end
  end
end

local exports = {}
exports.Menu = Menu
exports.Button = Button
return exports
