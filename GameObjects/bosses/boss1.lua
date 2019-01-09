local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local o = require "GameObjects.objects"

local b1l = require "GameObjects.bosses.boss1laser"

local Boss1 = {}

function Boss1.initialize(instance)
  instance.maxspeedcharge = 222
  instance.sprite_info = im.spriteSettings.boss1TestSprites
  instance.hp = 4 --love.math.random(3)
  instance.pushback = true
  instance.shielded = true
  instance.shieldWall = true
  instance.facing = "down"
  instance.sightWidth = 16
  instance.state = "patrol"
  instance.patrolDir = 1
  instance.changingDirCounter = 1
  instance.physical_properties.shape = ps.shapes.bosses.boss1.body
  instance.spritefixture_properties.shape = ps.shapes.bosses.boss1.sprite
end

Boss1.functions = {
  load = function (self)
    self.handx, self.handy = self.body:getPosition()
    self.patrolSpeed = 25
    -- hand stuff
    self.hox, self.hoy = 15, 2 -- offsets
    self.handx, self.handy = self.handx+self.hox, self.handy+self.hoy -- position
    self.hxtarget, self.hytarget = self.handx, self.handy -- target position
    self.hth = 0 -- theta angle for hand sinoid offset
    self.handSpr = im.sprites["arevcyeqLH"]
    -- staff stuff (hahahahahahahahaaaaaaa)
    self.staffx, self.staffy = self.body:getPosition()
    self.sox, self.soy = -15, 2 -- offsets
    self.staffx, self.staffy = self.staffx+self.sox, self.staffy+self.soy -- position
    self.sxtarget, self.sytarget = self.staffx, self.staffy -- target position
    self.sth = 0 -- theta angle for staff spinning
    self.staffAngle = 0
    self.staffSpr = im.sprites["arevcyeqRH"]
  end,

  enemyUpdate = function (self, dt)
    if self.invulnerableEnd then
      self.shieldDown = false
      self.shieldWall = true
    end

    -- start determining hand target position
    self.hth = self.hth + dt * 2
    self.hxtarget, self.hytarget = self.x+self.hox, self.y+self.hoy + math.sin(self.hth) * 2
    -- start determining staff target position
    self.sth = self.sth + dt
    self.sxtarget, self.sytarget = self.x+self.sox, self.y+self.soy
    local staffTargetAngle = self.staffAngle + math.sin(self.sth) * dt * love.math.random(7, 11)

    -- do stuff depending on state
    if self.state == "patrol" then
      self.body:setLinearVelocity(self.patrolDir * self.patrolSpeed, 0)
    elseif self.state == "changingDir" then
      if self.changingDirCounter < 0 then
        self.changingDirCounter = 1
        self.state = u.choose("patrol", "prepareLaser", 0.007)
        if self.state == "prepareLaser" then
          self.initialisedPreparingLaser = nil
        end
        self.patrolDir = -self.patrolDir
      end
      self.changingDirCounter = self.changingDirCounter - dt
    elseif self.state == "prepareLaser" then
      if not self.initialisedPreparingLaser then
        self.plphase = 1 -- preparing laser phase
        self.initialisedPreparingLaser = true
        self.prepareLaserCounter = 1
      end
      if self.plphase == 1 then
        self.sxtarget, self.sytarget = self.x, self.y+self.soy
        staffTargetAngle = u.gradualAdjust(dt, self.staffAngle, 90, 23)
        if self.staffAngle > 89.999999 then self.plphase = 2 end
      elseif self.plphase == 2 then
        self.sxtarget, self.sytarget = self.x, self.y+self.soy+10
        staffTargetAngle = u.gradualAdjust(dt, self.staffAngle, -135, 15)
        self.prepareLaserCounter = self.prepareLaserCounter - dt
        if self.prepareLaserCounter < 0 then
          self.laser = b1l:new{xstart = self.x, ystart = self.y + 15}
          o.addToWorld(self.laser)
          self.plphase = 3
          self.prepareLaserCounter = 1
        end
      elseif self.plphase == 3 then
        self.sxtarget, self.sytarget = self.x, self.y+self.soy+10
        staffTargetAngle = u.gradualAdjust(dt, self.staffAngle, -135, 15)
        self.prepareLaserCounter = self.prepareLaserCounter - dt
        if self.prepareLaserCounter < 0 then
          self.state = "laserAttack"
          self.laserDuration = 5 * 25 / self.patrolSpeed
        end
      end
      if self.state ~= "prepareLaser" then self.initialisedPreparingLaser = nil end
    elseif self.state == "laserAttack" then
      if self.laser then self.laser.body:setPosition(self.x, self.y + 15) end
      self.sxtarget, self.sytarget = self.x, self.y+self.soy+10
      staffTargetAngle = u.gradualAdjust(dt, self.staffAngle, -135, 15)
      self.laserDuration = self.laserDuration - dt
      if self.laserDuration < 0 then
        o.removeFromWorld(self.laser)
        self.laser = nil
      end
      self.body:setLinearVelocity(self.patrolDir * self.patrolSpeed, 0)
    end

    -- hand position:
    self.handx, self.handy = u.gradualAdjust2d(dt, self.handx, self.handy, self.hxtarget, self.hytarget, 15)
    -- staff position:
    self.staffx, self.staffy = u.gradualAdjust2d(dt, self.staffx, self.staffy, self.sxtarget, self.sytarget, 20)
    self.staffAngle = staffTargetAngle
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
    self.state = "changingDir"
    self.changingDirCounter = 1
  end,

  draw = function (self)
    et.functions.draw(self)

    local sprite = self.staffSpr
    love.graphics.draw(
    sprite.img, sprite[0], self.staffx, self.staffy, math.rad(self.staffAngle),
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)
    local sprite = self.handSpr
    love.graphics.draw(
    sprite.img, sprite[0], self.handx, self.handy, 0,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)

    love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end
}

function Boss1:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss1, instance, init) -- add own functions and fields
  return instance
end

return Boss1
