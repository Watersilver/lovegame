local screenEffects = require "screenEffects"
local u = require 'utilities'
local determineAmbient = require 'ScreenEffects.lighting.determineAmbient'
local determinePalette = require 'ScreenEffects.lighting.determinePalette'
local scaling_handler  = require 'scaling_handler'

local sourceTypes = require 'ScreenEffects.lighting.sourceTypes'

local lightingShdr

local shdrExists, err = pcall(
  function ()
    lightingShdr = love.graphics.newShader("ScreenEffects/lighting/lighting.fs")
  end
)

if not shdrExists then print(err) end

---@class Light
---@field x number
---@field y number
---@field type SourceType
---@field rad? number
---@field scale? number
---@field x_scale? number
---@field rgba? {r: number; g: number; b: number; a: number;}
---@field image_index? number
---@field canvasImg? love.Image
---@field dynamic_options? {radius: number, segments?: number}

---@type Light[]
local lights = {}

---@type Light[]
local shadows = {}

local function clearLights()
  for index in ipairs(lights) do
    lights[index] = nil
  end
  for index in ipairs(shadows) do
    shadows[index] = nil
  end
end

local initial_w = love.graphics.getWidth()
local initial_h = love.graphics.getHeight()
-- -- Min canvas width
local minCanvW = 800
-- -- Min canvas height
local minCanvH = 450
-- canvas width
local canvW = 800
-- canvas height
local canvH = 450

---@param w number
---@param h number
local function calcCanvasDims(w, h)
  canvW = minCanvW / scaling_handler.get_game_scale()
  canvH = minCanvH / scaling_handler.get_game_scale()
  return canvW, canvH
  -- local newW, newH
  -- local ratio = w / h
  -- if (ratio) > 1.7777 then
  --   newW = ratio * canvH
  --   newH = canvH
  -- else
  --   newW = canvW
  --   newH = canvW / ratio
  -- end
  -- return newW, newH
end


local lightMap = love.graphics.newCanvas(calcCanvasDims(initial_w, initial_h))
if shdrExists then lightingShdr:send("lightMap", lightMap) end
local shadowMap = love.graphics.newCanvas(calcCanvasDims(initial_w, initial_h))
if shdrExists then lightingShdr:send("shadowMap", shadowMap) end


---@type { r: number[], g: number[], b: number[] }
local palette
---@type { r: number[], g: number[], b: number[] }
local ambient

---@param v number
---@param t number
---@param step number
local function moveTowardsValue(v, t, step)
  if v > t then
    v = v - step * delta_time
    if v < t then v = t end
  elseif v < t then
    v = v + step * delta_time
    if v > t then v = t end
  end
  return v
end

local function rgbMoveTowardsValue(v, t, step)
  v.r[1] = moveTowardsValue(v.r[1], t.r[1], step)
  v.r[2] = moveTowardsValue(v.r[2], t.r[2], step)
  v.r[3] = moveTowardsValue(v.r[3], t.r[3], step)
  v.g[1] = moveTowardsValue(v.g[1], t.g[1], step)
  v.g[2] = moveTowardsValue(v.g[2], t.g[2], step)
  v.g[3] = moveTowardsValue(v.g[3], t.g[3], step)
  v.b[1] = moveTowardsValue(v.b[1], t.b[1], step)
  v.b[2] = moveTowardsValue(v.b[2], t.b[2], step)
  v.b[3] = moveTowardsValue(v.b[3], t.b[3], step)

  return v
end

---@param s love.Shader
local prepShader = function(s)
  -- determine palette
  local paletteTarget = determinePalette()
  palette = palette or {
    r = {
      paletteTarget.r[1],
      paletteTarget.r[2],
      paletteTarget.r[3],
      paletteTarget.r[4]
    },
    g = {
      paletteTarget.g[1],
      paletteTarget.g[2],
      paletteTarget.g[3],
      paletteTarget.g[4]
    },
    b = {
      paletteTarget.b[1],
      paletteTarget.b[2],
      paletteTarget.b[3],
      paletteTarget.b[4]
    }
  }
  rgbMoveTowardsValue(palette, paletteTarget, 1)

  -- determine ambient light
  local ambientTarget = determineAmbient()
  ambient = ambient or {
    r = {
      ambientTarget.r[1],
      ambientTarget.r[2],
      ambientTarget.r[3],
      ambientTarget.r[4]
    },
    g = {
      ambientTarget.g[1],
      ambientTarget.g[2],
      ambientTarget.g[3],
      ambientTarget.g[4]
    },
    b = {
      ambientTarget.b[1],
      ambientTarget.b[2],
      ambientTarget.b[3],
      ambientTarget.b[4]
    }
  }
  rgbMoveTowardsValue(ambient, ambientTarget, 1)

  s:send("redPalette", palette.r)
  s:send("greenPalette", palette.g)
  s:send("bluePalette", palette.b)

  s:send("redAmbient", ambient.r)
  s:send("greenAmbient", ambient.g)
  s:send("blueAmbient", ambient.b)

  -- s:send("redAmbient", {1, 0, 0, 1})
  -- s:send("greenAmbient", {0, 0.5, 0.2, 1})
  -- s:send("blueAmbient", {0.2, 0, 0.5, 1})

  -- s:send("redAmbient", {11, 0, 0, 1})
  -- s:send("greenAmbient", {20, 0.5, 0.2, 1})
  -- s:send("blueAmbient", {0.2, 30, 0.5, 1})

  -- s:send("redAmbient", {0.05, 0, 0.1, 1})
  -- s:send("greenAmbient", {0, 0.1, 0, 1})
  -- s:send("blueAmbient", {0, 0, 0.1, 1})

  -- s:send("redAmbient", {1, 0, 0, 1})
  -- s:send("greenAmbient", {0, 1, 0, 1})
  -- s:send("blueAmbient", {0, 0, 1, 1})

  -- s:send("redAmbient", {0, 0, 0, 1})
  -- s:send("greenAmbient", {0, 0, 0, 1})
  -- s:send("blueAmbient", {0, 0, 0, 1})
end

local lighting = {}

--- rgba is [0, 1]
---
---@param light Light
lighting.applyLight = function(light) table.insert(lights, light) end

--- rgba is [0, 1]
---
---@param shadow Light
lighting.applyShadow = function(shadow) table.insert(shadows, shadow) end

lighting.pushScreenEffect = function()
  if shdrExists then screenEffects.push(lightingShdr, prepShader) end
end

---@type boolean | nil
local prevNV = nil
---@param nv boolean
lighting.sendNightVision = function(nv)
  if nv == prevNV then return end
  if shdrExists then
    lightingShdr:send("nightVision", nv)
  end
  prevNV = nv
end

---@param sources Light[]
---@param canvas love.Canvas
local function drawSourceOnCanvas(sources, canvas)
  local prevCanv = love.graphics.getCanvas()
  love.graphics.setCanvas(canvas)
  local prevShader = love.graphics.getShader()

  -- Dunno if necessary but put here to be safe
  love.graphics.setShader()
  love.graphics.clear()
  local mode, alphamode = love.graphics.getBlendMode()
  love.graphics.setBlendMode("lighten", "premultiplied")
  local canvasW, canvasH = canvas:getDimensions()
  local ratioW = canvasW / canvW
  local ratioH = canvasH / canvH
  for index, light in ipairs(sources) do
    local x, y = mainCamera:toScreen(light.x, light.y)
    local l, t, w, h = mainCamera:getWindow()
    x, y = x - l, y - t
    x, y = (canvasW / ratioW) * x / w, (canvasH / ratioH) * y / h
    local type = sourceTypes[light.type]
    light.rgba = light.rgba or {r=1,g=1,b=1,a=1}
    u.changeColour({
      r = ((light.rgba.r) or 1) * light.rgba.a,
      g = ((light.rgba.g) or 1) * light.rgba.a,
      b = ((light.rgba.b) or 1) * light.rgba.a,
      a = (light.rgba.a) or 1
    })
    local resetColor = u.storeColour()
    if type then
      -- local scale = scaling_handler.get_game_scale()
      local scale = 1
      if type.type == "sprite" then
        if light.image_index then
          local s = type.sprite
          love.graphics.draw(
            s.img, s[light.image_index],
            x, y, light.rad or 0,
            scale * s.res_x_scale * (light.x_scale or light.scale or 1),
            scale * s.res_y_scale * (light.scale or 1),
            s.cx, s.cy
          )
        end
      elseif type.type == 'drawn' then
        love.graphics.draw(
          type.img,
          x, y, light.rad or 0,
          scale * (light.x_scale or light.scale or 1),
          scale * (light.scale or 1),
          type.centerOffset,
          type.centerOffset
        )
      else
        local sx = canvasW / light.canvasImg:getWidth()
        local sy = canvasH / light.canvasImg:getHeight()

        love.graphics.draw(
          light.canvasImg,
          0, 0, 0,
          sx,
          sy
        )
      end
    elseif light.type == 'dynamic' then
      if light.dynamic_options then
        love.graphics.circle(
          "fill", x, y,
          light.dynamic_options.radius,
          light.dynamic_options.segments
        )
      end
    end
    resetColor()
    lights[index] = nil
  end

  love.graphics.setBlendMode(mode, alphamode)

  -- Dunno if necessary but put here to be safe
  love.graphics.setShader(prevShader)
  love.graphics.setCanvas(prevCanv)
end

function lighting.draw()
  -------------------------------
  -- Draw light sources on canvas
  -------------------------------
  drawSourceOnCanvas(lights, lightMap)

  -------------------------
  -- Draw shadows on canvas
  -------------------------
  drawSourceOnCanvas(shadows, shadowMap)

  clearLights()
end

function lighting.resize(w, h)
  -- Canvas might be elongated on resize but fix that when feeding source positions
  local newW, newH = calcCanvasDims(w, h)
  lightMap = love.graphics.newCanvas(newW, newH)
  shadowMap = love.graphics.newCanvas(newW, newH)

  -- Send resized canvases to shader
  if shdrExists then
    lightingShdr:send("lightMap", lightMap)
    lightingShdr:send("shadowMap", shadowMap)
  end
end

scaling_handler.on_total_scale_calculated(function(w, h)
  -- Canvas might be elongated on resize but fix that when feeding source positions
  local newW, newH = calcCanvasDims(w, h)
  lightMap = love.graphics.newCanvas(newW, newH)
  shadowMap = love.graphics.newCanvas(newW, newH)

  -- Send resized canvases to shader
  if shdrExists then
    lightingShdr:send("lightMap", lightMap)
    lightingShdr:send("shadowMap", shadowMap)
  end
end)

return lighting



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