local M = {}

-- Constants
if love.getVersion() < 11 then
  COLORCOST = 255
else
  COLORCOST = 1
end

-- Private fields

-- Set dimensions
local initial_w = 800
local initial_h = 450
local current_w = initial_w
local current_h = initial_h
local previous_w = current_w
local previous_h = current_h

-- Camera scaling due to window size
local window_scale = initial_w / 800

-- Camera scaling due to in-game reasons
local game_scale = 1


-- Used when zooming in out due to in game reasons or window resize
-- Don't set total_scale. Calculate through this
function M.calculate_total_scale(table)

  if table.resized then
    window_scale = window_scale * (current_w / previous_w)
  end
  game_scale = table.game_scale or game_scale
  return window_scale * game_scale

end

-- Finds appropriate gamera window dimensions after resize.
-- Returned values are to be used in gamera:setWindow
function M.resize_calculate_dimensions( w, h )

  -- Calculate new dimensions
  local new_w = w
  local new_h = new_w * (current_h / current_w)
  if new_h > h then
    new_h = h
    new_w = new_h * (current_w / current_h)
  end

  -- Determine unused screen area (to find display window offset)
  local dead_space_w = w - new_w
  local dead_space_h = h - new_h

  -- Store previous dimensions
  previous_w = current_w
  previous_h = current_h

  -- Set current dimensions to new dimensions
  current_w = new_w
  current_h = new_h

  return dead_space_w * 0.5, dead_space_h * 0.5, new_w, new_h

end

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
