local text = require "text"
local font = text.font
local inp = require "input"
local sh = require "scaling_handler"
local u = require "utilities"

local max = math.max
local sin = math.sin

local setFont = love.graphics.setFont

local dialogue = {}

dialogue.textBox = {} -- Will hold the drawn textbox's left, top, width, height
local tb = dialogue.textBox

dialogue.enabled = false
dialogue.text = love.graphics.newText(font.prstart)
dialogue.choiceL = love.graphics.newText(font.prstart)
dialogue.choiceR = love.graphics.newText(font.prstart)
  dialogue.choiceL:set("Yes")
  dialogue.choiceR:set("No")
  dialogue.cursor = 0
dialogue.x = 0
dialogue.y = 0

local dlgBoxBorderH = 5
local dlgBoxBorderW = 25


-- Functions to be used in dialogue.simpleWallOfText
local function simpleWallOfTextDraw(l,t,w,h)
  local pr, pg, pb, pa = love.graphics.getColor()
  love.graphics.setColor(0, 0, 0, COLORCONST)
  love.graphics.rectangle("fill", l-1, t-1, w+1, h+1)
  love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
  -- setFont(dialogue.font) -- Use if dialogue text ISN'T text object
  love.graphics.draw(
    dialogue.text, -- Text or ColouredText (rgbtable1, text1, ...etc)
    dialogue.x, -- x
    dialogue.y, -- y
    dialogue.angle, -- angle
    dialogue.xscale, -- scaleX
    dialogue.yscale, -- scaleY
    dialogue.xoffset, -- Origin offset x
    dialogue.yoffset, -- Origin offset y
    dialogue.xshear, -- Shearing factor (x-axis) (Can be used for italics)
    dialogue.yshear) -- Shearing factor (y-axis)
  -- setFont(font.default) -- Use if dialogue text ISN'T text object
  love.graphics.setColor(0, 0, 0, COLORCONST)
  love.graphics.rectangle("fill", l-1, t-1, w+1, dlgBoxBorderH)
  love.graphics.rectangle("fill", l-1, t+h-dlgBoxBorderH, w+1, dlgBoxBorderH)

  local xsh, ysh -- Shape coordinates
  -- Arrows
  -- Downarrow
  love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, dialogue.downArrowAlpha)
  local xsh = l+w*0.98
  local ysh = t+h*0.7
  love.graphics.polygon("fill", xsh, ysh, xsh+5, ysh-5, xsh-5, ysh-5)
  -- Uparrow
  love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, dialogue.upArrowAlpha)
  xsh = l+w*0.98
  ysh = t+h*0.3
  love.graphics.polygon("fill", xsh, ysh-5, xsh+5, ysh, xsh-5, ysh)

  if dialogue.canSkip then
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, COLORCONST)
    xsh = l+w*0.98
    ysh = t+h*0.93
    love.graphics.circle("fill", xsh, ysh, dialogue.skipButtonRadius)
  end

  love.graphics.setColor(pr, pg, pb, pa)
end
-- Simple dialogue printing and controls, fit for reading signs letters etc.
dialogue.simpleWallOfText ={
  logic = function(dt)
    if inp.up then dialogue.y = dialogue.y + dt * 60 end
    if inp.down then dialogue.y = dialogue.y - dt * 60 end
    dialogue.canSkip = false
    dialogue.upArrowAlpha = COLORCONST
    dialogue.downArrowAlpha = COLORCONST
    dialogue.counter = dialogue.counter + dt * 5
    dialogue.skipButtonRadius = 3+0.2*sin(dialogue.counter)
    if dialogue.y + dialogue.height <= tb.h-dlgBoxBorderH then
      dialogue.y = tb.h-dlgBoxBorderH-dialogue.height
      dialogue.canSkip = true
      dialogue.downArrowAlpha = COLORCONST * 0.1
    end
    if dialogue.y >= dialogue.ystart then
      dialogue.y = dialogue.ystart
      dialogue.upArrowAlpha = COLORCONST * 0.1
    end
    if dialogue.canSkip and inp.enterPressed then
      dialogue.enabled = false
      dialogue.currentChoice = nil
      if dialogue.onDialogueEnd then dialogue.onDialogueEnd() end
    end
  end,
  draw = function(textCam)

    -- Before drawing ensure that the textbox won't cover the talker
    local gwsl, gwst, gwsw, gwsh = textCam:getWindow()
    local topOffset = 0
    local _, yta = mainCamera:toScreen(0, dialogue.yToAvoid)
    if yta > gwst and yta < gwst + gwsh then
      topOffset = 600
    end
    textCam:setWindow(gwsl, gwst - topOffset, gwsw, gwsh)

    textCam:draw(simpleWallOfTextDraw)

    -- restore the textbox to its proper place in
    -- case it changed to avoid covering the speaker
    textCam:setWindow(gwsl, gwst, gwsw, gwsh)
  end,
  setUp = function(text, yToAvoid, onDialogueEnd)
    dialogue.xscale = 0.5
    dialogue.yscale = 0.5
    dialogue.text:setFont(font.prstart)
    if type(text) == "string" then
      dialogue.text:set(text)
    elseif type(text[2]) == "number" then
      local wraplimit = text[2]
      if wraplimit < 0 then wraplimit = tb.w * 1.8 end
      dialogue.text:setf(text[1], wraplimit, text[3])
    else
      dialogue.text:set(text)
    end
    dialogue.x = dlgBoxBorderW
    -- Make sure you start at the begining of the dialogueBox
    dialogue.ystart = max(dialogue.text:getFont():getHeight() * 0.5, dlgBoxBorderH)
    dialogue.y = dialogue.ystart
    dialogue.angle = 0
    dialogue.xoffset = 0
    dialogue.yoffset = 0
    dialogue.xshear = 0
    dialogue.yshear = 0
    dialogue.yToAvoid = yToAvoid or 0
    dialogue.counter = 0
    dialogue.onDialogueEnd = onDialogueEnd
    dialogue.height = dialogue.text:getHeight() * dialogue.yscale
    dialogue.currentMethod = dialogue.simpleWallOfText
  end
}

dialogue.simpleBinaryChoice = {
  logic = function(dt)
    if inp.leftPressed then dialogue.cursor = dialogue.cursor - 1 end
    if inp.rightPressed then dialogue.cursor = dialogue.cursor + 1 end
    dialogue.cursor = u.clamp(0, dialogue.cursor, 1)
  end,

  draw = function(l,t,w,h)
    local pr, pg, pb, pa = love.graphics.getColor()
    local ts = sh.get_total_scale()
    local cbl, cbt, cbw, cbh = l+w*0.3, t+h*0.95, w*0.4, h*0.05 -- choice box
    local choiceAlpha = 0.3 * COLORCONST
    if dialogue.canSkip then
      choiceAlpha = COLORCONST
    end
    -- choice box
    love.graphics.setColor(0, 0, 0, choiceAlpha)
    love.graphics.rectangle("fill", cbl, cbt-1, cbw, cbh)
    -- cursor box
    love.graphics.setColor(0, COLORCONST*0.2, COLORCONST, choiceAlpha)
    local halfw = cbw * 0.5
    love.graphics.rectangle("line", cbl+dialogue.cursor * halfw, cbt-1, halfw, cbh)
    -- choice text
    love.graphics.setColor(COLORCONST, COLORCONST, COLORCONST, choiceAlpha)
    love.graphics.draw(
      dialogue.choiceL, -- Text or ColouredText (rgbtable1, text1, ...etc)
      cbl+cbw*0.02, -- x
      cbt+cbh*0.25, -- y
      0,
      ts*0.25
    )
    love.graphics.draw(
      dialogue.choiceR, -- Text or ColouredText (rgbtable1, text1, ...etc)
      cbl+cbw*0.52, -- x
      cbt+cbh*0.25, -- y
      0,
      ts*0.25
    )
    love.graphics.setColor(pr, pg, pb, pa)
  end,

  setUp = function(cleft, cright)
    dialogue.currentChoice = dialogue.simpleBinaryChoice
    dialogue.choiceL:set(cleft or "Yes")
    dialogue.choiceR:set(cright or "No")
    dialogue.text:setFont(font.prstart)
    dialogue.xscale = 0.5
    dialogue.yscale = 0.5
    dialogue.cursor = 0
  end
}

dialogue.currentMethod = dialogue.simpleWallOfText
dialogue.currentChoice = nil

return dialogue
