local M = {}

-- Set drawing constants
if love.getVersion() < 11 then
  COLORCOST = 255
else
  COLORCOST = 1
end

SCALING = 1


function M.ToMainCanvas(canvas)
  canvas:renderTo(function()
    love.graphics.clear()
    love.graphics.rectangle("fill", 11, 11, 33, 33)
    love.graphics.setColor(COLORCOST, COLORCOST, 0, COLORCOST)
    love.graphics.rectangle("fill", 33, 33, 33, 33)
    -- draw stuff..
    love.graphics.scale(5)
    love.graphics.setColor(COLORCOST, COLORCOST, COLORCOST, COLORCOST)
    love.graphics.draw(playa, playax, playay)
  end)
end

return M
