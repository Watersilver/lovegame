local im = require "image"
local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local u = require "utilities"
local dc = require "GameObjects.Helpers.determine_colliders"
local expl = require "GameObjects.explode"
local snd = require "sound"
local o = require "GameObjects.objects"
local drops = require "GameObjects.drops.drops"
local magic_dust_effects = require "GameObjects.Helpers.magic_dust_effects"

local sL = require "GameObjects.softLiftable"

local function choose(self, md)
  local r = GCON.md.reaction
  return u.chooseFromChanceTable{
    -- If you have nayrusWisdom, no explosions
    {value = r.boom, chance = md.poweredUp and 0 or 0.08},
    {value = r.kaboom, chance = md.poweredUp and 0 or 0.02},
    -- If you have nayrusWisdom, you may get healing instead
    {value = r.heart, chance = md.poweredUp and 0.08 or 0},
    {value = r.fairy, chance = md.poweredUp and 0.02 or 0},
    {value = r.fire, chance = 0.13},
    {value = r.wind, chance = 0.14},
    -- If you hit a wall, no magic block
    {value = r.block, chance = not md.hitSolid and 0.2 or 0},
    -- If you hit a wall, no decoy
    {value = r.decoy, chance = not md.hitSolid and 0.2 or 0},
    -- If none of the above happens, nothing happens
    {value = r.nothing, chance = 1},
  }
end

local Plant = {}

function Plant.initialize(instance)
  instance.sprite_info = im.spriteSettings.regeneratingPlant
  instance.physical_properties.sensor = true
  instance.seeThrough = true
  instance.attackDodger = true
  instance.image_speed = 0
  instance.layer = 13
  instance.bombGoesThrough = true
  instance.ballbreaker = false
  instance.liftable = false

  instance.timeTillRegen = 0
  instance.image_index_float = 2
  instance.image_index = instance.image_index_float
  instance.cooldown = 3
end

Plant.functions = {
  [GCON.md.choose] = choose,

  [GCON.md.reaction.fire] = function (self)
    magic_dust_effects.burn(self)
  end,

  [GCON.md.reaction.wind] = function (self)
    magic_dust_effects.blow(self)
  end,

  [GCON.md.cascade] = function () return true end,

  onWhirlwindStart = function (self)
    self:die()
  end,

  onFireEnd = function (self)
    self:die(true)
  end,

  update = function (self, dt)
    self.image_index = math.floor(self.image_index_float)

    if self.image_index == 2 then
      self.liftable = true
      self.cantGrab = false
      self[GCON.md.choose] = choose
    else
      self.liftable = false
      self.cantGrab = true
      self[GCON.md.choose] = nil
    end

    if self.timeTillRegen > 0 then
      self.timeTillRegen = self.timeTillRegen - dt
    else
      self.image_index_float = self.image_index_float + dt * self.sprite.frames
      if self.image_index_float > 2 then self.image_index_float = 2 end
    end
  end,

  myDrops = function (selfOrThrown)
    if selfOrThrown.persistentData.drops then
      drops.custom(selfOrThrown.x, selfOrThrown.y, selfOrThrown.persistentData.drops)
    end
  end,

  on_replaced_by_lifted = function (self)
    local uprooted = Plant:new{
      xstart = self.x or self.xstart, ystart = self.y or self.ystart,
      x = self.x or self.xstart, y = self.y or self.ystart,
      image_index_float = 0,
      timeTillRegen = self.cooldown,
      drops = self.drops
    }
    o.addToWorld(uprooted)
    snd.play(glsounds.uproot)
  end,

  die = function (self, noExplosion)
    self.image_index_float = 0
    self.timeTillRegen = self.cooldown
    if not noExplosion then
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
    end
    self:myDrops()
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is a sword that is slashing, a bomb or a super sprint then cut the grass
    if other.immasword or other.immabombsplosion or (other.immasprint and not otherF:isSensor() and session.save.faroresCourage) then
      if not other.stab and self.image_index == 2 then
        self:die()
      end
    end
  end
}

function Plant:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(sL, instance) -- add parent functions and fields
  p.new(Plant, instance, init) -- add own functions and fields
  return instance
end

return Plant
