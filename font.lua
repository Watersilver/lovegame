local font = {}

font.prstart = love.graphics.newFont("Fonts/PressStartFontFamily/prstart.ttf", 24)
font.prstartk = love.graphics.newFont("Fonts/PressStartFontFamily/prstartk.ttf", 24)

font.default = font.prstart

love.graphics.setFont(font.default)

return font
