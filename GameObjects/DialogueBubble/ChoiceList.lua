local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local input = require "input"
local textLib = require "text"
local fonts = textLib.font
local u = require "utilities"
local snd = require "sound"

local ChoiceList = {}

function ChoiceList.addNew(choices, bubble)
  local init = {}

  init.choices = choices
  init.bubble = bubble

  local choiceList = ChoiceList:new(init)
  o.addToWorld(choiceList)
  return choiceList
end

function ChoiceList.initialize(instance)
  instance.scale = 0.2
  instance.padding = 2
  instance.animationDur = 0.1
  instance.yOffset = 24
end

ChoiceList.functions = {
  remove = function (self)
    o.removeFromWorld(self)
  end,

  moveCursor = function (self, dir)
    snd.play(glsounds.cursor)
    self.animation = dir
    self.aniTimer = 0
    self.animationProgress = 0
    if dir == "up" then self.cursor = self:getCursorAt(self.cursor - 1)
    else self.cursor = self:getCursorAt(self.cursor + 1) end
  end,

  getCursorAt = function (self, point)
    point = point % #self.choices
    if point == 0 then point = #self.choices end
    return point
  end,

  updateAnimationTimer = function (self, dt)
    self.animationProgress = self.aniTimer / self.animationDur
    self.aniTimer = self.aniTimer + dt
    if self.aniTimer > self.animationDur then self.animation = nil end
  end,

  load = function (self)
    self.cursor = 1
    self.font = fonts[self.font] or fonts.prstart
    self.animation = "start"
    self.aniTimer = 0
    self.animationProgress = 0
  end,

  early_update = function (self, dt)
    if not (pl1 and pl1.exists) then return end
    input.controllers[pl1.player].blocked = true
    input.escapeBlocked = true
    input.backspaceBlocked = true
  end,

  update = function (self, dt)
    local bubble = self.bubble

    -- Determine position
    self.x = bubble.x or self.x
    self.y = bubble.y or self.y
    if bubble and bubble.exists then
      self.x = self.x + (bubble.xOffset or 0)
      self.y = self.y + (bubble.height + self.yOffset) * bubble.positionMod
    end

    -- Handle input
    if self.animation then
      self:updateAnimationTimer(dt)
    else
      if input.upPressed then
        self:moveCursor("up")
      elseif input.downPressed then
        self:moveCursor("down")
      end
    end
  end,

  draw_overlay = function (self, cam)
    local resetColour = u.storeColour()
    local caml, camt, camw, camh = cam:getVisible()
    local maxWidth = 0
    for _, choice in ipairs(self.choices) do
      local cWidth = self.font:getWidth(choice)
      if cWidth > maxWidth then maxWidth = cWidth end
    end
    maxWidth = maxWidth * self.scale + 2 * self.padding + 4
    local x, y = self.x, self.y
    if x - maxWidth * 0.5 < caml then
      x = caml + maxWidth * 0.5
    elseif x + maxWidth * 0.5 > caml + camw then
      x = caml + camw - maxWidth * 0.5
    end
    if self.animation then
      local prog = self.animationProgress
      local anti = 1 - self.animationProgress
      if self.animation == "up" then
        -- Choice above
        self:drawChoice(x, y - self.yOffset * 0.6,
          self:getCursorAt(self.cursor - 1),
          0.7 - 0.2 * anti,
          0.5 - 0.25 * anti,
          -0.2
        )
        -- Choice Below
        self:drawChoice(x, y + self.yOffset * 0.6,
          self:getCursorAt(self.cursor + 1),
          0.7 + 0.2 * anti,
          0.5 + 0.25 * anti,
          -0.2 * prog
        )
        -- Current Choice
        local animYOff = 2
        self:drawChoice(x,
          y - animYOff * anti,
          self.cursor,
          0.9 + 0.1 * prog,
          0.9 + 0.1 * prog,
          -0.1 * anti
        )
        self:drawCursor(x, y)
      elseif self.animation == "down" then
        -- Choice above
        self:drawChoice(x, y - self.yOffset * 0.6,
          self:getCursorAt(self.cursor - 1),
          0.7 + 0.2 * anti,
          0.5 + 0.25 * anti,
          -0.2
        )
        -- Choice Below
        self:drawChoice(x, y + self.yOffset * 0.6,
          self:getCursorAt(self.cursor + 1),
          0.7 - 0.2 * anti,
          0.5 - 0.25 * anti,
          -0.2 * prog
        )
        -- Current Choice
        local animYOff = 2
        self:drawChoice(x,
          y + animYOff * anti,
          self.cursor,
          0.9 + 0.1 * prog,
          0.9 + 0.1 * prog,
          -0.1 * anti
        )
        self:drawCursor(x, y)
      else
        -- Choice above
        self:drawChoice(x, y - self.yOffset * 0.6,
          self:getCursorAt(self.cursor - 1), 0.7 * prog, 0.5 * prog, -0.2
        )
        -- Choice Below
        self:drawChoice(x, y + self.yOffset * 0.6,
          self:getCursorAt(self.cursor + 1), 0.7 * prog, 0.5 * prog, -0.2
        )
        -- Current Choice
        self:drawChoice(x, y, self.cursor, prog, prog)
        self:drawCursor(x, y, prog)
      end
    else
      -- Choice above
      self:drawChoice(x, y - self.yOffset * 0.6,
        self:getCursorAt(self.cursor - 1), 0.7, 0.5, -0.2
      )
      -- Choice Below
      self:drawChoice(x, y + self.yOffset * 0.6,
        self:getCursorAt(self.cursor + 1), 0.7, 0.5, -0.2
      )
      -- Current Choice
      self:drawChoice(x, y, self.cursor)
      self:drawCursor(x, y)
    end
    resetColour()
  end,

  drawCursor = function (self, x, y, a)
    a = a or 1
    local w2 = self.font:getWidth(self.choices[self.cursor]) * self.scale * 0.5 + self.padding * 0.7
    u.changeColour{"red", a = a * COLORCONST}
    love.graphics.polygon("fill",
      x - w2, y,
      x - (w2 + 2), y - 2,
      x - (w2 + 2), y + 2
    )
    love.graphics.polygon("fill",
      x + w2, y,
      x + (w2 + 2), y - 2,
      x + (w2 + 2), y + 2
    )
  end,

  drawChoice = function (self, x, y, index, scaleMod, alphaMod, sear)
    local choice = self.choices[index]
    local s = self.scale * (scaleMod or 1)
    local alpha = COLORCONST * (alphaMod or 1)
    -- local w = self.font:getWidth(choice) * s
    -- local h = self.font:getHeight() * s
    local w = self.font:getWidth(choice) * s
    local h = self.font:getHeight() * s

    u.changeColour{"black", a = alpha}
    local l, t = x - w * 0.5, y - h * 0.5
    local p = self.padding
    love.graphics.rectangle("fill", l - p, t - p, w + 2 * p, h + 2 * p, 2)
    u.changeColour{"white", a = alpha}
    -- love.graphics.print(choice, x, y, 0, s, s, w * 0.5, h * 0.5, sear or 0)
    love.graphics.print(choice, l, t, 0, s, s, 0, 0, sear)
  end
}

function ChoiceList:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(ChoiceList, instance, init) -- add own functions and fields
  return instance
end

return ChoiceList
