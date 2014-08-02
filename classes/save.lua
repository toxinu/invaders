local class = require 'libs.middleclass'
local Tserial = require 'libs.Tserial'


local Save = class('Save')
function Save:initialize()
  self.filePath = "invaders.lua"
  self.defaultSave = {
    scores={},
    sound=true
  }
  self.scoreToKeep = 20

  if not love.filesystem.exists(self.filePath) then
    love.filesystem.write(self.filePath, Tserial.pack(self.defaultSave))
    self.content = self.defaultSave
  else
    self:load()
  end

  self.bestScore = self:getBestScore()
end
function Save:load()
    self.content = Tserial.unpack(love.filesystem.read(self.filePath))
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
  if table.getn(self.content.scores) > 0 then
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
  table.sort(self.content.scores, compare)
  return self.content.scores
end

local exports = {}
exports.Save = Save
return exports
