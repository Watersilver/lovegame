local p = require "GameObjects.prototype"
local ps = require "physics_settings"
local o = require "GameObjects.objects"
local game = require "game"
local LD = require "GameObjects.FloorDetectors.landDetector"

local dc = require "GameObjects.Helpers.determine_colliders"

local Detector = {}

function Detector.initialize(instance)
end

Detector.functions = {

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if other.floor and not other.water and not other.gap and not other.occupied then
      -- Set creator on init
      if self.target then

        -- Insert in table only if aligned with target
        local alignedAtYDimension = self.target.y >= other.ystart - 8 and self.target.y <= other.ystart + 8
        local alignedAtXDimension = self.target.x >= other.xstart - 8 and self.target.x <= other.xstart + 8
        if alignedAtYDimension or alignedAtXDimension then
          table.insert(self.creator.landTiles, other)
        end

      end

    end
  end,

}

function Detector:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(LD, instance) -- add parent functions and fields
  p.new(Detector, instance, init) -- add own functions and fields
  return instance
end

return Detector
