local class = require 'libs.middleclass'
local Tserial = require 'libs.Tserial'


local Save = class('Save')
function Save:initialize()
  self.filePath = "invaders.lua"
  self.defaultSave = {
    scores={},
    sound=true
  }
  self.scoreToKeep = 15

  if not love.filesystem.exists(self.filePath) or
      love.filesystem.read(self.filePath) == '' then
    love.filesystem.write(self.filePath, Tserial.pack(self.defaultSave))
  end

  self:load()
  self.bestScore = self:getBestScore()
  self.orderedScores = self:getOrderedScores()
end
function Save:createNew()
  love.filesystem.write(self.filePath, Tserial.pack(self.defaultSave))
end
function Save:isValid(content)
  if content.sound == nil then
    return false
  elseif content.scores == nil then
    return false
  end
  return true
end
function Save:load()
  local content = Tserial.unpack(love.filesystem.read(self.filePath))
  if not self:isValid(content) then
    self:createNew()
    local content = Tserial.unpack(love.filesystem.read(self.filePath))
  end
  self.content = content
end
function Save:save()
  love.filesystem.write(self.filePath, Tserial.pack(self.content))
end
function Save:addScore(score)
  while table.getn(self.content.scores) >= self.scoreToKeep do
    table.remove(self.content.scores, self:getOldestScore())
  end
  local dt = os.date("*t")
  score.date = os.time(dt)
  table.insert(self.content.scores, score)
  self.bestScore = self:getBestScore()
  self.orderedScores = self:getOrderedScores()
end
function Save:getOldestScore()
  if table.getn(self.content.scores) > 0 then
    local oldestId = 1
    local oldest = self.content.scores[oldestId]
    for i, score in ipairs(self.content.scores) do
      if score.date < oldest.date then
        oldestId = i
        oldest = score
      end
    end
    return oldestId
  else
    return nil
  end
end
function Save:getBestScore()
  if self.content.scores and table.getn(self.content.scores) > 0 then
    local mostRecent = self.content.scores[1]
    for i, score in ipairs(self.content.scores) do
      if score.date > mostRecent.date then
        mostRecent = score
      end
    end
    return mostRecent
  else
    return {}
  end
end
function Save:getOrderedScores()
  function compare(a, b)
    return a.score > b.score
  end
  if self.content.scores then
    table.sort(self.content.scores, compare)
  end
  return self.content.scores
end

local exports = {}
exports.Save = Save
return exports
