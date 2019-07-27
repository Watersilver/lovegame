local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local snd = require "sound"
local expl = require "GameObjects.explode"
local o = require "GameObjects.objects"

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
  -- FLOORCOLLIDECAT = 13, PLAYERATTACKCAT = 15
end

Tile.functions = {

  beginContact = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- If other is a sword that is slashing then cut the grass
    if other.immasword then
      if not other.stab then
        self.grass = nil
        self.floorViscosity = nil
        myF:setMask(1,2,3,4,5,6,7,8,9,10,11,12,14,15,16)
        self.image_index = self.image_index + 1
        local explOb = expl:new{
          x = self.x or self.xstart, y = self.y or self.ystart,
          layer = self.layer+1,
          explosionNumber = 1,
          sprite_info = self.explosionSprite,
          image_speed = self.explosionSpeed,
          sounds = snd.load_sounds({explode = self.explosionSound})
        }
        o.addToWorld(explOb)
        self.beginContact = nil
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
