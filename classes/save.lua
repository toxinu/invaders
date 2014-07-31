local class = require 'libs.middleclass'
local Tserial = require 'libs.Tserial'


local Save = class('Save')
function Save:initialize()
  self.filePath = "invaders.lua"
  self.defaultSave = {
    score=0,
    sound=true
  }

  if not love.filesystem.exists(self.filePath) then
    love.filesystem.write(self.filePath, Tserial.pack(self.defaultSave))
    self.content = self.defaultSave
  end
end
function Save:load()
    self.content = Tserial.unpack(love.filesystem.read(self.filePath))
end
function Save:save()
  love.filesystem.write(self.filePath, Tserial.pack(self.content))
end

local exports = {}
exports.Save = Save
return exports
