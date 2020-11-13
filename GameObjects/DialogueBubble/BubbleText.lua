local textLib = require "text"
local fonts = textLib.font
local u = require "utilities"

local transparentColour = {0, 0, 0, 0}

local BubbleText = {}

local methods = {

  getLength = function (self)
    return self.length
  end,

  getMaxLength = function (self)
    return #self.string
  end,

  getWraplimit = function (self)
    return self.maxWidth / self.scale
  end,

  getWidth = function (self)
    return math.min(self.text:getWidth() * self.scale, self.maxWidth)
  end,

  getLineHeight = function (self)
    return self.font:getHeight() * self.font:getLineHeight() * self.scale
  end,

  getHeight = function (self)
    return math.min(self.text:getHeight() * self.scale, self.maxHeight * self:getLineHeight())
  end,

  getNextHeight = function (self)
    return self.heightText:getHeight() * self.scale
  end,

  getNextVisibleHeight = function (self)
    return self.heightText:getHeight() * self.scale - self.yOffset
  end,

  updateHeightTextLength = function (self, length)
    -- Update visible text
    local maxLength = self:getMaxLength()
    if length > maxLength then
      if self.htLength == maxLength then return end
      self.htLength = maxLength
      self.heightText:setf(self.string, self:getWraplimit(), self.alignmode)
      return
    end
    if length < 0 then length = 0 end
    local c = self.string:sub(length, length)
    if c == "" then
      if self.htLength == 0 then return end
      self.htLength = 0
      self.heightText:setf("", self:getWraplimit(), self.alignmode)
      return
    elseif string.match(c, "%S") == nil then
      for i = length, 1, -1 do
        local c = self.string:sub(i,i)
        if string.match(c, "%S") ~= nil then
          if self.htLength == i then return end
          self.htLength = i
          self.heightText:setf(string.sub(self.string, 0, i), self:getWraplimit(), self.alignmode)
          return
        end
      end
      if self.htLength == 0 then return end
      self.htLength = 0
      self.heightText:setf("", self:getWraplimit(), self.alignmode)
    end
    for i = length, #self.string do
      local c = self.string:sub(i,i)
      if string.match(c, "%S") == nil then
        if self.htLength == i then return end
        self.htLength = i
        self.heightText:setf(string.sub(self.string, 0, i - 1), self:getWraplimit(), self.alignmode)
        return
      end
    end
    if self.htLength == #self.string then return end
    self.htLength = #self.string
    self.heightText:setf(self.string, self:getWraplimit(), self.alignmode)
  end,

  setYOffset = function (self, newOffset)
    self.yOffset = newOffset
  end,

  getOffsetAfterScrollingOneLine = function (self)
    return self:getNextHeight() - 2 * self:getLineHeight() + 0.01 -- Last line is to fix occasional floating point error
  end,

  updateLength = function (self, newLength)
    local maxLength = self:getMaxLength()
    if newLength >= maxLength then newLength = maxLength end
    if self.length == newLength then return end
    self.length = newLength
    self.colouredString[1] = self.textRGBA
    local visibleStr = string.sub(self.string, 0, self.length)
    self.colouredString[2] = visibleStr
    self.colouredString[3] = transparentColour
    self.colouredString[4] = string.sub(self.string, self.length + 1)
    self.text:setf(self.colouredString, self:getWraplimit(), self.alignmode)
    return visibleStr:sub(#visibleStr, #visibleStr)
  end,

  draw = function (self, x, y, cam)
    local width, height = self:getWidth(), self:getHeight()
    local left, top = x - 0.5 * width, y - 0.5 * height
    local resetColour = u.storeColour()
    local sl, st = cam:toScreen(left, top)
    local sw, sh = cam:toScreen(left + width, top + height)
    sw, sh = sw - sl, sh - st
    love.graphics.setScissor(sl, st, sw, sh)
    -- This color gets combined with text colour
    -- SEt to white to no modify text colour
    u.changeColour{"white"}
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    -- love.graphics.clear(123, 0, 0, COLORCONST)
    -- Draw string loop
    love.graphics.draw(self.text, left, top + 0.5 - self.yOffset, 0, self.scale)
    love.graphics.setFont(prevFont)
    love.graphics.setScissor( )
    resetColour()
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
  bubbleText.yOffset = 0
  bubbleText.string = string
  bubbleText.text = love.graphics.newText(bubbleText.font)
  bubbleText.heightText = love.graphics.newText(bubbleText.font)
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
