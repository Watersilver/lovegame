local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local snd = require "sound"
local expl = require "GameObjects.explode"
local o = require "GameObjects.objects"
local drops = require "GameObjects.drops.drops"
local magic_dust_effects = require "GameObjects.Helpers.magic_dust_effects"

local dc = require "GameObjects.Helpers.determine_colliders"

local fT = require "GameObjects.floorTile"

local Tile = {}

function Tile.initialize(instance)
  instance.floorViscosity = "grass"
  instance.grass = 'Witch/defaultGrass'
  instance.physical_properties.masks = {1,2,3,4,5,6,7,8,9,10,11,12,14,16}
  instance.explosionSprite = {im.spriteSettings.grassDestruction}
  instance.explosionSound = {"Effects/Oracle_Bush_Cut"}
  instance.explosionSpeed = 0.3
end

Tile.functions = {
  [GCON.md.choose] = function (self, md)
    local r = GCON.md.reaction
    return u.chooseFromChanceTable{
      -- If you have nayrusWisdom, no explosions
      {value = r.boom, chance = md.poweredUp and 0 or 0.08},
      {value = r.kaboom, chance = md.poweredUp and 0 or 0.02},
      -- If you have nayrusWisdom, you may get healing instead
      {value = r.heart, chance = md.poweredUp and 0.08 or 0},
      {value = r.fairy, chance = md.poweredUp and 0.02 or 0},
      {value = r.fire, chance = 0.13},
      {value = r.ice, chance = 0.13},
      {value = r.wind, chance = 0.14},
      -- If you hit a wall, no magic block
      {value = r.block, chance = not md.hitSolid and 0.2 or 0},
      -- If you hit a wall, no decoy
      {value = r.decoy, chance = not md.hitSolid and 0.2 or 0},
      -- If none of the above happens, nothing happens
      {value = r.nothing, chance = 1},
    }
  end,

  [GCON.md.reaction.fire] = function (self)
    magic_dust_effects.burn(self)
  end,

  [GCON.md.reaction.wind] = function (self)
    magic_dust_effects.blow(self)
  end,

  [GCON.md.reaction.ice] = function (self)
    if self.image_index < 10 then
      snd.play(glsounds.ice)
    end
    if self.image_index == 0 or self.image_index == 2 or self.image_index == 84 then
      self.image_index = 84
    else
      self.image_index = 86
    end
  end,

  [GCON.md.cascade] = function () return true end,

  onWhirlwindStart = function (self)
    self:getDestroyed()
  end,

  onFireEnd = function (self)
    self.noExplosion = true
    self:getDestroyed()
  end,

  getDestroyed = function (self)
    if not self.grass then return end
    self.grass = nil
    self.floorViscosity = nil
    self.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,14,15,16)
    self.image_index = self.image_index + 1
    if not self.noExplosion then
      local explOb = expl:new{
        x = self.x or self.xstart, y = self.y or self.ystart,
        -- layer = self.layer+1,
        layer = 25,
        explosionNumber = 1,
        sprite_info = self.explosionSprite,
        image_speed = self.explosionSpeed,
        sounds = snd.load_sounds({explode = self.explosionSound})
      }
      o.addToWorld(explOb)
    end
    if self.drops then
      drops.custom(self.xexplode or self.xstart, self.yexplode or self.ystart, self.drops)
    else
      drops.cheapest(self.xstart, self.ystart)
    end
    self.beginContact = nil
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is a sword that is slashing, a bomb or a super sprint then cut the grass
    if other.immasword or other.immabombsplosion or (other.immasprint and not otherF:isSensor() and session.save.faroresCourage) then
      if not other.stab then
        self:getDestroyed()
      end
    end
  end
}

function Tile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(fT, instance) -- add parent functions and fields
  p.new(Tile, instance, init) -- add own functions and fields
  return instance
end

return Tile
