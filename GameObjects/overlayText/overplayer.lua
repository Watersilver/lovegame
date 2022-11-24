local o = require "GameObjects.objects"
local p = require "GameObjects.prototype"
local OverlayText = require "GameObjects.overlayText.default"
local txt = require "text"
local utilities = require "utilities"

local Text = {}

local existing = {}

function Text.initialize(instance)
end

function Text.createNew(text, options)
  local t = Text:new()
  options = options or {}
  t.text = text or "text goes here"
  t.scale = options.scale or 0.1625
  t.timer = options.timer or 2.5
  t.textWidth = txt.font.default:getWidth(text) * t.scale

  table.insert(existing, t)

  o.addToWorld(t)
  return t
end

Text.functions = {
  getTop = function(self)
    local i = utilities.findIndex(existing, self)
    local next = existing[i + 1]
    if next and next.exists then
      return next:getTop() - self:getHeight() - 5
    end
    if pl1 and pl1.exists then
      return pl1.y - pl1.height - self:getHeight()
    end
    return 0
  end,

  updatePosition = function(self)
    if pl1 and pl1.exists then
      self.x = pl1.x - self.textWidth * 0.5
      self.y = self:getTop()
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

  delete = function (self)
    local i = utilities.findIndex(existing, self)
    if i ~= nil then
      table.remove(existing, i)
    end
  end
}

function Text:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(OverlayText, instance) -- add parent functions and fields
  p.new(Text, instance, init) -- add own functions and fields
  return instance
end

return Text
