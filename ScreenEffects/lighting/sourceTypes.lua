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

  return {img = love.graphics.newImage(data), centerOffset = radius + 0.5}
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

---@param r1 number
---@param r2 number
---@return {img: love.Image, centerOffset: number}
local function radialGrad2(r1, r2)
  local data = love.image.newImageData(r2 * 2, r2 * 2)

  data:mapPixel(function(x, y)
    local dist = u.distance2d(r2, r2, x, y)

    ---@type number
    local alpha

    if dist > r2 then alpha = 0
    elseif dist > r1 then alpha = 1 - (dist - r1) / (r2 - r1)
    else alpha = 1 end

    return COLORCONST, COLORCONST, COLORCONST, alpha * COLORCONST
  end)

  return {img = love.graphics.newImage(data), centerOffset = r2 + 0.5}
end

local sourceTypes = {
  torch = {sprite = im.load_sprite({'flickeringLight', 2, padding = 1, width = 48, height = 48})},
  owlStatue = radialGradient(24, {r = 0, g = 0.7, b = 1}),

  smoothCircle8 = radialGrad2(8, 16),
  smoothCircle16 = radialGrad2(16, 24),
  smoothCircle24 = radialGrad2(24, 48),

  doorLight = squareGradient(16, {a = 1}),
}

return sourceTypes