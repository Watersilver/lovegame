local dlg = require "dialogue"
local text = require "text"
local font = text.font
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local inp = require "input"
local game = require "game"
local snd = require "sound" -- to play game over music

local Go = {}

function Go.initialize(instance)
  instance.layer = 31
  instance.text = love.graphics.newText(font.prstart)
  instance.text:set("Game Over")
  instance.text2 = love.graphics.newText(font.prstart)
  instance.text2:set("Press Enter")
  instance.text2size = 0.5
end

Go.functions = {
  load = function (self)
    snd.bgm:load{"Music/GameOver"}
  end,

  update = function (self, dt)
    if inp.enterPressed and not self.pressed then
      self.pressed = true
      if self.player then
        self.player.transPersistent = nil
      end
      game.transition{
        type = "whiteScreen",
        progress = 0,
        roomTarget = "Rooms/main_menu.lua"
      }
    end
  end,

  draw = function (self)
    local camx, camy = mainCamera:getPosition()
    local drawx, drawy

    drawx = camx - self.text:getWidth() * 0.5
    drawy = camy - self.text:getHeight() * 0.5
    love.graphics.draw(self.text, drawx, drawy)

    local l, t, w, h = mainCamera:getVisible()
    drawx = camx - self.text2:getWidth() * 0.5 * self.text2size
    -- drawy = camy - self.text2:getHeight() * self.text2size * (-2.5)
    drawy = t + h * 1 - self.text2:getHeight() * self.text2size

    -- Store Colour
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(COLORCONST, COLORCONST*0.3, COLORCONST*0.1, COLORCONST*0.7)
    love.graphics.draw(self.text2, drawx, drawy, 0, self.text2size)

    -- Restore Colour
    love.graphics.setColor(r, g, b, a)
  end,

  trans_draw = function (self)
  end
}

function Go:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Go, instance, init) -- add own functions and fields
  return instance
end

return Go
