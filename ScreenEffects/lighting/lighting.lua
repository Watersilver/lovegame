local newPiecewise = require "piecewise2"
local screenEffects = require "screenEffects"
local u = require 'utilities'

local sourceTypes = require 'ScreenEffects.lighting.sourceTypes'

-- TODO: should light be able to turn something white?
-- Right now it turns it at most its unodified color.
-- Could be that up to .5 alpha it makes things be their color but above that it whitens.
-- Maybe that should be different effect.

local lightingShdr

local shdrExists = pcall(
  function ()
    lightingShdr = love.graphics.newShader("ScreenEffects/lighting/lighting.fs")
  end
)

---@class Light
---@field x number
---@field y number
---@field type "torch" | "owlStatue" | "smoothCircle8" | "smoothCircle16" | "smoothCircle24" | "doorLight"
---@field scale? number
---@field rgba? {r: number; g: number; b: number; a: number;}
---@field image_index? number

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
if shdrExists then lightingShdr:send("lightMap", lightMap) end
local shadowMap = love.graphics.newCanvas(getCanvasiDims(initial_w, initial_h))
if shdrExists then lightingShdr:send("shadowMap", shadowMap) end

---@param s love.Shader
local prepShader = function(s)
  -- determine ambient light from time or location
  -- session.save.time

  s:send("redBacklight", {1, 0, 0})
  s:send("greenBacklight", {0, 0.5, 0.2})
  s:send("blueBacklight", {0.2, 0, 0.5})

  -- s:send("redBacklight", {11, 0, 0})
  -- s:send("greenBacklight", {20, 0.5, 0.2})
  -- s:send("blueBacklight", {0.2, 30, 0.5})
end

local lighting = {}

---@param light Light
lighting.applyLight = function(light) table.insert(lights, light) end

---@param shadow Light
lighting.applyShadow = function(shadow) table.insert(shadows, shadow) end

lighting.pushScreenEffect = function()
  if shdrExists then screenEffects.push(lightingShdr, prepShader) end
end

---@param sources Light[]
---@param canvas love.Canvas
local function drawLightOnCanvas(sources, canvas)
  local prevCanv = love.graphics.getCanvas()
  love.graphics.setCanvas(canvas)
  local prevShader = love.graphics.getShader()

  -- Dunno if necessary but put here to be safe
  love.graphics.setShader()
  love.graphics.clear()
  local canvasW, canvasH = canvas:getDimensions()
  local ratioW = canvasW / canvW
  local ratioH = canvasH / canvH
  for index, light in ipairs(sources) do
    local x, y = mainCamera:toScreen(light.x, light.y)
    local _, _, w, h = mainCamera:getWindow()
    x, y = (canvasW / ratioW) * x / w, (canvasH / ratioH) * y / h
    local type = sourceTypes[light.type]
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
end

function lighting.draw()
  -------------------------------
  -- Draw light sources on canvas
  -------------------------------
  drawLightOnCanvas(lights, lightMap)

  -------------------------
  -- Draw shadows on canvas
  -------------------------
  drawLightOnCanvas(shadows, shadowMap)

  clearLights()
end

function lighting.resize(w, h)
  -- Canvas might be elongated on resize but fix that when feeding source positions
  local newW, newH = getCanvasiDims(w, h)
  lightMap = love.graphics.newCanvas(newW, newH)
  shadowMap = love.graphics.newCanvas(newW, newH)

  -- Send resized canvases to shader
  if shdrExists then
    lightingShdr:send("lightMap", lightMap)
    lightingShdr:send("shadowMap", shadowMap)
  end
end

return lighting