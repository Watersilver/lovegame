local dlg = require "dialogue"
local text = require "text"
local font = text.font
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local inp = require "input"
local game = require "game"

local Go = {}

function Go.initialize(instance)
  instance.layer = 21
  instance.text = love.graphics.newText(font.prstart)
  instance.text:set("Game Over")
end

Go.functions = {
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
    local drawx, drawy = mainCamera:getPosition()
    drawx = drawx - self.text:getWidth() * 0.5
    drawy = drawy - self.text:getHeight() * 0.5
    love.graphics.draw(self.text, drawx, drawy)
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
