local p = require "GameObjects.prototype"
local u = require "utilities"
local txt = require "text"

local Text = {}

Text.scale = 0.25

function Text.initialize(instance)
  instance.x = 0
  instance.y = 0
  instance.yoff = 0
  instance.scaleMod = 1
  instance.text = "erty"
end

local function printOutlinedText(txt, x, y, s)
  local resetColour = u.storeColour()
  local w = 2
  u.changeColour{"black"}
  love.graphics.print(txt, x, y, 0, s, s, -w, -w)
  love.graphics.print(txt, x, y, 0, s, s, 0, -w)
  love.graphics.print(txt, x, y, 0, s, s, w, -w)
  love.graphics.print(txt, x, y, 0, s, s, -w)
  love.graphics.print(txt, x, y, 0, s, s, w)
  love.graphics.print(txt, x, y, 0, s, s, -w, w)
  love.graphics.print(txt, x, y, 0, s, s, 0, w)
  love.graphics.print(txt, x, y, 0, s, s, w, w)
  u.changeColour{"white"}
  love.graphics.print(txt, x, y, 0, s)
  resetColour()
end

Text.functions = {
  draw_overlay = function (self)
    local restoreFont = txt.storeFont()
    love.graphics.setFont(txt.font.default)
    printOutlinedText(self.text, self.x, self.y, Text.scale * self.scaleMod)
    restoreFont()
  end
}

function Text:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Text, instance, init) -- add own functions and fields
  return instance
end

return Text
