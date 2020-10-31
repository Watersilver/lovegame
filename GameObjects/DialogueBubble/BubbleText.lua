local textLib = require "text"
local fonts = textLib.font
local u = require "utilities"

local transparentColour = {0, 0, 0, 0}

local BubbleText = {}

local methods = {
  setLength = function (self, length)
    bubbleText.length = math.floor(length)
  end,

  getWraplimit = function (self)
    return self.maxWidth / self.scale
  end,

  getWidth = function (self)
    return math.min(self.text:getWidth() * self.scale, self.maxWidth)
  end,

  getHeight = function (self)
    return math.min(self.text:getHeight() * self.scale, self.maxHeight * self.font:getHeight() * self.font:getLineHeight() * self.scale)
  end,

  getNextHeight = function (self)
    return self.lengthPlus1Text:getHeight() * self.scale
  end,

  updateLength = function (self, newLength)
    if self.length == newLength then return end
    self.length = newLength
    self.colouredString[1] = self.textRGBA
    self.colouredString[2] = string.sub(self.string, 0, self.length)
    self.colouredString[3] = transparentColour
    self.colouredString[4] = string.sub(self.string, self.length + 1)
    self.text:setf(self.colouredString, self:getWraplimit(), self.alignmode)

    -- Update visible text
    local lengthPlus1 = self.length + 1
    if lengthPlus1 > #self.string then
      if self.lp1length == #self.string then return end
      self.lp1length = #self.string
      self.lengthPlus1Text:setf(self.string, self:getWraplimit(), self.alignmode)
      return
    end
    local c = self.string:sub(lengthPlus1, lengthPlus1)
    if c == "" then
      if self.lp1length == 0 then return end
      self.lp1length = 0
      self.lengthPlus1Text:setf("", self:getWraplimit(), self.alignmode)
      return
    elseif string.match(c, "%S") == nil then
      for i = lengthPlus1, 1, -1 do
        local c = self.string:sub(i,i)
        if string.match(c, "%S") ~= nil then
          if self.lp1length == i then return end
          self.lp1length = i
          self.lengthPlus1Text:setf(string.sub(self.string, 0, i), self:getWraplimit(), self.alignmode)
          return
        end
      end
      if self.lp1length == 0 then return end
      self.lp1length = 0
      self.lengthPlus1Text:setf("", self:getWraplimit(), self.alignmode)
    end
    for i = lengthPlus1, #self.string do
      local c = self.string:sub(i,i)
      if string.match(c, "%S") == nil then
        if self.lp1length == i then return end
        self.lp1length = i
        self.lengthPlus1Text:setf(string.sub(self.string, 0, i - 1), self:getWraplimit(), self.alignmode)
        return
      end
    end
    if self.lp1length == #self.string then return end
    self.lp1length = #self.string
    self.lengthPlus1Text:setf(self.string, self:getWraplimit(), self.alignmode)
  end,

  draw = function (self, x, y, cam)
    local width, height = self:getWidth(), self:getHeight()
    local left, top = x - 0.5 * width, y - 0.5 * height
    local resetColour = u.storeColour()
    local sl, st = cam:toScreen(left, top)
    local sw, sh = cam:toScreen(left + width, top + height)
    sw, sh = sw - sl, sh - st
    love.graphics.setScissor(sl, st, sw, sh)
    u.changeColour{"white"}
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    -- love.graphics.clear(123, 0, 0, COLORCONST)
    -- Draw string loop
    love.graphics.draw(self.text, left, top + 0.5, 0, self.scale)
    love.graphics.setFont(prevFont)
    love.graphics.setScissor( )
    resetColour()
    -- fuck = self:getNextHeight() .. " / " .. height
  end,
}

function BubbleText.new(string, options)
  local bubbleText = {}
  for name, method in pairs(methods) do
    bubbleText[name] = method
  end
  options = options or {}
  local maxWidth, maxHeight, font, textRGBA =
    options.maxWidth, options.maxHeight,
    options.font, options.textRGBA
  bubbleText.font = fonts[font] or fonts.prstart
  bubbleText.string = string
  bubbleText.text = love.graphics.newText(bubbleText.font)
  bubbleText.lengthPlus1Text = love.graphics.newText(bubbleText.font)
  bubbleText.scale = options.scale or 0.2
  bubbleText.maxWidth = maxWidth or 100
  -- Height measured in lines
  bubbleText.maxHeight = maxHeight or 2
  if not textRGBA and options.color then
    textRGBA = u.getComplementaryColourList{options.color}
  end
  bubbleText.textRGBA = textRGBA or {0, 0, 0, COLORCONST}
  bubbleText.alignmode = "left"
  bubbleText.colouredString = {}
  bubbleText:updateLength(0)
  return bubbleText
end

return BubbleText
