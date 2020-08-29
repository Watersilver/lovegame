local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local LD = require "GameObjects.FloorDetectors.landDetector"
local ALD = require "GameObjects.FloorDetectors.alignedLandDetector"
local robe = require "GameObjects.enemies.robe"

local lp = love.physics

local detShape = love.physics.newCircleShape(48)

local RS = {}

function RS.initialize(instance)
  instance.avgRobeTime = 1 --sec
  instance.robes = 1 -- If they die, destroy self.
  instance.radius = 32
  instance.layer = 18
  instance.detectorShape = detShape
  instance.detector = LD
end

RS.functions = {
  resetTimer = function (self, extraTime)
    extraTime = extraTime or 0
    -- +- 20%
    local variance = extraTime + 0.4 * love.math.random() - 0.2
    self.timer = self.avgRobeTime * (variance + 1)
  end,

  load = function (self)
    self:resetTimer()
    self.landTiles = {}
  end,

  onTilesFilled = function (self)
    if self.landTiles[1] then
      local randomTile = self.landTiles[love.math.random(1, #self.landTiles)]
      self.spawnedRobe = robe:new{
        xstart = randomTile.x, ystart = randomTile.y,
        x = randomTile.x, y = randomTile.y,
        layer = self.layer, creator = self
      }
      o.addToWorld(self.spawnedRobe)
    else
      -- If no land available, unpause and try again later
      self:resetTimer()
      self.pause = false
    end
  end,

  update = function (self, dt)

    if self.robes < 1 then o.removeFromWorld(self) end
    if self.pause then return end
    self.timer = self.timer - dt
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.timer < 0 then

      -- Empty tiles, so the new object can use the table
      for i in ipairs(self.landTiles) do
        self.landTiles[i] = nil
      end

      if self.target then
        local myLd

        if self.alignWithPlayer then
          myLd = ALD:new{
            x = self.target.x, y = self.target.y, creator = self,
            target = self.target
          }
        else
          myLd = LD:new{
            x = self.target.x, y = self.target.y, creator = self
          }
        end
        myLd.physical_properties.shape = self.detectorShape
        o.addToWorld(myLd)
      end
      self.pause = true
      self:resetTimer()
    end
  end,
}

function RS:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(RS, instance, init) -- add own functions and fields
  return instance
end

return RS
