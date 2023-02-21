local game = require 'game'
local newPiecewise = require 'piecewise2'

---@param a number
---@param b number
---@param progress number
---@return number
local function atob(a, b, progress)
  if b > a then
    local diff = b - a
    return a + diff * progress
  else
    local diff = a - b
    return a - diff * progress
  end
end

---@param a {r: number[], g: number[], b: number[]}
---@param b {r: number[], g: number[], b: number[]}
---@param t number
local function rgbLerp(a, b, t)
  return {
    r = {
      atob(a.r[1], b.r[1], t),
      atob(a.r[2], b.r[2], t),
      atob(a.r[3], b.r[3], t),
      1
    },
    g = {
      atob(a.g[1], b.g[1], t),
      atob(a.g[2], b.g[2], t),
      atob(a.g[3], b.g[3], t),
      1
    },
    b = {
      atob(a.b[1], b.b[1], t),
      atob(a.b[2], b.b[2], t),
      atob(a.b[3], b.b[3], t),
      1
    }
  }
end

local daynight1 = newPiecewise({value = 0})

-- Small hours
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.05, 0, 0.1},
    g = {0, 0.1, 0},
    b = {0, 0, 0.1}
  }, {
    r = {0.1, 0, 0.1},
    g = {0, 0.13, 0},
    b = {0, 0, 0.13}
  }, f)
end, {value = 6})
-- Dawn start
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.1, 0, 0.1},
    g = {0, 0.13, 0},
    b = {0, 0, 0.13}
  }, {
    r = {0.2, 0, 0},
    g = {0, 0.6, 0},
    b = {0, 0, 0.7}
  }, f)
end, {value = 7})
-- Dawn end
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.2, 0, 0},
    g = {0, 0.6, 0},
    b = {0, 0, 0.7}
  }, {
    r = {0.6, 0, 0},
    g = {0, 0.8, 0},
    b = {0, 0, 0.8}
  }, f)
end, {value = 8})
-- Sunrise
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.6, 0, 0},
    g = {0, 0.8, 0},
    b = {0, 0, 0.8}
  }, {
    r = {0.9, 0, 0},
    g = {0, 0.9, 0},
    b = {0, 0, 0.9}
  }, f)
end, {value = 9})
-- Day
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.9, 0, 0},
    g = {0, 0.9, 0},
    b = {0, 0, 0.9}
  }, {
    r = {1, 0, 0},
    g = {0, 1, 0},
    b = {0, 0, 1}
  }, f)
end, {value = 15})
-- Late day
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {1, 0, 0},
    g = {0, 1, 0},
    b = {0, 0, 1}
  }, {
    r = {0.8, 0, 0},
    g = {0, 0.8, 0},
    b = {0, 0, 0.8}
  }, f)
end, {value = 18})
-- Sunset
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.8, 0, 0},
    g = {0, 0.8, 0},
    b = {0, 0, 0.8}
  }, {
    r = {0.7, 0, 0},
    g = {0, 0.6, 0},
    b = {0, 0, 0.6}
  }, f)
end, {value = 19})
-- Twilight start
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.7, 0, 0},
    g = {0, 0.6, 0},
    b = {0, 0, 0.6}
  }, {
    r = {0.6, 0, 0},
    g = {0.1, 0.3, 0},
    b = {0.1, 0, 0.3}
  }, f)
end, {value = 20})
-- Twilight end
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.6, 0, 0},
    g = {0.1, 0.3, 0},
    b = {0.1, 0, 0.3}
  }, {
    r = {0.1, 0, 0},
    g = {0, 0.1, 0},
    b = {0, 0, 0.1}
  }, f)
end, {value = 21})
-- Night
daynight1.newSubfunction(function(_, f)
  return rgbLerp({
    r = {0.1, 0, 0},
    g = {0, 0.1, 0},
    b = {0, 0, 0.1}
  }, {
    r = {0.05, 0, 0.1, 1},
    g = {0, 0.1, 0, 1},
    b = {0, 0, 0.1, 1}
  }, f)
end, {value = 24})

-- Input: backlight type and time of day
-- TODO: smooth transitions even when input changes suddenly
-- Cosider making it a gradient

---@param s love.Shader
---@return { r: number[], g: number[], b: number[] }
local function determineAmbient(s)

  local a = game.room.ambientLightType

  if a == 'black' then return {
    r = {0,0,0,1},
    g = {0,0,0,1},
    b = {0,0,0,1}
  } end

  if a == 'dull' then return {
    r = {0.3, 0, 0.3, 1},
    g = {0, 0.7, 0.3, 1},
    b = {0, 0, 0.7, 1}
  } end

  if a == 'forestCurse1' then return {
    r = {0.4, 0, 0.1, 1},
    g = {0.4, 0.15, 0.15, 1},
    b = {0, 0, 0.5, 1}
  } end

  if a == 'forestMagic' then return {
    r = {0.5, 0.1, 0, 1},
    g = {0, 1, 0, 1},
    b = {0, 0.2, 0.7, 1}
  } end

  if a == 'daynight1' then return daynight1.call(session.save.time) end

  if a == 'midnight' then return {
    r = {0.05, 0, 0.1, 1},
    g = {0, 0.1, 0, 1},
    b = {0, 0, 0.1, 1}
  } end

  return a or {
    r = {1, 0, 0, 1},
    g = {0, 1, 0, 1},
    b = {0, 0, 1, 1}
  }

  -- delta_time
end

return determineAmbient
