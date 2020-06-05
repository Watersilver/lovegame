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
    -- Make on init args when making instance
    -- shape = love.physics.newCircleShape(1)
    categories = {FLOORCOLLIDECAT},
    masks = {
      SPRITECAT,
      PLAYERATTACKCAT,
      ENEMYATTACKCAT,
      FLOORCOLLIDECAT,
      PLAYERJUMPATTACKCAT,
      PLAYERCAT,
      ROOMEDGECOLLIDECAT
    }
  }
  instance.seeThrough = true
end

Detector.functions = {
  load = function (self)
    -- Set x and y on init
    self.body:setPosition(self.x, self.y)
  end,

  update = function (self)
    if self.updatedOnce then
      o.removeFromWorld(self)
    end
    self.updatedOnce = true
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if other.water and not other.occupied then
      -- Set creator on init
      table.insert(self.creator.waterTiles, other)
    end
  end,

  -- draw = function (self)
  --   love.graphics.circle("line", self.x, self.y, self.fixture:getShape():getRadius())
  -- end,

  delete = function(self)
    self.creator:onTilesFilled()
  end
}

function Detector:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Detector, instance, init) -- add own functions and fields
  return instance
end

return Detector
