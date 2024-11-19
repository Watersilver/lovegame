require 'image' -- This is here to ensure scaling filters are set before fonts get created

love.keyboard.setKeyRepeat(true)

local text = {}

text.font = {
prstart = love.graphics.newFont("Fonts/PressStartFontFamily/prstart.ttf", 24),
prstartk = love.graphics.newFont("Fonts/PressStartFontFamily/prstartk.ttf", 24),
tiny = love.graphics.newFont("Fonts/teeny-tiny-pixls-font/TeenyTinyPixls-o2zo.ttf", 5)
}

text.font.prstart:setLineHeight(1.5)

text.font.default = text.font.prstart
love.graphics.setFont(text.font.default)

text.input = ""
text.inputLim = 10

text.key = ""

text.storeFont = function()
  local storedFont = love.graphics.getFont()
  return function() love.graphics.setFont(storedFont) end
end

---@param font love.Font
---@param action fun()
text.withFont = function(font, action)
  local prevFont = love.graphics.getFont()
  love.graphics.setFont(font)
  action()
  love.graphics.setFont(prevFont)
end

return text
