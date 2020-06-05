local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local game = require "game"

local dc = require "GameObjects.Helpers.determine_colliders"

local Detector = {}

function Detector.initialize(instance)
  instance.physical_properties = {
    bodyType = "dynamic",
    gravityScaleFactor = 0,
    sensor = true,
    density = 0,
    shape = ps.shapes.missile,
    categories = {FLOORCOLLIDECAT},
  }
  instance.seeThrough = true
end

Detector.functions = {
  load = function (self)
    self.body:setPosition(self.x, self.y)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if other.water then
      other.occupied = true
      o.removeFromWorld(self)
    end
  end,
}

function Detector:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Detector, instance, init) -- add own functions and fields
  return instance
end

return Detector
