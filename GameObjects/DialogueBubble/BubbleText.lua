local textLib = require "text"
local gamera  = require "gamera.gamera"
local fonts = textLib.font
local u = require "utilities"

local transparentColour = {0, 0, 0, 0}

local BubbleText = {}

---@class BubbleTextMethods
---@field new fun(content: string, options: any): BubbleTextMethods

---@class BubbleTextMethodsd
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
    local c = u.utf8_sub(self.string, length, length)
    if c == "" then
      if self.htLength == 0 then return end
      self.htLength = 0
      self.heightText:setf("", self:getWraplimit(), self.alignmode)
      return
    elseif string.match(c, "%S") == nil then
      for i = length, 1, -1 do
        local c = u.utf8_sub(self.string, i,i)
        if string.match(c, "%S") ~= nil then
          if self.htLength == i then return end
          self.htLength = i
          self.heightText:setf(u.utf8_sub(self.string, 0, i), self:getWraplimit(), self.alignmode)
          return
        end
      end
      if self.htLength == 0 then return end
      self.htLength = 0
      self.heightText:setf("", self:getWraplimit(), self.alignmode)
    end
    for i = length, #self.string do
      local c = u.utf8_sub(self.string, i,i)
      if string.match(c, "%S") == nil then
        if self.htLength == i then return end
        self.htLength = i
        self.heightText:setf(u.utf8_sub(self.string, 0, i - 1), self:getWraplimit(), self.alignmode)
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

  parseCol = function(self, col)
    if not col then return self.textRGBA end
    if u.utf8_sub(col.token, 5, 5) == '#' then
      return {
        tonumber(u.utf8_sub(col.token, 6, 6), 16) / 15,
        tonumber(u.utf8_sub(col.token, 7, 7), 16) / 15,
        tonumber(u.utf8_sub(col.token, 8, 8), 16) / 15,
        1
      }
    elseif u.utf8_sub(col.token, 5) == 'default' then
      return self.textRGBA
    end
  end,

  ---@return string
  getRevealedString = function (self)
    return self.revealedString
  end,

  ---@return number
  getLetterDelay = function (self)
    local delay = {pos = 0, delay = -1}
    for _, d in ipairs(self:getDelays()) do
      if d.pos <= self.length then
        if delay.pos <= d.pos then
          delay = d
        end
      end
    end
    return delay.delay
  end,

  getNextNonZeroDelayPosition = function (self)
    for _, d in ipairs(self:getDelays()) do
      if d.pos >= self.length and d.delay ~= 0 then
        return d.pos
      end
    end
    return #self.string
  end,

  getDelays = function (self)
    local delays = {}
    for _, v in ipairs(self.options.markup or {}) do
      if u.utf8_sub(v.token, 1,5) == "delay" then
        local split = u.split(v.token, ":")
        table.insert(delays, {delay = tonumber(split[2]), pos = v.atLength - 1})
      end
    end
    return delays
  end,

  updateLength = function (self, newLength)
    local maxLength = self:getMaxLength()
    if newLength >= maxLength then newLength = maxLength end
    if self.length == newLength then return end
    self.length = newLength

    local markup = self.options.markup or {}

    -- Determine colours
    -- Sort color tokens by encounter order
    local colToks = {}
    for _, m in pairs(markup) do
      if m.atLength <= self.length and u.utf8_sub(m.token, 1,3) == 'col' then
        table.insert(colToks, m)
      end
    end

    local cols = {{
      startPos = 1,
      endPos = 1,
      col = self.textRGBA
    }}
    for _, colTok in ipairs(colToks) do
      local l = colTok.atLength - 1
      cols[#cols].endPos = l
      if l >= self.length then break end
      table.insert(cols, {
        startPos = colTok.atLength,
        col = self:parseCol(colTok)
      })
    end
    cols[#cols].endPos = self.length
    table.insert(cols, {
      startPos = self.length + 1,
      col = transparentColour
    })

    local i = 1

    for _, col in ipairs(cols) do
      self.colouredString[i] = col.col
      -- At the moment we're done col.startPos will be bigger than string length
      -- if the utf8_sub clamps its i value it will cause a bug here
      self.colouredString[i + 1] = u.utf8_sub(self.string, col.startPos, col.endPos)
      i = i + 2
    end

    self.text:setf(self.colouredString, self:getWraplimit(), self.alignmode)
    self.revealedString = u.utf8_sub(self.string, 1, self.length)
    return u.utf8_sub(self.revealedString, #self.revealedString, #self.revealedString)
  end,

  draw = function (self, x, y, cam)
    local width, height = self:getWidth(), self:getHeight()
    local left, top = x - 0.5 * width, y - 0.5 * height
    local resetColour = u.storeColour()
    local sl, st = cam:toScreen(left, top)
    local sw, sh = cam:toScreen(left + width, top + height)
    sw, sh = sw - sl, sh - st
    gamera.setScissor(sl, st, sw, sh)
    -- This color gets combined with text colour
    -- Set to white to no modify text colour
    u.changeColour{"white"}
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    -- love.graphics.clear(123, 0, 0, 1)
    -- Draw string loop
    love.graphics.draw(self.text, left, top + 0.5 - self.yOffset, 0, self.scale)
    love.graphics.setFont(prevFont)
    love.graphics.setScissor()
    resetColour()
  end,
}

function BubbleText.new(string, options)
  local bubbleText = {}
  for name, method in pairs(methods) do
    bubbleText[name] = method
  end
  options = options or {}

  bubbleText.options = options
  local maxWidth, maxHeight, font, textRGBA =
    options.maxWidth, options.maxHeight,
    options.font, options.textRGBA
  bubbleText.font = fonts[font] or fonts.prstart
  bubbleText.yOffset = 0
  bubbleText.string = string
  bubbleText.revealedString = ""
  bubbleText.text = love.graphics.newText(bubbleText.font)
  bubbleText.heightText = love.graphics.newText(bubbleText.font)
  bubbleText.scale = options.scale or 0.2
  bubbleText.maxWidth = maxWidth or 100
  -- Height measured in lines
  bubbleText.maxHeight = maxHeight or 2
  if not textRGBA and options.color then
    textRGBA = u.getComplementaryColourList{options.color}
  end
  bubbleText.textRGBA = textRGBA or {0, 0, 0, 1}
  bubbleText.alignmode = "left"
  bubbleText.colouredString = {}
  bubbleText:updateLength(0)
  return bubbleText
end

return BubbleText
