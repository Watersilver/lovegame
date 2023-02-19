local u = require 'utilities'
local im = require 'image'

local gradFuncs = {
  smoothEdgeCircle = function(dist, radius)
    local x = dist / radius -- This division stretches the function horizontally!!!
    -- calculated from https://mycurvefit.com/
    -- almost circle
    return -0.9360318 + (1 + 0.9360318)/(1 + (x/0.9981175)^35.08253)
    -- return -0.5820536 + (1 + 0.5820536)/(1 + (x/0.9798232)^26.55095)
  end,

  linear = function(dist, radius)
    return 1 - (1/radius) * dist
  end,

  -- Hope to figure out one day why I name this like that
  elipseQuadrant = function(dist, radius)
    return math.sqrt(1 - dist^2/radius^2)
  end
}

local function radialGradient(radius, kwargs)
  local data = love.image.newImageData(radius * 2, radius * 2)
  kwargs = kwargs or {}

  data:mapPixel(function(x, y)
    local dist = u.distance2d(radius, radius, x, y)
    local alpha = (dist <= radius and gradFuncs[kwargs.gradFunc or "smoothEdgeCircle"](dist, radius) or 0) * (kwargs.a or 1) * COLORCONST
    return (kwargs.r or 1) * COLORCONST, (kwargs.g or 1) * COLORCONST, (kwargs.b or 1) * COLORCONST, alpha
  end)

  return {img = love.graphics.newImage(data), centerOffset = radius + 0.5, type = "drawn"}
end

local function squareGradient(side, kwargs)
  local data = love.image.newImageData(side, side)
  kwargs = kwargs or {}

  data:mapPixel(function(x, y)
    -- local alpha = (y / side) * (kwargs.a or 1) * COLORCONST
    local alpha = (1 - 3 / (y + 3)) * (kwargs.a or 1) * COLORCONST
    return (kwargs.r or 1) * COLORCONST, (kwargs.g or 1) * COLORCONST, (kwargs.b or 1) * COLORCONST, alpha
  end)

  return {img = love.graphics.newImage(data), centerOffset = side * 0.5}
end

---@param layers {r: number; a: number}[]
---@return {img: love.Image, centerOffset: number, type: "drawn"}
local function radGrad(layers)
  local first = layers[1]
  local last = layers[#layers]
  local totalRadius = last.r
  local data = love.image.newImageData(totalRadius * 2, totalRadius * 2)

  ---@type {rmin: number; rmax: number; rdiff: number; avar: number; astart: number;}[]
  -- areas between layers
  local pairs = {
    -- first pair
    {rmin = 0, rmax = first.r, rdiff = first.r, avar = 0, astart = first.a}
  }

  -- middle pairs
  local prev = pairs[1]
  for i = 2, #layers do
    local layer = layers[i]
    pairs[i] = {
      rmin = prev.rmax,
      rmax = layer.r,
      rdiff = layer.r - prev.rmax,
      avar = (prev.astart - prev.avar) - layer.a,
      astart = prev.astart - prev.avar
    }
    prev = pairs[i]
  end

  -- last pair
  table.insert(pairs, {rmin = last.r, rmax = last.r, rdiff = 0, avar = 0, astart = 0})

  data:mapPixel(
    function(x, y)
      local dist = u.distance2d(totalRadius, totalRadius, x, y)

      -- Between two layers
      for i = #pairs, 1, -1 do
        local pair = pairs[i]
        if dist > pair.rmin then
          local alpha = pair.astart - pair.avar * (dist - pair.rmin) / (pair.rdiff)
          return COLORCONST, COLORCONST, COLORCONST, alpha * COLORCONST
        end
      end

      -- smaller than first
      return COLORCONST, COLORCONST, COLORCONST, first.a * COLORCONST
    end
  )

  return {img = love.graphics.newImage(data), centerOffset = totalRadius + 0.5, type = "drawn"}
end

---@alias SourceType "torch" | "owlStatue" | "playerGlow" | "massive"

---@type {[SourceType]: {type: "drawn", img: love.Image, centerOffset: number} | {type: "sprite", sprite: unknown}}
local sourceTypes = {
  torch = {sprite = im.load_sprite({'flickeringLight', 2, padding = 1, width = 48, height = 48})},
  owlStatue = radialGradient(24, {r = 0, g = 0.7, b = 1}),

  playerGlow = radGrad{
    {r = 8, a = 0.5},
    {r = 16, a = 0.2},
    {r = 48, a = 0}
  },
  massive = radGrad{
    {r = 24, a = 1},
    {r = 48, a = 0.5},
    {r = 150, a = 0.1},
    {r = 174, a = 0}
  },

  doorLight = squareGradient(16, {a = 1}),
}

return sourceTypes