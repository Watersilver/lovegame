local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"

local dc = require "GameObjects.Helpers.determine_colliders"

local Projectile = {}

function Projectile.initialize(instance)
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
end

local function fireUpdate(self, dt)
  -- Remove if out of bounds
  if self.x + 5 < 0 or self.x - 5 > game.room.width then
    o.removeFromWorld(self)
  elseif self.y < -5 or self.y > game.room.height + 5 then
    o.removeFromWorld(self)
  end
  -- Swap x scale for effect
  self.fireTimer = self.fireTimer + dt * 30
  self.x_scale = u.sign(math.sin(self.fireTimer))
  if self.x_scale == 0 then self.x_scale = 1 end
end

Projectile.functions = {
  load = function (self)
    et.functions.load(self)
    if not self.holdFire then
      self:fire()
    end
    if self.enemFire then
      self.enemyUpdate = fireUpdate
      self.image_speed = 0.25
    end
  end,

  fire = function (self)
    self.body:setLinearVelocity(u.polarToCartesian(self.maxspeed, self.direction))
  end,

  enemyUpdate = u.emptyFunc,

  -- draw = function (self)
  --   et.functions.draw(self)
  --   -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end,

  hitBySword = function (self, other, myF, otherF)
    if not self.deflected and session.save.dinsPower then
      local msl = require "GameObjects.Items.missile"
      msl.getDeflected(self, other.creator, other)
      self.fired = true
      self.deflected = true
      if session.save.nayrusWisdom then
        self.immamissile = true
      end
    end
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  hitByBombsplosion = function (self, other, myF, otherF)
  end,

  hitByBullrush = function (self, other, myF, otherF)
  end,

  preSolve = function(self, a, b, coll, aob, bob)
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
