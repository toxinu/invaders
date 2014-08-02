local scores

function scores()
  love.graphics.setColor(29, 30, 26, 255)
  love.graphics.rectangle("fill", 0, 0, 600, 600)

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(global.fonts['normal'])
  love.graphics.print('Highscores', 100, 100)

  local x = 100
  local y_offset = 150
  local y = 20
  love.graphics.setFont(global.fonts['tiny'])
  for k, score in ipairs(global.save:getOrderedScores()) do
    local msg = k .. '. ' .. score.score ..
      ' (' .. os.date('%c', score.date) .. ')'
    love.graphics.print(msg, x, y * k + y_offset)
  end

  love.graphics.print('Press escape to return to menu.', 10, 570)
end

return scores
