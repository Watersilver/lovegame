local M = {}

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
function M.get_game_scale()
  return game_scale
end

local total_scale
function M.get_total_scale()
  return total_scale
end

-- Used when zooming in out due to in game reasons or window resize
-- Never set total_scale. Calculate through this
function M.calculate_total_scale(params)

  if params.resized then
    window_scale = window_scale * (current_w / previous_w)
  end
  game_scale = params.game_scale or game_scale
  total_scale = window_scale * game_scale

end

-- Finds appropriate gamera window dimensions after resize.
-- Returned values are to be used in gamera:setWindow
function M.calculate_resized_window( w, h )
  -- w = window width after resize, h = same with height

  -- Calculate new dimensions:
  -- set screen width to window width
  local new_w = w
  -- Preserve aspect ratio
  local new_h = new_w * (current_h / current_w)
  -- If the new dimentions are bigger than the window recalculate
  if new_h > h then
    -- Since height went out of bounds, make sure it doesn't this time
    new_h = h
    -- Preserve aspect ratio
    new_w = new_h * (current_w / current_h)
  end

  -- Determine unused screen area to find display window offset,
  -- so that what's displayed is always in the middle of the window
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
