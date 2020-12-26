local o = require "GameObjects.objects"
local p = require "GameObjects.prototype"
local OverlayText = require "GameObjects.overlayText.default"
local u = require "utilities"
local txt = require "text"

local text = "Journal entry added"
local scale = OverlayText.scale
local scaleMod = 0.65
local textWidth = txt.font.default:getWidth(text) * scaleMod * scale
local textHeight = txt.font.default:getHeight() * scaleMod * scale

local Text = {}

function Text.initialize(instance)
  instance.text = text
  instance.scaleMod = scaleMod
  instance.timer = 2.5
end

Text.functions = {
  updatePosition = function(self)
    if pl1 and pl1.exists then
      self.x = pl1.x - textWidth * 0.5
      self.y = pl1.y - textHeight - pl1.height
    end
  end,

  unpausable_update = function (self, dt)
    self.timer = self.timer - dt
    if self.timer < 0 then o.removeFromWorld(self) end
    self:updatePosition()
  end,

  late_update = function (self)
    self:updatePosition()
  end,
}

function Text:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(OverlayText, instance) -- add parent functions and fields
  p.new(Text, instance, init) -- add own functions and fields
  return instance
end

return Text
