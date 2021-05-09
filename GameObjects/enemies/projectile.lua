local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"
local fire = require "GameObjects.fire"

local dc = require "GameObjects.Helpers.determine_colliders"
local bnd = require "GameObjects.bounceAndDie"

local Projectile = {}

function Projectile.initialize(instance)
  instance.doesntForceDir = true
  instance.levitating = true
  instance.maxspeed = 80
  instance.physical_properties.shape = ps.shapes.missile
  instance.direction = math.random()*2*math.pi
  instance.sprite_info = im.spriteSettings.fireMissile
  instance.hp = 1
  instance.vx, instance.vy = 0, 0
  instance.layer = 25
  instance.unpushable = true
  instance.canBeRolledThrough = false
  instance.canBeBullrushed = false
  instance.fireTimer = 0
  instance.dpDeflectable = true
  instance.doesntGoThroughSolids = false
  instance.getDestroyed = o.removeFromWorld
  instance.seeThrough = true
  instance.thrownGoesThrough = true
end

local function fireUpdate(self, dt)
  -- Swap x scale for effect
  self.fireTimer = self.fireTimer + dt * 30
  self.x_scale = u.sign(math.sin(self.fireTimer))
  if self.x_scale == 0 then self.x_scale = 1 end
end

local function boneUpdate(self, dt)
  if self.fired then
    self.angle = self.angleAfterDeflection
    self.xtraUpdate = nil
  else
    self.angle = self.angle + self.aVel
  end
end

local function boneBreak(self, howIGotDestroyed)

  bnd.quickBnD(self, {init = {xscaleReversalFreq = 0.1} })
  o.removeFromWorld(self)
  self.broken = true
  if howIGotDestroyed ~= "wall" then
    snd.play(glsounds.shieldDeflect)
  end

end

local function burn(self)
  self.dpDeflectable = false
  self.dpBreakable = false
  self.breakable = false
  self.undamageable = true
  self.notBreakableByMissile = true
  self.attackDodger = true
  self.invisible = true
  self.onFireEnd = self.onFireEnd or o.removeFromWorld
  local myfire = fire:new{
    x = self.x, y = self.y,
    layer = self.layer - 1,
    fuel = self
  }
  o.addToWorld(myfire)
  self.forceStill = true
  if not self.targetStart then return end
  self.body:setPosition(self.targetStart.x, self.targetStart.y)
end

Projectile.functions = {
  load = function (self)
    et.functions.load(self)

    if self.enemFire then
      self.xtraUpdate = fireUpdate
      self.image_speed = 0.25
    elseif self.enemBone then
      self.xtraUpdate = boneUpdate
      self.getDestroyed = boneBreak
      self.aVel = math.pi * 0.1
      self.angleAfterDeflection = u.choose(0, math.pi * 0.5)
      self.doesntGoThroughSolids = true
      self.dpDeflectable = false
      self.dpBreakable = true
    elseif self.enemRock then
      self.doesntGoThroughSolids = true
      self.dpDeflectable = false
      self.breakable = true
      self.getDestroyed = boneBreak
      self.maxspeed = 100
    elseif self.dragonFire then
      self.onReachTarget = burn
      self.image_speed = 0.25
    end

    if not self.holdFire then
      self:fire()
    end
  end,

  fire = function (self)

    -- Determine direction if fed facing
    if self.facing then
      if self.facing == "up" then
        self.direction = -math.pi * 0.5
      elseif self.facing == "down" then
        self.direction = math.pi * 0.5
      elseif self.facing == "left" then
        self.direction = math.pi
      elseif self.facing == "right" then
        self.direction = 0
      end
    end

    -- Determine direction if fed target
    if self.target then
      local _, direction = u.cartesianToPolar(self.target.x - self.x, self.target.y - self.y)
      self.direction = direction
      self.reachedTarget = false
      self.tarDis = u.magnitude2d(self.target.x - self.x, self.target.y - self.y)
      self.targetStart = {
        x = self.target.x,
        y = self.target.y
      }
    end

    self.body:setLinearVelocity(u.polarToCartesian(self.maxspeed, self.direction))
  end,

  enemyUpdate = function (self, dt)
    -- Remove if out of bounds
    if self.x + 5 < 0 or self.x - 5 > game.room.width then
      o.removeFromWorld(self)
    elseif self.y < -5 or self.y > game.room.height + 5 then
      o.removeFromWorld(self)
    end
    if self.xtraUpdate then self.xtraUpdate(self, dt) end
    if self.targetStart then
      -- fire
      local newTarDis = u.magnitude2d(self.targetStart.x - self.x, self.targetStart.y - self.y)
      if not self.reachedTarget and newTarDis > self.tarDis then
        self.reachedTarget = true
        if self.onReachTarget then self:onReachTarget() end
      end
      self.tarDis = newTarDis
    end
    if self.forceStill then
      self.body:setLinearVelocity(0, 0)
    end
  end,

  -- draw = function (self)
  --   et.functions.draw(self)
  --   -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end,

  hitSolidStatic = function (self, other, myF, otherF, coll)
    if other.roomEdge then return end
    if self.doesntGoThroughSolids and not self.broken then

      self:getDestroyed("wall");

    end
  end,

  hitBySword = function (self, other, myF, otherF)
    if self.dpDeflectable and (not self.deflected and session.save.dinsPower) then
      local msl = require "GameObjects.Items.missile"
      msl.getDeflected(self, other.creator, other)
      self.fired = true

      -- Can only hit enemies with the deflected
      -- msl if you have nayru's wisdom
      if session.save.nayrusWisdom then
        self.immamissile = true
      end
    elseif self.breakable or (self.dpBreakable and (not self.broken and session.save.dinsPower)) then

      self:getDestroyed("sword");

    end
  end,

  hitByMissile = function (self, other, myF, otherF, coll)
    if self.notBreakableByMissile then return end
    if session.save.nayrusWisdom then
      self:getDestroyed("missile");
    end
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  hitByBombsplosion = function (self, other, myF, otherF)
  end,

  hitByBullrush = function (self, other, myF, otherF)
  end,

  preSolve = function(self, a, b, coll, aob, bob)
    -- if self.dontInteractWithMissile then
    --   coll:setEnabled(false)
    --   return
    -- end
    coll:setEnabled(false)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
  end,
}

function Projectile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Projectile, instance, init) -- add own functions and fields
  return instance
end

return Projectile
