local sh = {}

-- Private fields

-- Set dimensions
local initial_w = love.graphics.getWidth()
local initial_h = love.graphics.getHeight()
local real_w = initial_w
local real_h = initial_h
local current_l = 0
local current_t = 0
local current_w = initial_w
local current_h = initial_h
local previous_w = current_w
local previous_h = current_h

-- Camera scaling due to window size
local window_scale = initial_w / 800
function sh.get_window_scale()
  return window_scale
end

---@return number
function sh.get_aspect_ratio()
  return initial_w / initial_h
end
---@return number
function sh.get_inv_aspect_ratio()
  return initial_h / initial_w
end

---@param w number
---@param h number
function sh.fit_in_aspect_ratio(w, h)
  local a = sh.get_aspect_ratio()
  local givenAspectRatio = w / h

  if givenAspectRatio == a then return w, h end

  if a > givenAspectRatio then
    return w, w * sh.get_inv_aspect_ratio()
  else
    return h * a, h
  end
end

---@param w number
---@param h number
function sh.get_deadspace(w, h)
  local fw, fh = sh.fit_in_aspect_ratio(w, h)
  return (w - fw) * 0.5, (h - fh) * 0.5
end

-- Camera scaling due to in-game reasons
local game_scale = 1
function sh.get_game_scale()
  return game_scale
end

local total_scale
function sh.get_total_scale()
  return total_scale
end
function sh.__set_total_scale(tsc)
  total_scale = tsc
end

-- Used when zooming in out due to in game reasons or window resize
-- Never set total_scale. Calculate through this
function sh.calculate_total_scale(params)

  if params.resized then
    window_scale = window_scale * (current_w / previous_w)
  end
  game_scale = params.game_scale or game_scale
  total_scale = window_scale * game_scale

end

-- Finds appropriate gamera window dimensions after resize.
-- Returned values are to be used in gamera:setWindow
function sh.calculate_resized_window( w, h )
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

  real_w = w
  real_h = h

  -- Determine unused screen area to find display window offset,
  -- so that what's displayed is always in the middle of the window
  local dead_space_w = w - new_w
  local dead_space_h = h - new_h

  -- Store previous dimensions
  previous_w = current_w
  previous_h = current_h

  -- return dead_space_w * 0.5, dead_space_h * 0.5, new_w, new_h
  current_l, current_t, current_w, current_h = dead_space_w * 0.5, dead_space_h * 0.5, new_w, new_h

  return current_l, current_t, current_w, current_h
end

function sh.getCachedWindow()
  return current_l, current_t, current_w, current_h
end

function sh.getCachedTextWindow()
  return (real_w - current_w * 0.5) * 0.5, (real_h + current_h * 0.5) * 0.5, current_w * 0.5, current_h * 0.2
end

-- Return the result of calculate_resized_window without doing
-- any operations and messing up previous_w and previous_h
-- USE ON RESIZE CALLBACK AFTER calculate_resized_window!
function sh.get_resized_window( w, h )
  return (w - current_w) * 0.5, (h - current_h) * 0.5, current_w, current_h
end

-- USE ON RESIZE CALLBACK AFTER calculate_resized_window!
function sh.get_resized_text_window( w, h )
  return
    -- left
    (w - current_w * 0.5) * 0.5,
    -- top
    (h + current_h * 0.5) * 0.5,
    -- width
    current_w * 0.5,
    -- height
    current_h * 0.2
end

-- USE ON RESIZE CALLBACK AFTER calculate_resized_window!
function sh.get_resized_choice_window( w, h )
  return
    -- left
    (w - current_w * 0.5) * 0.5,
    -- top
    (h + current_h * 0.5) * 0.5,--83,
    -- width
    current_w * 0.5,
    -- height
    current_h * 0.2
end

function sh.get_current_window()
  return (real_w - current_w) * 0.5, (real_h - current_h) * 0.5, current_w, current_h
end

function sh.calculate_initial_window(cam)
  local _,_,ww,wh = cam:getWorld()
  initial_w = math.max(initial_w, ww)
  initial_h = math.max(initial_h, wh)
  return sh.calculate_resized_window(initial_w, initial_h)
end

return sh
