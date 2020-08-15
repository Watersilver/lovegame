local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local LD = require "GameObjects.FloorDetectors.landDetector"
local blueHand = require "GameObjects.enemies.blueHand"

local lp = love.physics

local detShape = love.physics.newCircleShape(48)

local BHS = {}

function BHS.initialize(instance)
  instance.avgBlueHandTime = 1 --sec
  instance.blueHands = 1 -- If they die, destroy self.
  instance.radius = 32
  instance.layer = 18
  instance.detectorShape = detShape
end

BHS.functions = {
  resetTimer = function (self, extraTime)
    extraTime = extraTime or 0
    -- +- 20%
    local variance = extraTime + 0.4 * love.math.random() - 0.2
    self.timer = self.avgBlueHandTime * (variance + 1)
  end,

  load = function (self)
    self:resetTimer()
    self.landTiles = {}
  end,

  onTilesFilled = function (self)
    if self.landTiles[1] then
      local randomTile = self.landTiles[love.math.random(1, #self.landTiles)]
      self.spawnedBlueHand = blueHand:new{
        xstart = randomTile.x, ystart = randomTile.y,
        x = randomTile.x, y = randomTile.y,
        layer = self.layer, creator = self,
        destination = self.destination, -- Rooms/w100x100.lua for testing
        desx = self.desx, desy = self.desy -- 257 for testing
      }
      o.addToWorld(self.spawnedBlueHand)
    else
      -- If no water available, unpause and try again later
      self:resetTimer()
      self.pause = false
    end
  end,

  update = function (self, dt)

    if self.blueHands < 1 then o.removeFromWorld(self) end
    if self.pause then return end
    self.timer = self.timer - dt
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.timer < 0 then

      -- Empty water tiles, so the new object can use the table
      for i in ipairs(self.landTiles) do
        self.landTiles[i] = nil
      end

      if self.target then
        local myLd = LD:new{
          x = self.target.x, y = self.target.y, creator = self
        }
        myLd.physical_properties.shape = self.detectorShape
        o.addToWorld(myLd)
      end
      self.pause = true
      self:resetTimer()
    end
  end,
}

function BHS:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(BHS, instance, init) -- add own functions and fields
  return instance
end

return BHS
