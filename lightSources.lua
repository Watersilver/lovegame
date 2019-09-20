local im = require "image"
local sh = require "scaling_handler"
local multiply = (require "Shaders.shaders").multiply
local u = require "utilities"


local ls = {}

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

local function radialGradient(radius, kwargs)
  local data = love.image.newImageData(radius * 2, radius * 2)
  kwargs = kwargs or {}

  data:mapPixel(function(x, y)
    local dist = u.distance2d(radius, radius, x, y)
    local alpha = (dist <= radius and gradFuncs[kwargs.gradFunc or "smoothEdgeCircle"](dist, radius) or 0) * (kwargs.a or 1) * COLORCONST
    return (kwargs.r or 1) * COLORCONST, (kwargs.g or 1) * COLORCONST, (kwargs.b or 1) * COLORCONST, alpha
  end)

  return {img = love.graphics.newImage(data), centerOffset = radius + 0.5, scale = 1}
end

local lights = {
  circleWhite8 = radialGradient(8),
  circleWhite16 = radialGradient(16),
  circleWhite24 = radialGradient(24),
  testGlow = radialGradient(8, {gradFunc = "linear", a = 1}),
  missile = radialGradient(8, {gradFunc = "elipseQuadrant", a = 0.75, r = 0, g = 0.5}),
  owlStatue = radialGradient(24, {r = 0, g = 0.7, b = 1}),
  flickerTorch = {sprite = im.load_sprite({'flickeringLight', 2, padding = 1, width = 48, height = 48})}
}

local sources = {}

function ls.drawSource(source)
  table.insert(sources, source)
end

-- clears sources array. Will be run once per main draw
function ls.clearSources()
  for index in ipairs(sources) do
    sources[index] = nil
  end
end

-- draws light source then DELETES it!!!
function ls.drawSources()
  local mode, alphamode = love.graphics.getBlendMode()
  love.graphics.setBlendMode( "lighten", "premultiplied" )
  local worldShader = love.graphics.getShader()
  for index, source in ipairs(sources) do
    -- Use shader to premultiply to be able to use lighten blend mode
    love.graphics.setShader(multiply)
    local sx, sy = mainCamera:toScreen(source.x, source.y)
    local deadSpaceX, deadSpaceY = mainCamera:getWindow()
    -- sx, sy = sx * 0.5, sy * 0.5
    sx, sy = (sx - deadSpaceX) / sh.get_window_scale(), (sy - deadSpaceY) / sh.get_window_scale()
    local skind = lights[source.kind]
    local sc = sh.get_game_scale()
    if skind.img then
      love.graphics.draw(skind.img, sx, sy, 0, sc * skind.scale, sc * skind.scale, skind.centerOffset, skind.centerOffset)
    elseif source.image_index then
      -- if light doesn't show, check the source to see if I remembered to set index
      local sprite = skind.sprite
      love.graphics.draw(sprite.img, sprite[source.image_index], sx, sy, 0, sc * sprite.res_x_scale, sc * sprite.res_x_scale, sprite.cx, sprite.cy)
    end
    sources[index] = nil
  end
  love.graphics.setShader(worldShader)
  love.graphics.setBlendMode( mode, alphamode )
end

return ls
