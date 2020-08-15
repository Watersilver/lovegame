local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local WD = require "GameObjects.FloorDetectors.waterDetector"
local zora = require "GameObjects.enemies.zora"

local lp = love.physics

local defaultDetectorShape = love.physics.newCircleShape(160)

local ZS = {}

function ZS.initialize(instance)
  instance.avgZoraTime = 4 --sec
  instance.zoras = 1 -- If they die, destroy self.
  instance.radius = 32
  instance.layer = 18
  instance.detectorShape = defaultDetectorShape
end

ZS.functions = {
  resetTimer = function (self, extraTime)
    extraTime = extraTime or 0
    -- +- 20%
    local variance = extraTime + 0.4 * love.math.random() - 0.2
    self.timer = self.avgZoraTime * (variance + 1)
  end,

  load = function (self)
    self:resetTimer()
    self.waterTiles = {}
  end,

  onTilesFilled = function (self)
    if self.waterTiles[1] then
      local randomTile = self.waterTiles[love.math.random(1, #self.waterTiles)]
      -- local expl = (require "GameObjects.explode")
      -- expl.sink(randomTile)
      self.spawnedZora = zora:new{
        xstart = randomTile.x, ystart = randomTile.y,
        x = randomTile.x, y = randomTile.y,
        layer = self.layer, creator = self
      }
      o.addToWorld(self.spawnedZora)
    else
      -- If no water available, unpause and try again later
      self:resetTimer()
      self.pause = false
    end
  end,

  update = function (self, dt)

    if self.zoras < 1 then o.removeFromWorld(self) end
    if self.pause then return end
    self.timer = self.timer - dt
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.timer < 0 then
      -- if not self.wtiles then self.wtiles = o.identified.waterTile end
      -- local randomTile = self.wtiles[love.math.random(1, #wtiles)]
      -- -- Spawn zora on custom tile

      -- Empty water tiles, so the new object can use the table
      for i in ipairs(self.waterTiles) do
        self.waterTiles[i] = nil
      end

      if self.target then
        local myWd = WD:new{
          x = self.target.x, y = self.target.y, creator = self
        }
        myWd.physical_properties.shape = self.detectorShape
        o.addToWorld(myWd)
      end
      self.pause = true
      self:resetTimer()
    end
  end,
}

function ZS:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(ZS, instance, init) -- add own functions and fields
  return instance
end

return ZS
