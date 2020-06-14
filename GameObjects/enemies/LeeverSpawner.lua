local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local LD = require "GameObjects.FloorDetectors.landDetector"
local leever = require "GameObjects.enemies.leever"

local lp = love.physics

local detShape = love.physics.newCircleShape(48)

local LS = {}

function LS.initialize(instance)
  instance.avgLeeverTime = 1 --sec
  instance.leevers = 1 -- If they die, destroy self.
  instance.radius = 32
  instance.layer = 18
  instance.detectorShape = detShape
end

LS.functions = {
  resetTimer = function (self, extraTime)
    extraTime = extraTime or 0
    -- +- 20%
    local variance = extraTime + 0.4 * love.math.random() - 0.2
    self.timer = self.avgLeeverTime * (variance + 1)
  end,

  load = function (self)
    self:resetTimer()
    self.landTiles = {}
  end,

  onTilesFilled = function (self)
    if self.landTiles[1] then
      local randomTile = self.landTiles[love.math.random(1, #self.landTiles)]
      self.spawnedLeever = leever:new{
        xstart = randomTile.x, ystart = randomTile.y,
        x = randomTile.x, y = randomTile.y,
        layer = self.layer, creator = self
      }
      o.addToWorld(self.spawnedLeever)
    else
      -- If no water available, unpause and try again later
      self:resetTimer()
      self.pause = false
    end
  end,

  update = function (self, dt)

    if self.leevers < 1 then o.removeFromWorld(self) end
    if self.pause then return end
    self.timer = self.timer - dt
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.timer < 0 then
      -- if not self.wtiles then self.wtiles = o.identified.waterTile end
      -- local randomTile = self.wtiles[love.math.random(1, #wtiles)]
      -- -- Spawn leever on custom tile

      -- Empty water tiles, so the new object can use the table
      for i in ipairs(self.landTiles) do
        self.landTiles[i] = nil
      end

      local myLd = LD:new{
        x = self.target.x, y = self.target.y, creator = self
      }
      myLd.physical_properties.shape = self.detectorShape
      o.addToWorld(myLd)
      self.pause = true
      self:resetTimer()
    end
  end,
}

function LS:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(LS, instance, init) -- add own functions and fields
  return instance
end

return LS
