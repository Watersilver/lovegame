local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local sh = require "GameObjects.shadow"
local expl = require "GameObjects.explode"
local proj = require "GameObjects.enemies.projectile"
local u = require "utilities"
local o = require "GameObjects.objects"

local dc = require "GameObjects.Helpers.determine_colliders"

local Zora = {}

function Zora.initialize(instance)
  instance.maxspeed = 80
  instance.sprite_info = im.spriteSettings.zora
  instance.hp = 3 --love.math.random(3)
  instance.resetBehaviour = 0.5
  instance.physical_properties.shape = ps.shapes.circleHalf
  -- instance.physical_properties.categories = {FLOORCOLLIDECAT}
  instance.physical_properties.masks = {
    SPRITECAT,
    PLAYERATTACKCAT,
    ENEMYATTACKCAT,
    FLOORCOLLIDECAT,
    PLAYERJUMPATTACKCAT,
    PLAYERCAT,
    ROOMEDGECOLLIDECAT
  }
  instance.duration = 3
  instance.universalForceMod = 0

  instance.harmless = true
  instance.untouchable = true
  instance.attackDodger = true
end

Zora.functions = {
  enemyLoad = function (self)
    self.timer = 0
  end,

  destroy = function (self)
    self.creator.pause = false
    self.creator:resetTimer(self.duration - self.timer)
    if not self.sank then self.creator.zoras = self.creator.zoras - 1 end
    if self.zoraFire and not self.zoraFire.fired then
      o.removeFromWorld(self.zoraFire)
      self.zoraFire = nil
    end
  end,

  enemyUpdate = function (self, dt)
    self.target = session.decoy or pl1

    if self.timer > self.duration then
      self.sank = true
      expl.sink(self)
    elseif self.timer > self.duration * 0.87 then
      self.image_index = 2
    elseif self.timer > self.duration * 0.80 then
      if self.target and self.zoraFire and self.zoraFire.exists and not self.zoraFire.fired then
        -- Shoot at target
        -- Get target direction
        local _, dir = u.cartesianToPolar(self.target.x - self.x, self.target.y - self.y)
        self.zoraFire.direction = dir
        self.zoraFire:fire()
        self.zoraFire.fired = true
      end
    elseif self.timer > self.duration * 0.74 then
      -- Fire if you have target and you haven't fired yet
      if self.target and not self.zoraFire then
        self.zoraFire = proj:new{
          xstart = self.x, ystart = self.y,
          attackDmg = 2, layer = self.layer + 1,
          holdFire = true, enemFire = true
        }
        o.addToWorld(self.zoraFire)
      end
    elseif self.timer > self.duration * 0.66 then
      self.image_index = 3
    elseif self.timer > self.duration * 0.33 then
      self.image_index = 2
      self.fixture:setMask(SPRITECAT, ENEMYATTACKCAT)
      self.harmless = nil
      self.untouchable = nil
      self.attackDodger = nil
    else
      -- Get 0th or 1st frame
      self.image_index = math.sin(self.timer * 33) + 1
      if self.image_index == 2 then self.image_index = 1 end
    end

    self.timer = self.timer + dt
  end,

  enemyBeginContact = function (self, other)

    if other.water then
      other.occupied = other.occupied and other.occupied + 1 or 1
    end
  end,

  endContact = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    if other.water and other.occupied then
      other.occupied = other.occupied - 1
      if other.occupied < 1 then other.occupied = nil end
    end
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    coll:setEnabled(false)
  end,
}

function Zora:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Zora, instance, init) -- add own functions and fields
  return instance
end

return Zora
