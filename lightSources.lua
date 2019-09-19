local sh = require "scaling_handler"
local multiply = (require "Shaders.shaders").multiply


local ls = {}


local function line(x, a, b)
  return a * x + b
end

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

  elipseQuadrant = function(dist, radius)
    return math.sqrt(1 - dist^2/radius^2)
  end,
}

local function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function radialGradient(radius, kwargs)
  local data = love.image.newImageData(radius * 2, radius * 2)
  kwargs = kwargs or {}

  data:mapPixel(function(x, y)
    local dist = distance(radius, radius, x, y)
    -- local alpha = (dist <= radius and line(dist, (COLORCONST/radius) * ((kwargs.edgeAlpha or 0) - 1), COLORCONST) or 0) * (kwargs.a or 1)
    -- local alpha = (dist <= radius and math.cos(math.pi * 0.5 * dist / radius) or 0) * (kwargs.a or 1) * COLORCONST
    -- local alpha = (dist <= radius and gradFunction(dist, radius) or 0) * (kwargs.a or 1) * COLORCONST
    local alpha = (dist <= radius and gradFuncs[kwargs.gradFunc or "smoothEdgeCircle"](dist, radius) or 0) * (kwargs.a or 1) * COLORCONST
    return (kwargs.r or 1) * COLORCONST, (kwargs.g or 1) * COLORCONST, (kwargs.b or 1) * COLORCONST, alpha
  end)

  return {img = love.graphics.newImage(data), radius = radius}
end

local lights = {
  circleWhite8 = radialGradient(8),
  circleWhite16 = radialGradient(16),
  circleWhite24 = radialGradient(24),
  testGlow = radialGradient(24, {gradFunc = "elipseQuadrant"}),
  owlStatue = radialGradient(24, {r = 0, g = 0.7, b = 1}),
}

local sources = {}

function ls.drawSource(source)
  table.insert(sources, source)
end

function ls.drawSources()
  local mode, alphamode = love.graphics.getBlendMode()
  love.graphics.setBlendMode( "lighten", "premultiplied" )
  local worldShader = love.graphics.getShader()
  for index, source in ipairs(sources) do
    -- Use shader to premultiply to be able to use lighten blend mode
    love.graphics.setShader(multiply)
    local sx, sy = mainCamera:toScreen(source.x, source.y)
    sx, sy = sx * 0.5, sy * 0.5
    local skind = lights[source.kind]
    local sc = sh.get_game_scale()
    love.graphics.draw(skind.img, sx, sy, 0, sc, sc, skind.radius, skind.radius)
    sources[index] = nil
  end
    love.graphics.setShader(worldShader)
  love.graphics.setBlendMode( mode, alphamode )
end

return ls
