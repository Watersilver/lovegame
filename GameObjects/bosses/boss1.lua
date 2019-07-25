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
local game = require "game"
local shdrs = require "Shaders.shaders"

local b1l = require "GameObjects.bosses.boss1laser"
local b1fo = require "GameObjects.bosses.boss1fallorb"

local hitShader = shdrs.enemyHitShader

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
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
    if instance.gotHit then
      instance.state:change_state(instance, dt, "hurt")
    elseif instance.haveHitWall then
      instance.haveHitWall = false
      instance.state:change_state(instance, dt, "changingDir")
    end
  end,
  end_state = function(instance, dt)
    instance.resting = false
    instance.hasCorneredPlayer = false
  end
  },

  changingDir = {
  run_state = function(instance, dt)
    instance.changingDirCounter = instance.changingDirCounter - dt
  end,
  start_state = function(instance, dt)
    instance.patrolDir = -instance.patrolDir
    if instance.resting then
      instance.changeDirNextState = "patrol"
    else
      if instance.hasCorneredPlayer then
        instance.changeDirNextState = "orbsAttack"
      else
        instance.changeDirNextState = "prepareLaser"
      end
    end
    -- instance.changeDirNextState = u.choose("patrol", "prepareLaser", 0.007)
    if instance.changeDirNextState ~= "patrol" then
      instance.changingDirCounter = -1
    else
      instance.changingDirCounter = 1
    end
  end,
  check_state = function(instance, dt)
    if instance.gotHit then
      instance.state:change_state(instance, dt, "hurt")
    elseif instance.changingDirCounter < 0 then
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
    instance.hasCorneredPlayer = true
    instance.laserDuration = 9.1 * 25 / instance.patrolSpeed
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

  orbsAttack = {
  run_state = function(instance, dt)
    -- staff position
    instance.sxtarget, instance.sytarget = instance.x+instance.sox * 0.7, instance.y+instance.soy + 3
    instance.staffTargetAngle = u.gradualAdjust(dt, instance.staffAngle, -90, 23)
    -- hand position
    instance.hxtarget, instance.hytarget = instance.x+instance.hox * 0.7, instance.y-5 + math.sin(instance.hth)
    -- decrease counter
    instance.orbsAttackCounter = instance.orbsAttackCounter - dt
  end,
  start_state = function(instance, dt)
    instance.handFrame = 1
    -- instance.orbsAttackCounter = 2
    instance.orbsAttackCounter = instance.hp - 0.5
    if not instance.orbAttacksNumber then
      instance.orbAttacksNumber = 4 - instance.hp
    end
    -- create orbs
    local rr, rc -- room rows, room collumns
    local tw = 16
    if game.room then
      rr, rc = game.room.width, game.room.height
    end
    if not rr or not rc then
      rr, rc = 16, 6
    else
      -- Convert width and height to rows and collumns and take terrain into account
      rr = (rr - tw * 2)/tw -- because of left and right walls
      rc = (rc - tw * 4)/tw -- because of upper and lower walls and gaps
    end
    local isOrbRow = love.math.random(0, 1)
    -- Many free spots. (Commented out is old one free spot)
    local possibleRows = {}
    for row = 2, rc do
      table.insert(possibleRows, row)
    end

    for i = 1, rr do
      -- Many free spots. (Commented out is old one free spot)
      u.shuffle(possibleRows)

      -- - tw * 0.5 to center
      o.addToWorld(b1fo:new{xstart = i * tw + tw - tw * 0.5, ystart = tw + tw * 3 - tw * 0.5})
      -- Many free spots. (Commented out is old one free spot)
      -- local freeSpot = love.math.random(2, rc)
      local numberOfFreeSpots = love.math.random(instance.hp)
      local freeSpots = {}
      for freeSpotNumber = 1, numberOfFreeSpots do
        freeSpots[possibleRows[freeSpotNumber]] = true
      end

      if isOrbRow == 1 then
        for j = 2, rc do
          -- Many free spots. (Commented out is old one free spot)
          -- if j ~= freeSpot then
          if not freeSpots[j] then
            -- local orb = b1fo:new{xstart = i * tw + tw - tw * 0.5, ystart = j * tw + tw * 3 - tw * 0.5}
            o.addToWorld(b1fo:new{xstart = i * tw + tw - tw * 0.5, ystart = j * tw + tw * 3 - tw * 0.5})
          end
        end
      end
      -- instance.patrolDir == 1 means I am preparing to move right
      -- wihch means I was moving LEFT. The opposite for -1
      if instance.orbAttacksNumber == 1 and ((i == rr and instance.patrolDir == 1) or (i == 1 and instance.patrolDir == -1)) then
        -- create liftable orb
        liftableOrb = b1fo:new{
          xstart = i * tw + tw - tw * 0.5,
          -- Many free spots. (Commented out is old one free spot)
          -- ystart = freeSpot * tw + tw * 3 - tw * 0.5,
          ystart = u.chooseKeyFromTable(freeSpots) * tw + tw * 3 - tw * 0.5,
          liftable = true
        }
        liftableOrb.sprite_info = {im.spriteSettings.boss1LiftableOrb}
        o.addToWorld(liftableOrb)
      end
      isOrbRow = 1 - isOrbRow
    end
  end,
  check_state = function(instance, dt)
    if instance.orbsAttackCounter < 0 then
      instance.state:change_state(instance, dt, "prepareLaser")
    end
  end,
  end_state = function(instance, dt)
    instance.handFrame = 0
    if instance.orbAttacksNumber == 1 then
      instance.resting = true
      instance.orbAttacksNumber = nil
    else
      instance.orbAttacksNumber = instance.orbAttacksNumber - 1
    end
  end
  },

  hurt = {
  run_state = function(instance, dt)
    instance.hurtCounter = instance.hurtCounter - dt
  end,
  start_state = function(instance, dt)
    instance.hurtCounter = 2
    instance.invulnerable = instance.hurtCounter
    instance.hp = instance.hp - 1
    instance.image_index = instance.hp == 0 and 3 or 1
  end,
  check_state = function(instance, dt)
    if instance.hurtCounter < 0 then
      instance.state:change_state(instance, dt, "patrol")
    end
  end,
  end_state = function(instance, dt)
    instance.hasCorneredPlayer = false
    instance.image_index = instance.hp == 0 and 3 or 0
  end
  }
}

local Boss1 = {}

function Boss1.initialize(instance)
  instance.grounded = false
  instance.levitating = true
  instance.sprite_info = im.spriteSettings.boss1TestSprites
  instance.hp = 3
  instance.pushback = true
  instance.shielded = true
  instance.shieldWall = true
  instance.facing = "down"
  instance.patrolDir = 1
  instance.physical_properties.shape = ps.shapes.bosses.boss1.body
  instance.spritefixture_properties.shape = ps.shapes.bosses.boss1.sprite
  instance.handFrame = 0
  instance.image_index = 0

  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
end

Boss1.functions = {
  load = function (self)
    self.x, self.y = self.body:getPosition()
    self.vx, self.vy = self.body:getLinearVelocity()
    self.handx, self.handy = self.x, self.y
    self.patrolSpeed = 55
    self.laserSpeedWhenOrbsExist = 25
    -- hand stuff
    self.hox, self.hoy = 15, 2 -- offsets
    self.handx, self.handy = self.handx+self.hox, self.handy+self.hoy -- position
    self.hxtarget, self.hytarget = self.handx, self.handy -- target position
    self.hth = 0 -- theta angle for hand sinoid offset
    self.handSpr = im.sprites["boss1/arevcyeqLH"]
    -- staff stuff (hahahahahahahahaaaaaaa)
    self.staffx, self.staffy = self.x, self.y
    self.sox, self.soy = -15, 2 -- offsets
    self.staffx, self.staffy = self.staffx+self.sox, self.staffy+self.soy -- position
    self.sxtarget, self.sytarget = self.staffx, self.staffy -- target position
    self.sth = 0 -- theta angle for staff spinning
    self.staffAngle = 0
    self.staffSpr = im.sprites["boss1/arevcyeqRH"]
  end,

  enemyUpdate = function (self, dt)
    if self.invulnerableEnd then
      self.shieldDown = false
      self.shieldWall = true
    end

    -- start determining hand target position
    self.hth = self.hth + dt * 2
    self.hxtarget, self.hytarget = self.x+self.hox, self.y + self.hoy + math.sin(self.hth) * 2
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

    -- Special boss shader handling
    if self.invulnerable then
      self.myShader = nil
      if math.floor(7 * self.invulnerable % 2) == 1 then
        self.myShader = hitShader
      end
    else
      self.myShader = nil
    end

    self.gotHit = false
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
    self.gotHit = true
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
    sprite.img, sprite[self.handFrame], self.handx, self.handy, 0,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)

    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end,

  delete = function (self)
    local ptl = require "GameObjects.portal"
    o.addToWorld(ptl:new{
      destination = "Rooms/newTilesTestRoom.lua",
      desx = 217,
      desy = 282,
      grounded = true,
      xstart = 32+8,
      ystart = 80+8,
      layer = 11,
      sprite_info = {im.spriteSettings.basicFriendlyInterior},
      image_index = 3+11*3
    })
  end
}

function Boss1:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss1, instance, init) -- add own functions and fields
  return instance
end

return Boss1
