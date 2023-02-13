local newPiecewise = require "piecewise2"
local screenEffects = require "screenEffects"
local u = require 'utilities'
local im = require 'image'

local lightingShdr

local shdrExists = pcall(
  function ()
    lightingShdr = love.graphics.newShader("ScreenEffects/lighting.fs")
  end
)

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
  end,

  focusedLinear = function(dist, radius)
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

-- Calculate screen lighting modifiers (due to time of day and weather(?) or due to interior lighting)

local lightTypes = {
  torch = {sprite = im.load_sprite({'flickeringLight', 2, padding = 1, width = 48, height = 48})},
  owlStatue = radialGradient(24, {r = 0, g = 0.7, b = 1}),

  smoothCircle8 = radialGrad2(8, 10),
  smoothCircle16 = radialGrad2(16, 18),
  smoothCircle24 = radialGrad2(24, 48),
  -- missile = radialGradient(8, {gradFunc = "elipseQuadrant", a = 0.75, r = 0, g = 0.5}),

  doorLight = squareGradient(16, {a = 1}),
}

---@class Light
---@field x number
---@field y number
---@field type "torch" | "owlStatue" | "smoothCircle8" | "smoothCircle16" | "smoothCircle24" | "doorLight"
---@field scale? number
---@field rgba? {r: number; g: number; b: number; a: number;}
---@field image_index? number

---@type Light[]
local lights = {}

local function clearLights()
  for index in ipairs(lights) do
    lights[index] = nil
  end
end

local initial_w = love.graphics.getWidth()
local initial_h = love.graphics.getHeight()
local canvScale = 2
-- -- Min canvas width
-- local canvW = 800 / 2
-- -- Min canvas height
-- local canvH = 450 / 2
-- Min canvas width
local canvW = 400 * canvScale
-- Min canvas height
local canvH = 225 * canvScale

---@param w number
---@param h number
local function getCanvasiDims(w, h)
  local newW, newH
  local ratio = w / h
  if (ratio) > 1.7777 then
    newW = ratio * canvH
    newH = canvH
  else
    newW = canvW
    newH = canvW / ratio
  end
  return newW, newH
end

local lightMap = love.graphics.newCanvas(getCanvasiDims(initial_w, initial_h))

---@param s love.Shader
local prepShader = function(s)
  -- determine ambient light from time or location
  -- session.save.time
  s:send("redMap", {1, 0, 0})
  s:send("greenMap", {0, 0.5, 0.2})
  s:send("blueMap", {0.2, 0, 0.5})
  s:send("lightMap", lightMap)
end

local lighting = {}

---@param light Light
lighting.applyLight = function(light) table.insert(lights, light) end

lighting.applyScreenEffect = function()
  if shdrExists then screenEffects.push(lightingShdr, prepShader) end
end

function lighting.draw()

  -------------------------------
  -- Draw light sources on canvas
  -------------------------------
  local prevCanv = love.graphics.getCanvas()
  love.graphics.setCanvas(lightMap)
  local prevShader = love.graphics.getShader()

  -- Dunno if necessary but put here to be safe
  love.graphics.setShader()
  love.graphics.clear()
  local canvasW, canvasH = lightMap:getDimensions()
  local ratioW = canvasW / canvW
  local ratioH = canvasH / canvH
  for index, light in ipairs(lights) do
    local x, y = mainCamera:toScreen(light.x, light.y)
    local _, _, w, h = mainCamera:getWindow()
    x, y = (canvasW / ratioW) * x / w, (canvasH / ratioH) * y / h
    local type = lightTypes[light.type]
    local resetColor
    if light.rgba then
      u.changeColour({
        r = light.rgba.r * COLORCONST,
        g = light.rgba.g * COLORCONST,
        b = light.rgba.b * COLORCONST,
        a = light.rgba.a * COLORCONST
      })
      resetColor = u.storeColour()
    end
    if type then
      if type.sprite then
        local s = type.sprite
        love.graphics.draw(
          s.img, s[light.image_index],
          x, y, 0,
          canvScale * s.res_x_scale,
          canvScale * s.res_x_scale,
          s.cx, s.cy
        )
      else
        love.graphics.draw(
          type.img,
          x, y, 0,
          canvScale * (light.scale or 1),
          canvScale * (light.scale or 1),
          type.centerOffset,
          type.centerOffset
        )
      end
    end
    if resetColor then resetColor() end
    lights[index] = nil
  end

  -- Dunno if necessary but put here to be safe
  love.graphics.setShader(prevShader)
  if prevCanv then love.graphics.setCanvas(prevCanv) else love.graphics.setCanvas() end

  clearLights()
end

function lighting.resize(w, h)
  -- Canvas might be elongated on resize but fix that when feeding source positions
  lightMap = love.graphics.newCanvas(getCanvasiDims(w, h))
end

return lighting