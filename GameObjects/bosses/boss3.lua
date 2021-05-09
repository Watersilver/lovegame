local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local gsh = require "gamera_shake"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local sm = require "state_machine"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"
local expl = require "GameObjects.explode"

local shdrs = require "Shaders.shaders"
local hitShader = shdrs.enemyHitShader
local deathShader = shdrs.bossDeathShader

local proj = require "GameObjects.enemies.projectile"

local pi = math.pi

local function onFireEnd(fuel)
  o.removeFromWorld(fuel)
  if o.identified.blastSeedDrop and #o.identified.blastSeedDrop >= 2 then return end
  local drops = require "GameObjects.drops.drops"
  drops.custom(fuel.x, fuel.y, {
    {chance = 0.05, value = "blastSeed"}
  })
end

local animationTable = {
  wingsOpen = {0,1,2,3,4,5,12,14,16},
  wingsClosed = {6,7,8,9,10,11,13,15,17},
  leftLegUp = {0,2,4,6,8,10},
  rightLegUp = {1,3,5,7,9,11},
  inTheAir = {12,13,14,15,16,17},
  mouthClosed = {0,1,6,7,12,13},
  mouthHalfOpen = {2,3,8,9,14,15},
  mouthOpen = {4,5,10,11,16,17},
  -- charge 18, still 19, bush 20

  init = function (self)
    if self.initialized then return end
    self.initialized = true
    local subtables = {}
    for subtable, value in pairs(self) do
      if type(value) == "table" then
        table.insert(subtables, subtable)
      end
    end
    for i = 0, 17 do
      self[i] = {}
    end
    for _, subtable in ipairs(subtables) do
      for _, index in ipairs(self[subtable]) do
        self[index][subtable] = true
      end
    end
  end,

  getStateIndex = function (self, state)
    -- narrow possible indexes down to one
    local possibleIndexes = {}
    for _, mouthIndex in ipairs(self[state.mouth]) do
      table.insert(possibleIndexes, mouthIndex)
    end
    for _, possibleIndex in ipairs(possibleIndexes) do
      if self[possibleIndex][state.legs] and self[possibleIndex][state.wings] then
        return possibleIndex
      end
    end
    return 20
  end
}
animationTable:init()

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "bush")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  bush = {
    run_state = function(instance, dt)
      instance.stateTimer = instance.stateTimer - dt
      if instance.stateTimer < 0 then instance.stateTimer = 0 end
      local preStateProg = instance.stateProg

      if instance.stateProg == 0 then
        if pl1 and pl1.x and u.magnitude2d(pl1.x - instance.x, pl1.y - instance.y) < 67 then
          instance.stateProg = 1
          instance.stateTimer = 1
        end
      elseif instance.stateProg == 1 then
        if instance.stateTimer == 0 then
          instance.body:setLinearVelocity(0, 0)
          instance.stateProg = 2
          instance.stateTimer = 0.5
        else
          instance.body:setLinearVelocity(100*math.sin(instance.stateTimer * 100), 0)
        end
      elseif instance.stateProg == 2 then
        if instance.stateTimer == 0 then
          instance.stateProg = 3
          instance.image_index_override = nil
          for _ = 1, 25 do
            local explInst = {
              x = love.math.random(-24, 10) + (instance.x or instance.xStart),
              y = love.math.random(-25, 29) + (instance.y or instance.yStart),
              layer = instance.layer,
              explosionSpeed = 0.2
            }
            expl.commonExplosion(explInst, im.spriteSettings.bushDestruction, {"Effects/Oracle_Bush_Cut"})
          end
        end
      elseif instance.stateProg == 3 then
        -- init
        if instance.stateProgChange then
          instance.wingTimer = 0
          instance.wingTimerSpeedFactor = 1
          instance.wingFlaps = 0
          instance.mouthTimer = 2
        end

        instance.wingTimer = instance.wingTimer + dt * instance.wingTimerSpeedFactor

        -- determine animation state
        if instance.wingTimer > 0.5 then
          instance.wingTimer = 0
          if instance.animationState.wings == "wingsClosed" then
            instance.animationState.wings = "wingsOpen"
          else instance.animationState.wings = "wingsClosed" end
        end

        -- Apply effects of animation state
        if instance.animationState.wings == "wingsClosed" and instance.animationState.wings ~= instance.animStatePrev.wings then
          snd.play(glsounds.dragonWingFlap)
          instance.wingFlaps = instance.wingFlaps + 1
        end

        if instance.wingFlaps < 3 and instance.animationState.wings == "wingsClosed" then
          instance.zo = instance.zo - dt * 40
        end

        if instance.wingFlaps > 2 then
          instance.wingTimerSpeedFactor = 2
          instance.mouthTimer = instance.mouthTimer - dt
        end
        if instance.mouthTimer < 0.45 then
          instance.animationState.mouth = "mouthOpen"
        elseif instance.mouthTimer < 0.60 then
          instance.animationState.mouth = "mouthHalfOpen"
        elseif instance.mouthTimer < 0.75 then
          instance.animationState.mouth = "mouthClosed"
        end

        if instance.wingFlaps > 7 then
          instance.stateProg = 4
        end

        if instance.animationState.mouth == "mouthOpen" and instance.animationState.mouth ~= instance.animStatePrev.mouth then
          snd.play(glsounds.dragonRoar)
        end

      elseif instance.stateProg == 4 then
        if instance.stateProgChange then
          instance.stateTimer = 1.5
          instance.wingTimer = 0
        end
        instance.zo = instance.zo - dt * 200

        instance.wingTimer = instance.wingTimer + dt * 4

        -- determine animation state
        if instance.wingTimer > 1 then
          instance.wingTimer = 0
          if instance.animationState.wings == "wingsClosed" then
            instance.animationState.wings = "wingsOpen"
          else instance.animationState.wings = "wingsClosed" end
        end

        -- Apply effects of animation state
        if instance.animationState.wings == "wingsClosed" and instance.animationState.wings ~= instance.animStatePrev.wings then
          snd.play(glsounds.dragonWingFlap)
          instance.wingFlaps = instance.wingFlaps + 1
        end

        if instance.stateTimer == 0 then
          instance.stateProg = 5
        end
      end

      instance.stateProgChange = preStateProg ~= instance.stateProg
    end,
    start_state = function(instance, dt)
      instance.image_index_override = 20
      instance.animationState = {
        wings = "wingsOpen",
        mouth = "mouthHalfOpen",
        legs = "inTheAir"
      }
      instance.stateTimer = 0
      instance.stateProg = 0
      instance.cutscene = true
      -- dragonWingFlap
    end,
    check_state = function(instance, dt)
      if instance.stateProg == 5 then
        instance.state:change_state(instance, dt, "offscreen")
      end
    end,
    end_state = function(instance, dt)
      instance.cutscene = false
      game.room.music_info = "SoMBelieveinVictory"
      snd.bgmV2.getMusicAndload()
      instance.offscreenTime = 0
    end
  },

  offscreen = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(0, 0)
      instance.offscreenTime = instance.offscreenTime - dt
      if instance.offscreenTime < 0 then instance.offscreenTime = 0 end
    end,
    start_state = function(instance, dt)
      instance.body:setPosition(-299, -299)
      instance.x, instance.y = -299, -299
      instance.zo = -299

      -- Randomly determine next pattern and time until next pattern
      instance.pattern = u.chooseFromWeightTable{
        {weight = 1, value = "chase"},
        {weight = 1, value = "sweep"},
        {weight = 1, value = "manyjump"},
        {weight = 1, value = "charge"}
      }
      if not instance.offscreenTime then
        instance.offscreenTime = love.math.random() * 2 + 0.5
      end
    end,
    check_state = function(instance, dt)
      if instance.offscreenTime == 0 then
        instance.state:change_state(instance, dt, instance.pattern)
      end
    end,
    end_state = function(instance, dt)
      instance.offscreenTime = nil
    end
  },

  chase = {
    run_state = function(instance, dt)
      local prevStateTimer = instance.stateTimer

      instance.stateTimer = instance.stateTimer - dt
      if instance.stateTimer < 0 then instance.stateTimer = 0 end

      local prevSubstate = instance.substate

      if instance.substate == 0 then
        if instance.zo >= 0 then
          -- If I'm not in the air just start walking
          instance.substate = 4
        else
          -- Do warning sound
          if prevStateTimer >= 1 and instance.stateTimer < 1 or
          prevStateTimer >= 0.3 and instance.stateTimer < 0.3 or
          prevStateTimer >= 0.2 and instance.stateTimer < 0.2 or
          prevStateTimer >= 0.1 and instance.stateTimer < 0.1
          then
            snd.play(glsounds.dragonWingFlap)
          end
          if instance.stateTimer == 0 then
            instance.substate = 1
            instance.animationState.wings = "wingsOpen"
            instance.animationState.legs = "inTheAir"
            instance.animationState.mouth = "mouthHalfOpen"
          end
        end
      elseif instance.substate == 1 then
        if instance.substateChanged then
          instance.body:setPosition(instance.target.x, instance.target.y - instance.shadowHeightMod)
          instance.wingSpeed = 2
        end

        instance:lookAtTarget()

        instance.zo = instance.zo + dt * 100
        if instance.zo >= -30 then
          instance.zo = -30
          instance.substate = 2
        end
      elseif instance.substate == 2 then
        if instance.substateChanged then
          instance.wingSpeed = 4
          instance.stateTimer = 1
        end

        instance:lookAtTarget()

        if instance.stateTimer == 0 then instance.substate = 3 end
      elseif instance.substate == 3 then
        if instance.substateChanged then
          instance.wingSpeed = math.pi
          instance.mouthSpeed = 2
        end

        instance.zo = instance.zo + dt * 25

        instance:lookAtTarget()

        if instance.zo >= 0 then
          instance.zo = 0
          instance.substate = 4
          snd.play(glsounds.dragonWalk)
          gsh.newShake(mainCamera, "displacement", 0.5)
        end
      elseif instance.substate == 4 then
        if instance.substateChanged then
          instance.animationState.legs = love.math.random(0, 1) == 1 and "leftLegUp" or "rightLegUp"
          instance.wingSpeed = math.pi * 0.5
          instance.mouthSpeed = 2
          instance.fireSpeed = love.math.random(2, 6) * 0.25

          instance.flamethrower = false
          instance.flthrwIndex = 0
          instance.flthrwroarIndex = 0
          instance.flthrwroarSpeed = 2
          instance.flthrwflameIndex = 0
          instance.flthrwflameSpeed = 4

          instance.newStep = true
          instance.stomp = nil
          instance.idleT = nil
        end

        if instance.newStep then
          instance.newStep = false
          instance.body:setLinearVelocity(0, 0)
          instance.t = 0
          instance:lookAtTarget()
          instance.x0, instance.y0 = instance.body:getPosition()
          local dist, dir = u.cartesianToPolar(instance.target.x - instance.x, instance.target.y - (instance.y + instance.shadowHeightMod))
          if dist < 40 then
            instance.stomp = 0.1
            instance.animationState.legs = "inTheAir"
          end

          if dist < 100 then
            if love.math.random(0, 1) == 1 then
              instance.flamethrower = true
            end
          else
            instance.flamethrower = false
          end

          instance.walkAccel = instance.stomp and 200 or 300
          instance.ax, instance.ay = u.polarToCartesian(instance.walkAccel, dir)
          instance.walkDuration = 0.33 + (instance.stomp and 0.22 or 0)
        end

        -- Position for constant acceleration
        -- x=x0+v0*t+0.5*a*t^2

        local tto2timeshalf = 0.5*instance.t^2
        instance.body:setPosition(instance.x0 + instance.ax*tto2timeshalf, instance.y0 + instance.ay*tto2timeshalf)

        if instance.t > instance.walkDuration then
          instance.steps = instance.steps + 1
          instance.t = instance.walkDuration
          instance.idleT = instance.steps >= instance.stepsToTake and 1 or 0.25
          instance.animationState.legs = instance.animationState.legs ~= "leftLegUp" and "leftLegUp" or "rightLegUp"
          if instance.stomp then
            instance.stomp = nil
            instance.idleT = 0.5
            snd.play(glsounds.bigBoom)
            gsh.newShake(mainCamera, "displacement")
            if pl1 and pl1.exists and pl1.zo == 0 then
              pl1.zvel = 120
            end
          else
            snd.play(glsounds.dragonWalk)
            gsh.newShake(mainCamera, "displacement", 0.15)
          end

          -- Check if in proper position to charge
          instance.chargeAligned = false
          local ___, ltop, ____, _____, ______, lbottom = instance.fixture:getShape():getPoints()
          local _, top, __, bottom = instance.body:getWorldPoints(___, ltop, ______, lbottom)
          if love.math.random() < 0.5 and instance.target.y > top and instance.target.y < bottom and math.abs(instance.target.x - instance.x) < 100 then
            instance.chargeAligned = true
            instance:lookAtTarget()
          end
        end

        if instance.stomp and instance.stomp > 0 then
          instance.stomp = instance.stomp - dt
        elseif instance.idleT then
          instance.idleT = instance.idleT - dt
          if instance.idleT < 0 then
            instance.idleT = nil
            instance.newStep = true
          end
        else
          instance.t = instance.t + dt
        end
      end

      -- Wings
      instance.wingIndex = instance.wingIndex - dt * instance.wingSpeed
      if instance.wingIndex <= 0 then
        instance.wingIndex = 1
        if instance.animationState.wings == "wingsOpen" then
          instance.animationState.wings = "wingsClosed"
          if instance.zo < 0 then
            snd.play(glsounds.dragonWingFlap)
          end
        else
          instance.animationState.wings = "wingsOpen"
        end
      end

      -- Fire
      if not instance.firing then
        instance.fireIndex = instance.fireIndex - dt * instance.fireSpeed

        -- Mouth
        instance.mouthIndex = instance.mouthIndex - dt * instance.mouthSpeed
        if instance.mouthIndex <= 0 then
          instance.mouthIndex = 1
          if instance.animationState.mouth == "mouthClosed" or instance.animationState.mouth == "mouthOpen" then
            instance.animationState.mouth = "mouthHalfOpen"
          else
            instance.animationState.mouth = "mouthClosed"
          end
        end

        if instance.fireIndex < 0 then
          instance.fireIndex = 1
          instance.fireSpeed = love.math.random(2, 6) * 0.25
          instance.firing = instance.fireAnimDur
        end
      elseif instance.flamethrower or instance.flthrwIndex > 0 then
        if instance.flamethrower then
          instance.flthrwIndex = instance.flthrwIndex + dt
          if instance.flthrwIndex > 1 then
            -- Spit continuous fire
            instance.flthrwroarIndex = instance.flthrwroarIndex + dt * instance.flthrwroarSpeed
            if instance.flthrwroarIndex >= 1 then
              instance.flthrwroarIndex = 0
              snd.play(glsounds.dragonRoar)
            end
            instance.flthrwflameIndex = instance.flthrwflameIndex + dt * instance.flthrwflameSpeed
            if instance.flthrwflameIndex >= 1 then
              instance.flthrwflameIndex = 0
              if instance.hp / instance.initialHP < 0.51 then
                instance:fireblast(3, 32)
              else
                instance:fireblast(2, 32)
              end
            end

          elseif instance.flthrwIndex > 0.5 then
            instance.animationState.mouth = "mouthOpen"
          elseif instance.flthrwIndex > 0.25 then
            if instance.animationState.mouth == "mouthClosed" then
              instance.animationState.mouth = "mouthHalfOpen"
            end
          end
        else
          instance.flthrwIndex = 0
          if instance.flthrwIndex <= 0 then
            instance.flthrwIndex = 0
            instance.flthrwroarIndex = 0
            instance.flthrwflameIndex = 0
          end
        end
      else
        local prevFiring = instance.firing
        instance.firing = instance.firing - dt

        if instance.firing < 1 and prevFiring >= 1 then
          if instance.animationState.mouth == "mouthOpen" then
            instance.animationState.mouth = "mouthHalfOpen"
          end
        elseif instance.firing < 0.75 and prevFiring >= 0.75 then
          instance.animationState.mouth = "mouthClosed"
        elseif instance.firing < 0.5 and prevFiring >= 0.5 then
          instance.animationState.mouth = "mouthHalfOpen"
        elseif instance.firing < 0.25 and prevFiring >= 0.25 then
          instance.animationState.mouth = "mouthOpen"
          snd.play(glsounds.dragonRoar)
          if instance.hp / instance.initialHP < 0.51 then
            instance:fireblast(6, 64)
          else
            instance:fireblast(4, 64)
          end
        end

        if instance.firing <= 0 then
          instance.firing = nil
        end
      end

      instance.substateChanged = prevSubstate ~= instance.substate
    end,
    start_state = function(instance, dt)
      instance.chargeAligned = false
      instance.image_index_override = nil

      instance.fireAnimDur = 1
      instance.firing = nil
      instance.fireIndex = 1
      instance.fireSpeed = 0

      instance.wingSpeed = 0
      instance.wingIndex = 1

      instance.mouthSpeed = 0
      instance.mouthIndex = 1

      instance.steps = 0
      instance.stepsToTake = love.math.random(5, 20)

      instance.substate = 0
      instance.substateChanged = false
      instance.stateTimer = 1
    end,
    check_state = function(instance, dt)
      if instance.steps >= instance.stepsToTake and not instance.idleT then
        -- Fly offscreen or choose another valid state
        local weightTable = {
          {weight = 1, value = "flyoff"},
        }
        if 200 > u.distance2d(instance.x, instance.y, instance.target.x, instance.target.y) then
          table.insert(weightTable, {weight = 1, value = "manyjump"})
        end
        local choice = u.chooseFromWeightTable(weightTable)
        instance.state:change_state(instance, dt, choice)
      elseif instance.chargeAligned then
        instance.state:change_state(instance, dt, "charge")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  sweep = {
    run_state = function(instance, dt)
      instance.wingTimer = instance.wingTimer + dt
      while instance.wingTimer > instance.wingDuration do
        instance.wingTimer = instance.wingTimer - instance.wingDuration
        snd.play(glsounds.dragonWingFlap)
      end
      if instance.wingTimer > 0.5 then
        instance.animationState.wings = "wingsOpen"
      else
        instance.animationState.wings = "wingsClosed"
      end

      instance.fireDelay = instance.fireDelay - dt
      if instance.fireDelay < 0 then
        instance.fireDelay = 0
      end

      if instance.sweepDir == "down" then
        if instance.y + instance.zo - instance.sprite.height * 0.5 - 2 > game.room.height then
          instance.sweepOuttaBounds = true
        end
      elseif instance.sweepDir == "up" then
        if instance.y - instance.zo + instance.sprite.height * 0.5 + 2 < 0 then
          instance.sweepOuttaBounds = true
        end
      elseif instance.sweepDir == "left" then
        if instance.x + instance.sprite.width * 0.5 + 2 < 0 then
          instance.sweepOuttaBounds = true
        end
      elseif instance.sweepDir == "right" then
        if instance.x - instance.sprite.width * 0.5 - 2 > game.room.width then
          instance.sweepOuttaBounds = true
        end
      end

      if not instance.firing then
        if instance.fireDelay == 0 then
          instance.firing = 0
        end
      else
        local prevFiring = instance.firing
        instance.firing = instance.firing + dt

        if instance.firing < 0.33 then
          instance.animationState.mouth = "mouthClosed"
        elseif instance.firing < 0.66 then
          instance.animationState.mouth = "mouthHalfOpen"
        elseif instance.firing < 0.99 then
          instance.animationState.mouth = "mouthOpen"
        elseif prevFiring % 0.4 > instance.firing % 0.4 then
          -- FIRE!
          local prevTarget = instance.target
          instance.target = {
            x = love.math.random() * game.room.width,
            y = love.math.random() * game.room.height
          }
          if instance.sweepDir == "down" or instance.sweepDir == "up" then
            instance:lookAtTarget()
            instance:determineMouthPos()
          end
          instance:fire(0)
          instance.target = prevTarget
          if instance.hp / instance.initialHP < 0.51 then
            for i = 1, 4 do
              local prevTarget = instance.target
              instance.target = {
                x = love.math.random() * game.room.width,
                y = love.math.random() * game.room.height
              }
              instance:fire(0)
              instance.target = prevTarget
            end
          end
        end
      end
    end,
    start_state = function(instance, dt)
      instance.zo = instance.zoMinBomb + 1
      instance.wingTimer = 0
      instance.wingDuration = 0.67
      instance.fireDelay = 2
      instance.firing = nil
      instance.animationState.wings = "wingsClosed"
      instance.animationState.legs = "inTheAir"
      instance.animationState.mouth = "mouthClosed"
      local sweepChoice = love.math.random()
      local sweepSpeed = 50
      instance.sweepDir = sweepChoice > 0.75 and "down" or (sweepChoice > 0.50 and "left" or (sweepChoice > 0.25 and "right" or "up"))
      if instance.sweepDir == "down" or instance.sweepDir == "up" then
        instance.x = instance.sprite.width + love.math.random() * (game.room.width - 2 * instance.sprite.width)
        if instance.sweepDir == "up" then
          instance.body:setLinearVelocity(0, -sweepSpeed)
          instance.y = game.room.height - instance.zo + instance.sprite.height * 0.5 + 2
        else
          instance.body:setLinearVelocity(0, sweepSpeed)
          instance.y = -instance.shadowHeightMod * 1.2
        end
        instance.body:setPosition(instance.x, instance.y)
      else
        instance.y = instance.sprite.height - instance.zo + love.math.random() * (game.room.height - 2 * instance.sprite.height + instance.zo)
        if instance.sweepDir == "left" then
          instance.body:setLinearVelocity(-sweepSpeed, 0)
          instance.x = game.room.width + instance.sprite.width * 0.5 + 2
        else
          instance.body:setLinearVelocity(sweepSpeed, 0)
          instance.x = -(instance.sprite.width * 0.5 + 2)
        end
        instance.body:setPosition(instance.x, instance.y)
      end
      if instance.x > game.room.width * 0.5 then
        instance.lookingRight = false
      else
        instance.lookingRight = true
      end
    end,
    check_state = function(instance, dt)
      if instance.sweepOuttaBounds then
        instance.state:change_state(instance, dt, "offscreen")
      end
    end,
    end_state = function(instance, dt)
      instance.sweepOuttaBounds = nil
    end
  },

  charge = {
    run_state = function(instance, dt)
      local prevSubstate = instance.substate

      local prevStateTimer = instance.stateTimer
      instance.stateTimer = instance.stateTimer - dt
      if instance.stateTimer < 0 then instance.stateTimer = 0 end

      if instance.substate == 0 then
        if instance.zo >= 0 then
          -- If I'm not in the air just charge
          instance:lookAtTarget()
          instance.substate = 2
        else
          -- Do warning sound
          if prevStateTimer >= 1 and instance.stateTimer < 1 or
          prevStateTimer >= 0.9 and instance.stateTimer < 0.9 or
          prevStateTimer >= 0.3 and instance.stateTimer < 0.3 or
          prevStateTimer >= 0.2 and instance.stateTimer < 0.2
          then
            snd.play(glsounds.dragonWingFlap)
          end
          if instance.stateTimer == 0 then instance.substate = 1 end
        end
      elseif instance.substate == 1 then
        if instance.substateChanged then
          local chx = instance.target.x
          local chy = instance.target.y

          local distFromPl = 100
          local middle = game.room.width * 0.5
          if math.abs(chx + distFromPl - middle) > math.abs(chx - distFromPl - middle) and chx - distFromPl > 0 then
            instance.x = chx - distFromPl
          else
            instance.x = chx + distFromPl
          end
          instance.y = chy - instance.shadowHeightMod
          -- Don't accidentally hit player if there is a decoy
          if instance.fixture:testPoint(instance.x + 8, chy + 8) or
          instance.fixture:testPoint(instance.x - 8, chy + 8) or
          instance.fixture:testPoint(instance.x + 8, chy - 8) or
          instance.fixture:testPoint(instance.x - 8, chy - 8) then
            local farx = instance.x + 100
            local closex = instance.x - 100
            if math.abs(farx - middle) > math.abs(closex - middle) and chx - distFromPl > 0 then
              instance.x = closex
            else
              instance.x = farx
            end
          end
          instance.body:setPosition(instance.x, instance.y)
          instance:lookAtTarget()
        end

        instance.zo = instance.zo + dt * 600
        if instance.zo >= 0 then
          instance.zo = 0
          snd.play(glsounds.bigBoom)
          gsh.newShake(mainCamera, "displacement", 2)
          instance.substate = 2
          if pl1 and pl1.exists and pl1.zo == 0 then
            pl1.zvel = 120
          end
        end
      elseif instance.substate == 2 then
        if instance.substateChanged then
          instance.image_index_override = 18
          snd.play(glsounds.swordShimmer)
          instance.stateTimer = 0.5
        end

        if instance.stateTimer == 0 then
          instance.substate = 3
        end
      elseif instance.substate == 3 then
        if instance.substateChanged then
          snd.play(glsounds.supercharge)
          instance.body:setLinearVelocity(200 * (instance.lookingRight and 1 or -1), 0)
        end

        if (instance.x > game.room.width - 40 and instance.lookingRight) or (instance.x < 40 and not instance.lookingRight) then
          instance.body:setLinearVelocity(0, 0)
          snd.play(glsounds.smallBoom)
          gsh.newShake(mainCamera, "displacement")
          instance.substate = 4
        end
      elseif instance.substate == 4 then
        if instance.substateChanged then
          instance.stateTimer = 1.7
          instance.stateTStart = instance.stateTimer
          instance.stuckX = instance.x
          instance.stuckY = instance.y
        end

        if instance.stateTimer > 0 then
          instance.body:setPosition(instance.stuckX + math.sin(100 * (instance.stateTStart - instance.stateTimer)), instance.stuckY)
        else
          instance.substate = 5
        end
      elseif instance.substate == 5 then
        if instance.substateChanged then
          instance.stateTimer = 0.5
          snd.play(glsounds.smallBoom)
          -- snd.play(glsounds.swordShimmer)
          instance.body:setLinearVelocity(40 * (instance.lookingRight and -1 or 1), 0)
        end

        if instance.stateTimer == 0 then
          instance.body:setLinearVelocity(0, 0)
          instance.substate = 6
          instance.stateTimer = 0.5
        end
      elseif instance.substate == 6 then
        if instance.stateTimer == 0 then
          instance.substate = 7
        end
      end

      instance.substateChanged = prevSubstate ~= instance.substate
    end,
    start_state = function(instance, dt)
      instance.animationState.wings = "wingsOpen"
      instance.animationState.mouth = "mouthClosed"
      instance.animationState.legs = "inTheAir"

      instance.substate = 0
      instance.stateTimer = 1
      instance.substateChanged = false
    end,
    check_state = function(instance, dt)
      if instance.substate == 7 then
        -- Fly offscreen or choose another valid state
        local weightTable = {
          {weight = 1, value = "flyoff"},
        }
        if 200 > u.distance2d(instance.x, instance.y, instance.target.x, instance.target.y) then
          table.insert(weightTable, {weight = 1, value = "manyjump"})
          table.insert(weightTable, {weight = 1, value = "chase"})
        end
        local choice = u.chooseFromWeightTable(weightTable)
        instance.state:change_state(instance, dt, choice)
      end
    end,
    end_state = function(instance, dt)
    end
  },

  manyjump = {
    run_state = function(instance, dt)
      instance.t = instance.t + dt
      if instance.t > instance.tmax then instance.t = instance.tmax end

      local prevSubstate = instance.substate

      if instance.substate == 0 then
        if instance.zo >= 0 then
          instance.substate = 2
          snd.play(glsounds.dragonRoar)
          instance.animationState.wings = "wingsClosed"
          instance.animationState.mouth = "mouthClosed"
          instance.animationState.legs = "leftLegUp"
          instance:lookAtTarget()
        else
          instance.subtimer = 0
          instance.substate = 1
          instance.animationState.wings = "wingsOpen"
          instance.animationState.mouth = "mouthOpen"
          instance.animationState.legs = "inTheAir"
        end
      elseif instance.substate == 1 then
        local prevsubtimer = instance.subtimer
        instance.subtimer = instance.subtimer + dt
        if instance.subtimer >= 1 then
          instance.subtimer = 1
          if prevsubtimer < 1 then
            instance.xjump = instance.target.x
            instance.yjump = instance.target.y
          end
          instance.body:setPosition(instance.xjump, instance.yjump - instance.shadowHeightMod)
          instance.zo = instance.zo + 200 * dt
          if instance.zo < -200 then
            instance:lookAtTarget()
          end
          if instance.zo >=0 then
            instance.zo = 0
            instance.substate = 4
          end
        else
          if prevsubtimer < 0.9 and instance.subtimer >= 0.9 or
          prevsubtimer < 0.6 and instance.subtimer >= 0.6 or
          prevsubtimer < 0.3 and instance.subtimer >= 0.3 then
            snd.play(glsounds.dragonWingFlap)
          end
        end
      elseif instance.substate == 2 then
        -- set up substate 3 so I will jump on player at exactly tmax
        instance.substate = 3
        instance.animationState.wings = "wingsClosed"
        instance.animationState.mouth = "mouthOpen"
        instance.animationState.legs = "inTheAir"
        instance:lookAtTarget()
        instance.t = 0
        instance.zstart = instance.zo
        -- (3) => zvelinit = - 0.5 * g * tmax - zo / tmax
        instance.zvelinit = - 0.5 * instance.g * instance.tmax - instance.zstart / instance.tmax
        instance.xjump = instance.x
        instance.yjump = instance.y
        instance.vxjump = (instance.target.x - instance.xjump) / instance.tmax
        instance.vyjump = (instance.target.y - instance.shadowHeightMod - instance.yjump) / instance.tmax
      elseif instance.substate == 3 then
        local prevZo = instance.zo
        instance.zo = instance.t * (0.5 * instance.g * instance.t + instance.zvelinit) + instance.zstart

        if prevZo < instance.zo then
          instance.animationState.wings = "wingsOpen"
        end

        instance.body:setPosition(instance.xjump + instance.vxjump * instance.t, instance.yjump + instance.vyjump * instance.t)

        if instance.t == instance.tmax then instance.substate = 4 end
      elseif instance.substate == 4 then -- landed
        if instance.substateChanged then
          instance.animationState.wings = "wingsClosed"
          instance.animationState.mouth = "mouthHalfOpen"
          instance.animationState.legs = math.random() < 0.5 and "leftLegUp" or "rightLegUp"
          if pl1 and pl1.exists and pl1.zo == 0 then
            pl1.zvel = 66
          end
          snd.play(glsounds.bigBoom)
          gsh.newShake(mainCamera, "displacement")
          instance.substateTimer = 1
          instance.timesJumped = instance.timesJumped + 1
          instance.zo = 0

          -- Check if in proper position to charge
          instance.chargeAligned = false
          local ___, ltop, ____, _____, ______, lbottom = instance.fixture:getShape():getPoints()
          local _, top, __, bottom = instance.body:getWorldPoints(___, ltop, ______, lbottom)
          if love.math.random() < 0.5 and instance.target.y > top and instance.target.y < bottom and math.abs(instance.target.x - instance.x) < 100 then
            instance.chargeAligned = true
            instance:lookAtTarget()
          end
        end

        if instance.substateTimer == 0 then
          if instance.timesJumped < instance.jumps then
            instance.substate = 2
            snd.play(glsounds.dragonRoar)
          else
            instance.substate = 5

            -- Check if I will fly off or start chasing
            if love.math.random(0, 1) == 1 and 200 > u.distance2d(instance.x, instance.y, instance.target.x, instance.target.y) then
              instance.substate = 6
            end
            if instance.substate == 5 then snd.play(glsounds.dragonRoar) end
          end
        elseif instance.substateTimer < 0.15 then
          instance.animationState.mouth = "mouthHalfOpen"
        elseif instance.substateTimer < 0.3 then
          instance.animationState.mouth = "mouthClosed"
          instance:lookAtTarget()
        end

        instance.substateTimer = instance.substateTimer - dt
        if instance.substateTimer < 0 then instance.substateTimer = 0 end
      elseif instance.substate == 5 then
        if instance.substateChanged then
          instance.animationState.wings = "wingsOpen"
          instance.animationState.mouth = "mouthOpen"
          instance.animationState.legs = "inTheAir"
        end

        instance.zo = instance.zo - dt * 200
      end

      instance.substateChanged = instance.substate ~= prevSubstate
    end,
    start_state = function(instance, dt)
      instance.t = 0
      instance.substate = 0
      instance.zmax = -500
      -- z = 0.5 * g * t ^ 2 + zvelinit * t + zo (1)
      -- if v is constant
      -- s = v * t : s = displacement : v = (target - start) / tmax =>
      -- x = xo + vx * t
      -- y = yo + vy * t

      -- use above equations to find gravity for desired t
      instance.tmax = 1.5
      -- let zo be 0 =>
      -- (1) highpoint => zmax = 0.5 * g * thalf ^ 2 + zvelinit * thalf + 0 (2)
      -- (1) lowpoint => 0 = 0.5 * g * tmax ^ 2 + zvelinit * tmax + 0 (3)
      -- (3) => 0 = g * tmax / 2 + zvelinit => zvelinit = g * tmax / 2 (4)
      -- (2) => zmax / thalf = g * (zmax / 2) * 0.5 + zvelinit
      -- => zmax / thalf = zvelinit * 3 / 2 =>
      -- => zvelinit = (2 * zmax) / (3 * thalf) =>
      -- => zvelinit = zmax / (3 * tmax)
      -- (4) => g = zvelinit * 2 / tmax
      -- => g = (zmax / (3 * tmax)) * (2 / tmax)
      -- => g = ( 2 * zmax) / (3 * tmax ^ 2)
      -- the above is the magnitude. Sign it to make it point down
      instance.g = -(2 * instance.zmax) / (3 * instance.tmax ^ 2)
      instance.jumps = love.math.random(2, 5)
      instance.timesJumped = 0
      instance.image_index_override = nil
      instance.chargeAligned = false
      instance.substateChanged = false
    end,
    check_state = function(instance, dt)
      if instance.zo < -400 and instance.substate == 5 then
        instance.state:change_state(instance, dt, "offscreen")
      elseif instance.chargeAligned then
        instance.state:change_state(instance, dt, "charge")
      elseif instance.substate == 6 then
        instance.state:change_state(instance, dt, "chase")
      end
    end,
    end_state = function(instance, dt)
      instance.chargeAligned = false
    end
  },

  flyoff = {
    run_state = function(instance, dt)
      local stateTimerPrev = instance.stateTimer
      instance.stateTimer = instance.stateTimer + dt

      if instance.stateTimer % 0.5 < stateTimerPrev % 0.5 then
        instance.animationState.wings = "wingsOpen"
      elseif instance.stateTimer % 0.25 < stateTimerPrev % 0.25 then
        instance.animationState.wings = "wingsClosed"
        snd.play(glsounds.dragonWingFlap)
      end

      instance.zo = instance.zo + instance.zvel * dt
    end,
    start_state = function(instance, dt)
      instance.image_index_override = nil
      instance.animationState.legs = "inTheAir"
      instance.animationState.mouth = "mouthClosed"
      instance.animationState.wings = "wingsOpen"
      instance.zvel = -150
      instance.stateTimer = 0
      instance.stateDuration = 3
    end,
    check_state = function(instance, dt)
      if instance.stateTimer > instance.stateDuration then
        instance.state:change_state(instance, dt, "offscreen")
      end
    end,
    end_state = function(instance, dt)
    end
  }
}

local Boss3 = {}

function Boss3.initialize(instance)
  instance.flying = true -- can go through walls
  instance.sprite_info = im.spriteSettings.boss3
  instance.image_index = 20
  instance.zo = 0
  instance.zoMinBomb = -25
  instance.bombGoesThrough = true
  instance.undamageable = true
  instance.controlledFlight = true
  instance.grounded = false
  instance.unpushable = true
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.canLeaveRoom = true
  instance.hp = 20
  instance.initialHP = instance.hp
  instance.bombsplosionDamageMod = 1 / 4
  instance.sounds = snd.load_sounds({
    hitSound = {"Effects/Oracle_Boss_Hit"},
    fatalHit = {"Effects/Oracle_Boss_Die"},
  })
  instance.layer = pl1 and pl1.layer or 20
  instance.physical_properties.shape = ps.shapes.bosses.boss3.body
  instance.spritefixture_properties.shape = ps.shapes.bosses.boss3.sprite
  instance.spriteOffset = 25
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.animationState = {
    wings = "wingsOpen",
    mouth = "mouthClosed",
    legs = "inTheAir"
  }
  instance.animStatePrev = {}
  instance.mouth = {
    x = 0,
    y = 0
  }
  instance.lookingRight = false
  instance.chargeDmg = 4
  instance.stompDmg = 3
  instance.touchDmg = 2
  instance.attackDmg = instance.touchDmg
  instance.blowUpForce = 130
  instance.chargeImpact = 25
end

Boss3.functions = {
  load = function (self)
    self.shadowHeightMod = self.sprite.height * 0.5 - 8
  end,

  determineMouthPos = function (self)
    self.x_scale = self.lookingRight and -1 or 1
    self.mouth.x = self.x - 20 * self.x_scale
    if self.animationState.legs == "inTheAir" then
      self.mouth.y = self.y + self.zo - 12
    else
      self.mouth.y = self.y + self.zo + 4
    end
  end,

  fire = function (self, accuracyRadius, target, nosound)
    if not accuracyRadius then accuracyRadius = 0 end
    target = target or self.target
    target = {x = target.x, y = target.y}
    local offset = accuracyRadius * love.math.random()
    if offset > 0 then
      local offx, offy = u.polarToCartesian(offset, love.math.random() * 2 * math.pi)
      target.x, target.y = target.x + offx, target.y + offy
    end
    local fireball = proj:new{
      layer = self.layer + 1,
      xstart = self.mouth.x, ystart = self.mouth.y,
      notBreakableByMissile = true,
      dpDeflectable = false,
      dragonFire = true,
      attackDmg = 2,
      sprite_info = im.spriteSettings.dragonFire,
      target = target,
      onFireEnd = onFireEnd
    }
    o.addToWorld(fireball)
    if not nosound then snd.play(glsounds.dragonRoar) end
  end,

  fireblast = function (self, number, accuracyRadius, target)
    number = number or 2
    for i = 1, number do
      self:fire(accuracyRadius, target, true)
    end
  end,

  lookAtTarget = function (self)
    if self.target and self.target.x and self.x < self.target.x then
      self.lookingRight = true
    else
      self.lookingRight = false
    end
  end,

  touchedByBombsplosion = function (self, other, myF, otherF)
    if self.cutscene then return end
    if self.zo < self.zoMinBomb then return end

    self.lastHit = "bombsplosion"
    self.shieldDown = true
    ebh.damagedByHit(self, other, myF, otherF)
    self.shieldDown = false

    if self.hp <= 0 and not self.dying then
      self.dying = true
      self.invulnerable = 2
    end
  end,

  die = function (self)
    local explOb = expl:new{
      x = self.x or self.xstart, y = self.y or self.ystart,
      layer = self.layer,
      explosionNumber = self.explosionNumber or 9,
      explosion_sprite = self.explosionSprite or im.spriteSettings.testsplosion,
      image_speed = self.explosionSpeed or 0.5,
      onlySoundOnce = true,
      sounds = snd.load_sounds({explode = {"Effects/Oracle_Boss_Explode"}})
    }
    o.addToWorld(explOb)
    o.removeFromWorld(self)
    game.room.music_info = snd.silence
    snd.bgmV2.getMusicAndload()
    for _, door in ipairs(o.identified.DunDoor) do
      door:open()
    end
  end,

  enemyUpdate = function (self, dt)
    self.animStatePrev.wings = self.animationState.wings
    self.animStatePrev.mouth = self.animationState.mouth
    self.animStatePrev.legs = self.animationState.legs

    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.invulnerable then
      if not self.invPrev then
        self.storedv = {}
        self.storedv.x, self.storedv.y = self.body:getLinearVelocity()
      end
      self.body:setLinearVelocity(0, 0)
    else
      if self.storedv then
        self.body:setLinearVelocity(self.storedv.x, self.storedv.y)
        self.storedv = nil
      end

      -- do stuff depending on state
      local state = self.state
      state.states[state.state].check_state(self, dt)
      state.states[state.state].run_state(self, dt)

      -- determine image index
      if not self.image_index_override then
        self.image_index = animationTable:getStateIndex(self.animationState)
      else
        self.image_index = self.image_index_override
      end

      self:determineMouthPos()
    end
    self.invPrev = self.invulnerable

    -- Special boss shader handling
    if self.hp <= 0 then
      self.myShader = deathShader
    elseif self.invulnerable then
      self.myShader = nil
      if math.floor(7 * self.invulnerable % 2) == 1 then
        self.myShader = hitShader
      end
    else
      self.myShader = nil
    end

    -- Determine attack type and dmg
    if self.stomp then
      self.attackDmg = self.stompDmg
      self.explosive = nil
      self.impact = nil
    elseif self.state.state == "charge" and self.substate == 3 and self.speed > 30 then
      self.attackDmg = self.chargeDmg
      self.explosive = true
      self.impact = self.chargeImpact
    else
      self.attackDmg = self.touchDmg
      self.explosive = nil
      self.impact = nil
    end

    -- determine components
    if self.cutscene then
      self.goThroughPlayer = true
      self.harmless = true
      self.attackDodger = true
      self.pushback = false
      self.ballbreaker = false
    elseif self.zo < 0 then
      self.goThroughPlayer = true
      self.harmless = true
      self.attackDodger = true
      self.pushback = false
      self.shielded = false
      self.shieldWall = false
      self.ballbreaker = false
    else
      self.goThroughPlayer = false
      self.harmless = false
      self.attackDodger = false
      self.pushback = true
      self.shielded = true
      self.shieldWall = true
      self.ballbreaker = true
    end

    sh.handleShadow(self)
  end,

  -- draw = function (self)
  --
  --   -- Draw enemy the default way
  --   et.functions.draw(self)
  --
  --   -- love.graphics.circle("fill", self.mouth.x, self.mouth.y, 2)
  --
  --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  --   -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
  -- end,
}

function Boss3:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss3, instance, init) -- add own functions and fields
  return instance
end

return Boss3
