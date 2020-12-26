local u = require "utilities"

love.keyboard.setKeyRepeat(true)

local text = {}

text.font = {
prstart = love.graphics.newFont("Fonts/PressStartFontFamily/prstart.ttf", 24),
prstartk = love.graphics.newFont("Fonts/PressStartFontFamily/prstartk.ttf", 24)
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

return text
