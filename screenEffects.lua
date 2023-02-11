---@class Effect
---@field shader love.Shader
---@field canvas love.Canvas
---@field prepare? fun(shader: love.Shader)

---@param draw fun()|love.Canvas
---@param canvas? love.Canvas
---@param shader? love.Shader
---@param prepare? fun(shader: love.Shader)
local function drawEffects(draw, canvas, shader, prepare)
  -- Prepare: set canvas and prepare shader
  if canvas then
    -- We will draw on this canvas
    love.graphics.setCanvas(canvas)

    -- Only call clear if canvas exists because clear is called automatically
    -- before love.draw in the default love.run function
    love.graphics.clear()
  end
  if prepare and shader then
    prepare(shader)
  end

  -- Draw: set shader and draw
  if shader then love.graphics.setShader(shader) end
  if type(draw) == "function" then draw() else love.graphics.draw(draw) end

  -- Clear: clear shader and canvas
  love.graphics.setShader()
  love.graphics.setCanvas()
end

-- Canvas cache
---@type {c: love.Canvas, inUse: boolean}[]
local canvases = {}

-- Initialize some canvases to avoid possible lag during first creation
table.insert(canvases, {c = love.graphics.newCanvas(), inUse = false})
table.insert(canvases, {c = love.graphics.newCanvas(), inUse = false})
table.insert(canvases, {c = love.graphics.newCanvas(), inUse = false})

---@type Effect[]
local effects = {}

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

  ---@type fun(drawfunc: fun())
  -- Draws given draw function and then applies effects
  draw = function(drawfunc)
    ---@type fun()|love.Canvas
    local drawable = drawfunc
    local shdr
    local prepare

    for _, effect in ipairs(effects) do
      drawEffects(drawable, effect.canvas, shdr, prepare)
      shdr = effect.shader
      prepare = effect.prepare
      drawable = effect.canvas
    end

    drawEffects(drawable, nil, shdr, prepare)
  end,

  ---@param w number
  ---@param h number
  resize = function( w, h )
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
      c.c = love.graphics.newCanvas(w, h)

      -- update effect canvas to use resized one
      if e then e.canvas = c.c end
    end
  end
}

return screenEffects