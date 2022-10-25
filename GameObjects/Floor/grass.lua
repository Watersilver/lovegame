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
  magicReaction = function (self, dust)
    local reaction = u.chooseFromChanceTable{
      -- chance of freezing
      {value = self.freeze, chance = 0.1},
      -- chance of burning
      {value = dust.createFire, chance = 0.1},
      -- chance of blown
      {value = dust.createWind, chance = 0.1},
      -- If none of the above happens, nothing happens
      -- {value = nil, chance = 1},
    }
    if not reaction then return false end
    if reaction == dust.createFire then self.nonReactive = true
    elseif reaction == dust.createWind then self:getDestroyed(nil, self.fixture) end
    reaction(self)
    return true
  end,

  getDestroyed = function (self, other, myF, otherF)
    self.grass = nil
    self.floorViscosity = nil
    myF:setMask(1,2,3,4,5,6,7,8,9,10,11,12,14,15,16)
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

  freeze = function (self)
    if self.image_index < 10 then
      snd.play(glsounds.ice)
    end
    if self.image_index == 0 or self.image_index == 2 or self.image_index == 84 then
      self.image_index = 84
    else
      self.image_index = 86
    end
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is a sword that is slashing, a bomb or a super sprint then cut the grass
    if other.immasword or other.immabombsplosion or (other.immasprint and not otherF:isSensor() and session.save.faroresCourage) then
      if not other.stab then
        self:getDestroyed(other, myF, otherF)
      end
    elseif
      other.immamdust -- react to dust
      and not other.hasReacted -- that hasn't reacted
      and not self.nonReactive -- if I am reactive
      and not session.getEquippedTargetlessFocus() -- and player doesn't have a targetless focus equipped
    then
      other.hasReacted = true
      if not self:magicReaction(other) then
        other.reactAnyway = true
        other.noFire = true
        other.noWind = true
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
