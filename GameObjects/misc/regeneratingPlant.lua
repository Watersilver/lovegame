local im = require "image"
local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local u = require "utilities"
local dc = require "GameObjects.Helpers.determine_colliders"
local expl = require "GameObjects.explode"
local snd = require "sound"
local o = require "GameObjects.objects"
local drops = require "GameObjects.drops.drops"

local fT = require "GameObjects.floorTile"

local Plant = {}

function Plant.initialize(instance)
  instance.sprite_info = im.spriteSettings.regeneratingPlant
  instance.physical_properties = {
    bodyType = "static",
    fixedRotation = true,
    sensor = true,
    shape = ps.shapes.circleThreeFourths,
    masks = {1,2,3,4,5,6,7,8,9,10,11,12,14,16},
  }
  instance.image_speed = 0
  instance.seeThrough = true
  instance.layer = 13

  instance.timer = 0
  instance.image_index_float = 2
  instance.image_index = instance.image_index_float
  instance.attackDodger = true
  instance.cooldown = 10
end

Plant.functions = {
  update = function (self, dt)
    self.image_index = math.floor(self.image_index_float)

    if self.timer > 0 then
      self.timer = self.timer - dt
    else
      self.image_index_float = self.image_index_float + dt * self.sprite.frames
      if self.image_index_float > 2 then self.image_index_float = 2 end
    end
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is a sword that is slashing, a bomb or a super sprint then cut the grass
    if other.immasword or other.immabombsplosion or (other.immasprint and not otherF:isSensor() and session.save.faroresCourage) then
      if not other.stab and self.image_index == 2 then
        self.image_index_float = 0
        self.timer = self.cooldown
        local explOb = expl:new{
          x = self.x or self.xstart, y = self.y or self.ystart,
          -- layer = self.layer+1,
          layer = 25,
          explosionNumber = 1,
          sprite_info = {im.spriteSettings.bushDestruction},
          image_speed = 0.3,
          sounds = snd.load_sounds({explode = {"Effects/Oracle_Bush_Cut"}})
        }
        o.addToWorld(explOb)
        if self.drops then
          drops.custom(self.xexplode or self.xstart, self.yexplode or self.ystart, self.drops)
        end
      end
    end
  end
}

function Plant:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(fT, instance) -- add parent functions and fields
  p.new(Plant, instance, init) -- add own functions and fields
  return instance
end

return Plant
