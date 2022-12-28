---@class Effect
---@field shader love.Shader
---@field canvas love.Canvas
---@field prepare? fun(shader: love.Shader)

---@type Effect[]
local effects = {}

---@param canvas? love.Canvas
---@param shader? love.Shader
---@param prepare? fun(shader: love.Shader)
---@param draw fun()|love.Canvas
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

local screenEffects = {
  ---@param shader love.Shader
  ---@param prepare? fun(shader: love.Shader)
  push = function(shader, prepare)
    ---@type love.Canvas?
    local canvas

    for _, c in ipairs(canvases) do
      if not c.inUse then
        canvas = c.c
        c.inUse = true
        print("reused canvas")
        break
      end
    end

    if not canvas then
      canvas = love.graphics.newCanvas()
      table.insert(canvases, {c = canvas, inUse = true})
    end

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
    for _, effect in ipairs(effects) do
      effect.canvas = love.graphics.newCanvas(w, h)
    end
  end
}

return screenEffects