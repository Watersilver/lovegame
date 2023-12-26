local gamera = require "gamera.gamera"
local scaling_handler = require "scaling_handler"

-- TODO: Fix this bullshit system that needs one canvas per effect

local prevScale = -1

---@class Effect
---@field shader love.Shader
---@field canvas love.Canvas
---@field prepare? fun(shader: love.Shader)

-- Canvas cache
---@type {c: love.Canvas, inUse: boolean}[]
local canvases = {}

-- Initialize some canvases to avoid possible lag during first creation
table.insert(canvases, {c = love.graphics.newCanvas(), inUse = false})
table.insert(canvases, {c = love.graphics.newCanvas(), inUse = false})
table.insert(canvases, {c = love.graphics.newCanvas(), inUse = false})

---@type Effect[]
local effects = {}

---@param w number
---@param h number
local resize = function( w, h )
  local cw, ch = gamera.getCanvas():getWidth(), gamera.getCanvas():getHeight()
  local scale = 1
  if w < cw then
    scale = cw / w
  end
  if h < ch then
    scale = math.max(scale, ch / h)
  end

  for _, c in ipairs(canvases) do

    -- Find effect that uses this canvas if it exists
    ---@type Effect | nil
    local e
    for _, effect in ipairs(effects) do
      if effect.canvas == c.c then
        e = effect
        break
      end
    end

    -- Resize canvases
    -- c.c = love.graphics.newCanvas(w, h)

    c.c = love.graphics.newCanvas(w * scale, h * scale)

    -- update effect canvas to use resized one
    if e then e.canvas = c.c end
  end

  for _, effect in ipairs(effects) do
---@diagnostic disable-next-line: undefined-field
    if effect.shader:getExternVariable('deadSpaceX') then
      effect.shader:send('deadSpaceX', 0)
    end
---@diagnostic disable-next-line: undefined-field
    if effect.shader:getExternVariable('deadSpaceY') then
      effect.shader:send('deadSpaceY', 0)
    end
  end
end

local screenEffects = {
  ---@param shader love.Shader
  ---@param prepare? fun(shader: love.Shader)
  push = function(shader, prepare)
    ---@type love.Canvas?
    local canvas

    -- Assign unused canvas for the effect
    for _, c in ipairs(canvases) do
      if not c.inUse then
        canvas = c.c
        c.inUse = true
        break
      end
    end

    -- Create canvas if none are available
    if not canvas then
      canvas = love.graphics.newCanvas()
      table.insert(canvases, {c = canvas, inUse = true})
    end

    -- Push new effect to table
    table.insert(effects, {
      canvas = canvas,
      shader = shader,
      prepare = prepare
    })
  end,

  pop = function()
    local effect = effects[#effects]
    table.remove(effects)

    for _, c in ipairs(canvases) do
      if effect.canvas == c.c then
        c.inUse = false
        break
      end
    end
  end,

  clear = function()
    effects = {}

    for _, c in ipairs(canvases) do
      c.inUse = false
    end
  end,

  ---apply pushed effects on given canvas in order
  ---@param canvas love.Canvas
  apply = function(canvas)
    if #effects == 0 then return end

    local s = scaling_handler.get_total_scale()
    if s ~= prevScale then
      resize(love.graphics.getWidth(), love.graphics.getHeight())
    end
    prevScale = s

    local origCanvas = love.graphics.getCanvas()
    local prevCanvas = canvas

    -- apply effects
    for _, effect in ipairs(effects) do
      if effect.prepare and effect.shader then
        effect.prepare(effect.shader)
      end
      love.graphics.setShader(effect.shader)
      love.graphics.setCanvas(effect.canvas)
      love.graphics.clear()
      love.graphics.draw(prevCanvas)
      prevCanvas = effect.canvas
      love.graphics.setShader()
    end

    -- draw everything to original canvas
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.draw(prevCanvas)

    love.graphics.setCanvas(origCanvas)
    love.graphics.draw(prevCanvas)
  end,

  resize = resize
}

return screenEffects