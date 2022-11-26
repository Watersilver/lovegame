local p = require "GameObjects.prototype"
local u = require "utilities"
local txt = require "text"

local Text = {}

function Text.initialize(instance)
  instance.x = 0
  instance.y = 0
  instance.yoff = 0
  instance.scaleMod = 1
  instance.text = love.graphics.newText(txt.font.default)
end

local w = 2
local function printOutlinedText(text, x, y, s)
  local resetColour = u.storeColour()
  u.changeColour{"black"}
  love.graphics.draw(text, x, y, 0, s, s, -w, -w)
  love.graphics.draw(text, x, y, 0, s, s, 0, -w)
  love.graphics.draw(text, x, y, 0, s, s, w, -w)
  love.graphics.draw(text, x, y, 0, s, s, -w)
  love.graphics.draw(text, x, y, 0, s, s, w)
  love.graphics.draw(text, x, y, 0, s, s, -w, w)
  love.graphics.draw(text, x, y, 0, s, s, 0, w)
  love.graphics.draw(text, x, y, 0, s, s, w, w)
  u.changeColour{"white"}
  love.graphics.draw(text, x, y, 0, s)
  resetColour()
end

Text.functions = {
  getHeight = function (self)
    return self.text:getHeight() * self.scale
  end,

  getWidth = function (self)
    return (self.wraplimit or self.text:getWidth()) * self.scale
  end,

  setText = function (self, text)
    self.raw = text
    if self.wraplimit then
      self.text:setf(text, self.wraplimit, "center")
    else
      self.text:set(text)
    end
  end,

  setWraplimit = function (self, newLimit)
    self.wraplimit = newLimit
    self:setText(self.raw)
  end,

  draw_overlay = function (self)
    printOutlinedText(self.text, self.x, self.y, self.scale)
  end
}

function Text:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Text, instance, init) -- add own functions and fields
  return instance
end

return Text
