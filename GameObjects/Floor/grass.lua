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


local function getDestroyed(self, other, myF, otherF)
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
  drops.cheapest(self.xstart, self.ystart)
  self.beginContact = nil
end

local function freeze(instance)
  if instance.image_index < 10 then
    snd.play(glsounds.ice)
  end
  if instance.image_index == 0 or instance.image_index == 2 or instance.image_index == 84 then
    instance.image_index = 84
  else
    instance.image_index = 86
  end
end

local function onMdustTouch(instance, other)
  local reaction = u.chooseFromChanceTable{
    -- chance of burning
    {value = freeze, chance = 0.25},
    -- chance of burning
    {value = other.createFire, chance = 0.5},
    -- If none of the above happens, nothing happens
    -- {value = nil, chance = 1},
  }
  if not reaction then return end
  if reaction == other.createFire then instance.onMdustTouch = nil end
  reaction(instance)
end


local Tile = {}

function Tile.initialize(instance)
  instance.floorViscosity = "grass"
  instance.grass = 'Witch/defaultGrass'
  instance.physical_properties.masks = {1,2,3,4,5,6,7,8,9,10,11,12,14,16}
  instance.explosionSprite = {im.spriteSettings.grassDestruction}
  instance.explosionSound = {"Effects/Oracle_Bush_Cut"}
  instance.explosionSpeed = 0.3
  instance.getDestroyed = getDestroyed
  instance.onMdustTouch = onMdustTouch
  -- FLOORCOLLIDECAT = 13, PLAYERATTACKCAT = 15
end

Tile.functions = {

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is a sword that is slashing, a bomb or a super sprint then cut the grass
    if other.immasword or other.immabombsplosion or (other.immasprint and not otherF:isSensor() and session.save.faroresCourage) then
      if not other.stab then
        getDestroyed(self, other, myF, otherF)
      end
    elseif other.immamdust and not other.hasReacted and self.onMdustTouch then
      other.hasReacted = true
      self.onMdustTouch(self, other)
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
