local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local o = require "GameObjects.objects"
local sm = require "state_machine"

local b1l = require "GameObjects.bosses.boss1laser"

local Boss1 = {}

function Boss1.initialize(instance)
  instance.grounded = false
  instance.sprite_info = im.spriteSettings.boss1TestSprites
  instance.hp = 4 --love.math.random(3)
  instance.pushback = true
  instance.shielded = true
  instance.shieldWall = true
  instance.facing = "down"
  instance.patrolDir = 1
  instance.physical_properties.shape = ps.shapes.bosses.boss1.body
  instance.spritefixture_properties.shape = ps.shapes.bosses.boss1.sprite

  instance.state = sm.new_state_machine{
    state = "start",
    start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "patrol")
      end
    end,
    end_state = function(instance, dt)
    end
    },

    patrol = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(instance.patrolDir * instance.patrolSpeed, 0)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if instance.haveHitWall then
        instance.haveHitWall = false
        instance.state:change_state(instance, dt, "changingDir")
      end
    end,
    end_state = function(instance, dt)
    end
    },

    changingDir = {
    run_state = function(instance, dt)
      instance.changingDirCounter = instance.changingDirCounter - dt
    end,
    start_state = function(instance, dt)
      instance.changeDirNextState = u.choose("patrol", "prepareLaser", 0.007)
      if instance.changeDirNextState == "prepareLaser" then
        instance.changingDirCounter = -1
      else
        instance.changingDirCounter = 1
      end
    end,
    check_state = function(instance, dt)
      if instance.changingDirCounter < 0 then
        instance.patrolDir = -instance.patrolDir
        instance.state:change_state(instance, dt, instance.changeDirNextState)
      end
    end,
    end_state = function(instance, dt)
    end
    },

    prepareLaser = {
    run_state = function(instance, dt)
      if instance.plphase == 1 then
        instance.sxtarget, instance.sytarget = instance.x, instance.y+instance.soy
        instance.staffTargetAngle = u.gradualAdjust(dt, instance.staffAngle, 90, 23)
        if instance.staffAngle > 89.999999 then instance.plphase = 2 end
      elseif instance.plphase == 2 then
        instance.sxtarget, instance.sytarget = instance.x, instance.y+instance.soy+10
        instance.staffTargetAngle = u.gradualAdjust(dt, instance.staffAngle, -135, 15)
        instance.prepareLaserCounter = instance.prepareLaserCounter - dt
        if instance.prepareLaserCounter < 0 then
          instance.laser = b1l:new{xstart = instance.x, ystart = instance.y + 15}
          o.addToWorld(instance.laser)
          instance.plphase = 3
          instance.prepareLaserCounter = 1
        end
      elseif instance.plphase == 3 then
        instance.sxtarget, instance.sytarget = instance.x, instance.y+instance.soy+10
        instance.staffTargetAngle = u.gradualAdjust(dt, instance.staffAngle, -135, 15)
        instance.prepareLaserCounter = instance.prepareLaserCounter - dt
      end
    end,
    start_state = function(instance, dt)
      instance.plphase = 1 -- preparing laser phase
      instance.prepareLaserCounter = 1
    end,
    check_state = function(instance, dt)
      if instance.prepareLaserCounter < 0 and instance.plphase == 3 then
        instance.state:change_state(instance, dt, "laserAttack")
      end
    end,
    end_state = function(instance, dt)
    end
    },

    laserAttack = {
    run_state = function(instance, dt)
      if instance.laser then
        instance.laser.body:setPosition(instance.x, instance.y + 15)
        instance.sxtarget, instance.sytarget = instance.x, instance.y+instance.soy+10
        instance.staffTargetAngle = u.gradualAdjust(dt, instance.staffAngle, -135, 15)
      else
        instance.staffTargetAngle = u.gradualAdjust(dt, instance.staffAngle, instance.angleAfterAttack, 15)
      end
      instance.laserDuration = instance.laserDuration - dt
      if instance.laserDuration < 0 then
        o.removeFromWorld(instance.laser)
        instance.laser = nil
      end
      instance.body:setLinearVelocity(instance.patrolDir * instance.patrolSpeed, 0)
    end,
    start_state = function(instance, dt)
      instance.laserDuration = 5 * 25 / instance.patrolSpeed
      instance.angleAfterAttack = love.math.random(0,10) * 360
    end,
    check_state = function(instance, dt)
      if instance.haveHitWall then
        instance.haveHitWall = false
        instance.state:change_state(instance, dt, "changingDir")
      end
    end,
    end_state = function(instance, dt)
    end
    },
  }
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
    self.staffTargetAngle = self.staffAngle + math.sin(self.sth) * dt * love.math.random(7, 11)

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state[state.state].check_state(self, dt)
    -- Run animation state
    state[state.state].run_state(self, dt)

    -- hand position:
    self.handx, self.handy = u.gradualAdjust2d(dt, self.handx, self.handy, self.hxtarget, self.hytarget, 15)
    -- staff position:
    self.staffx, self.staffy = u.gradualAdjust2d(dt, self.staffx, self.staffy, self.sxtarget, self.sytarget, 20)
    self.staffAngle = self.staffTargetAngle
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
    -- self.state = "changingDir"
    -- self.changingDirCounter = 1
    self.haveHitWall = true
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
