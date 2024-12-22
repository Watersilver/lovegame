local u = require 'utilities'
local im = require 'image'

local function square(side, centerOffset)
  local data = love.image.newImageData(side, side)

  data:mapPixel(function()
    return 1,1,1,1
  end)

  return {img = love.graphics.newImage(data), centerOffset = centerOffset or 0, type = "drawn"}
end

local function squareGradient(side, kwargs)
  local data = love.image.newImageData(side, side)
  kwargs = kwargs or {}

  data:mapPixel(function(x, y)
    local alpha = (1 - 3 / (y + 3)) * (kwargs.a or 1)
    return (kwargs.r or 1) * alpha, (kwargs.g or 1) * alpha, (kwargs.b or 1) * alpha, alpha
  end)

  return {img = love.graphics.newImage(data), centerOffset = side * 0.5, type = "drawn"}
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

  -- local _ditheringPatternMatrix = {
  --   {
  --     0.659,0.157,0.533,0.031,0.627,0.125,0.502,0.000
  --   },
  --   {
  --     0.408,0.918,0.282,0.784,0.376,0.878,0.251,0.753
  --   },
  --   {
  --     0.596,0.102,0.722,0.220,0.565,0.071,0.690,0.188
  --   },
  --   {
  --     0.345,0.847,0.471,0.973,0.314,0.816,0.439,0.941
  --   },
  --   {
  --     0.643,0.141,0.518,0.031,0.675,0.173,0.549,0.031
  --   },
  --   {
  --     0.392,0.894,0.267,0.769,0.424,0.918,0.298,0.800
  --   },
  --   {
  --     0.580,0.071,0.706,0.204,0.612,0.102,0.741,0.235
  --   },
  --   {
  --     0.329,0.831,0.455,0.957,0.361,0.863,0.486,1.000
  --   },
  -- }

  -- local grads = 3
  -- local gradsDiv = 1 / grads
  data:mapPixel(
    function(x, y)
      local dist = u.distance2d(totalRadius, totalRadius, x, y)

      -- Between two layers
      for i = #pairs, 1, -1 do
        local pair = pairs[i]
        if dist > pair.rmin then
          local alpha = pair.astart - pair.avar * (dist - pair.rmin) / (pair.rdiff)

          -- local endAlpha = pair.astart - pair.avar

          -- alpha = alpha / first.a
          -- alpha = math.floor(alpha * grads) * gradsDiv
          -- alpha = alpha * first.a

          -- local tween = (alpha - endAlpha) / pair.astart

          -- local dith = _ditheringPatternMatrix[math.floor(x) % 8 + 1][math.floor(y) % 8 + 1]
          -- if tween - dith > -0.01 then
          --   alpha = pair.astart
          -- else
          --   alpha = endAlpha
          -- end

          return alpha, alpha, alpha, alpha
        end
      end

      -- smaller than first
      return first.a, first.a, first.a, first.a
    end
  )

  return {img = love.graphics.newImage(data), centerOffset = totalRadius + 0.5, type = "drawn"}
end

local function shallowcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

local function getLightsprite(spriteSettings)
  local copy = shallowcopy(spriteSettings)
  copy[1] = copy[1] .. "-light"
  return copy
end

---@alias SourceType "dynamic" | "owlStatue" | "canvas" | "cloudCurve" | "boss4" | "boss4shield" | "boss4ball" | "boss4spikes" | "boss4link" | "torch" | "sprinkle" | "owlStatue" | "playerGlow" | "massive" | "door" | 'missile' | 'pixel' | 'rupee' | 'rupee5' | 'rupee20' | 'rupee100' | 'rupee200'

---@type {[SourceType]: {type: "drawn", img: love.Image, centerOffset: number} | {type: "sprite", sprite: unknown} | {type: "canvas"}}
local sourceTypes = {
  torch = {type = "sprite", sprite = im.load_sprite({'flickeringLight', 2, padding = 1, width = 48, height = 48})},
  sprinkle = {type = "sprite", sprite = im.load_sprite{'Effects/UseSprinkleEffect', 6, padding = 2, width = 24, height = 10}},
  owlStatue = radGrad{{r = 23, a = 1}, {r = 30, a = 0}},

  playerGlow = radGrad{
    {r = 8, a = 0.5},
    {r = 16, a = 0.2},
    {r = 48, a = 0},
  },
  massive = radGrad{
    {r = 24, a = 1},
    {r = 48, a = 0.5},
    {r = 150, a = 0.1},
    {r = 174, a = 0}
  },

  missile = radGrad{
    {r = 2, a = 1},
    {r = 6, a = 0}
  },

  rupee = radGrad{
    {r = 4, a = 1},
    {r = 8, a = 0}
  },

  rupee5 = radGrad{
    {r = 4.5, a = 1},
    {r = 16, a = 0}
  },

  rupee20 = radGrad{
    {r = 5.5, a = 1},
    {r = 32, a = 0}
  },

  rupee100 = radGrad{
    {r = 6, a = 1},
    {r = 64, a = 0}
  },

  rupee200 = radGrad{
    {r = 8, a = 1},
    {r = 128, a = 0}
  },

  cloudCurve = radGrad{
    {r = 25, a = 1},
    {r = 50, a = 0}
  },

  door = squareGradient(16, {a = 1}),

  pixel = square(1),

  boss4 = {type = "sprite", sprite = im.load_sprite(getLightsprite(im.spriteSettings.boss4[1]))},
  boss4shield = {type = "sprite", sprite = im.load_sprite(getLightsprite(im.spriteSettings.boss4[2]))},
  boss4ball = {type = "sprite", sprite = im.load_sprite(getLightsprite(im.spriteSettings.boss4[3]))},
  boss4spikes = {type = "sprite", sprite = im.load_sprite(getLightsprite(im.spriteSettings.boss4[4]))},
  boss4link = {type = "sprite", sprite = im.load_sprite(getLightsprite(im.spriteSettings.boss4[5]))},

  canvas = {type = 'canvas'}
}

return sourceTypes