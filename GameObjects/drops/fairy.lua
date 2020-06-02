local ps = require "physics_settings"
local im = require "image"
local dc = require "GameObjects.Helpers.determine_colliders"
local p = require "GameObjects.prototype"
local snd = require "sound"
local o = require "GameObjects.objects"

local et = require "GameObjects.enemyTest"
local Wasp = require "GameObjects.enemies.wasp"

local Fairy = {}

function Fairy.initialize(instance)
  instance.damager = false
  instance.fairy = true
  instance.unpushable = true
  instance.notSolid = true
  instance.canBeBullrushed = false
  instance.sprite_info = im.spriteSettings.dropFairy
  -- instance.physical_properties.masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT, ENEMYATTACKCAT}
  instance.physical_properties.masks = {FLOORCOLLIDECAT, ENEMYATTACKCAT}
  instance.t = 0
  instance.attackDodger = true
  instance.inertiaDuration = 0
end

Fairy.functions = {
  early_update = function (self, dt)
    self.t = self.t + dt
  end,

  healPlaya = function (self, player, coll)
    if self.inertiaDuration > self.t then return end
    if self.healedPlaya then return end
    o.removeFromWorld(self)
    self.healedPlaya = true
    player:addHealth(8)
    snd.play(glsounds.getHeart)
    coll:setEnabled(false)
  end,

  beginContact = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.immasword then
      self.touchedBySword = other

      if self.touchedBySword and self.t > 0.2 and self.touchedBySword.creator then
        self:healPlaya(self.touchedBySword.creator, coll)
        return
      end
    end
  end,
}

function Fairy:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Wasp, instance) -- add parent functions and fields
  p.new(Fairy, instance, init) -- add own functions and fields
  return instance
end

return Fairy
