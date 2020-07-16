local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local sm = require "state_machine"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"

local cos = math.cos
local abs = math.abs
local pi = math.pi

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "grounded")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  grounded = {
    run_state = function(instance, dt)
      instance.grTimer = instance.grTimer + dt

      -- Manage helix spin
      if instance.grTimer < instance.grDuration - 1 then
        -- Stop spinning
        if instance.image_speed > 0 then
          instance.image_speed = instance.image_speed - dt * 0.1
          if instance.image_speed < 0 then instance.image_speed = 0 end
        else
          instance.image_speed = 0
        end
      else
        -- Start spinning
        if instance.image_speed < instance.spin_speed then
          instance.image_speed = instance.image_speed + dt * 0.3
        else
          instance.image_speed = instance.spin_speed
        end
      end
    end,
    start_state = function(instance, dt)
      instance.ballbreaker = true
      instance.grounded = true
      instance.undamageable = false
      instance.sprintThrough = false
      instance.thrownGoesThrough = false

      instance.grDuration = 5 + 2 * love.math.random()
      instance.grTimer = 0
      instance.zo = 0
      instance.body:setLinearVelocity(0, 0)
    end,
    check_state = function(instance, dt)
      if instance.grTimer > instance.grDuration then
        instance.state:change_state(instance, dt, "flight")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  flight = {
    run_state = function(instance, dt)

      instance.flTimer = instance.flTimer + dt

      if instance.flTimer < instance.flDuration - instance.flFadeOutDur then
        -- Raise height
        instance.zo = instance.maxHeight * instance.risePrecentage
        instance.risePrecentage = instance.risePrecentage + dt * 2
        if instance.risePrecentage > 1 then instance.risePrecentage = 1 end

        -- Initiate dodge maneuver
        if instance.attemtedToBeAttacked and instance.attemtedToBeAttacked ~= "mdust" and not instance.dodgeTimer and not instance.attacked then
          instance.dodgeTimer = 0
        end
      else
        -- Manage height and spin
        local loweringPercentage = 1 - (instance.flFadeOutDur - (instance.flDuration - instance.flTimer)) / instance.flFadeOutDur
        -- Lower speed
        instance.normalisedSpeed = loweringPercentage
        -- Lower Height
        instance.zo = instance.maxHeight * instance.risePrecentage
        instance.risePrecentage = loweringPercentage
        if instance.risePrecentage < 0 then instance.risePrecentage = 0 end
        -- Stop Spin
        if instance.image_speed > 0 then
          instance.image_speed = instance.image_speed - dt * 0.1
          if instance.image_speed < 0 then instance.image_speed = 0 end
        else
          instance.image_speed = 0
        end
        -- Lower magnitude
        instance.universalMagnNorm = loweringPercentage
      end

      -- Movement behaviour
      if instance.behaviourTimer < 0 then
        instance.direction = math.pi * 2 * love.math.random()
        instance.behaviourTimer = love.math.random(2)
      end
      if instance.invulnerable then
        instance.direction = nil
      end

      td.analogueWalk(instance, dt)

      -- Dodge maneuver
      if instance.dodgeTimer then
        local dtDivDur = instance.dodgeTimer / instance.dodgeMagnRaiseDuration
        instance.xModMagn = math.max(instance.xModMagn, instance.xModMagnMax * dtDivDur)
        instance.yModMagn = math.max(instance.yModMagn, instance.yModMagnMax * dtDivDur)
        instance.dodgeTimer = instance.dodgeTimer + dt
        if instance.dodgeTimer > instance.dodgeMagnRaiseDuration then
          instance.dodgeTimer = nil
        end
      end

      -- x and y get set to body position durin
      -- enemyTest's update before enemyUpdate gets called
      instance.xModTimer = instance.xModTimer + dt * 7
      instance.x = instance.x + math.sin(instance.xModTimer) * instance.xModMagn
      instance.yModTimer = instance.yModTimer + dt * 5
      instance.y = instance.y + math.sin(instance.yModTimer) * instance.yModMagn

      instance.xModMagn, instance.yModMagn = (instance.xModMagn - dt * 3) * instance.universalMagnNorm, (instance.yModMagn - dt * 3) * instance.universalMagnNorm
      if instance.xModMagn < 0 then instance.xModMagn = 0 end
      if instance.yModMagn < 0 then instance.yModMagn = 0 end

    end,
    start_state = function(instance, dt)
      instance.ballbreaker = false
      instance.grounded = false
      instance.undamageable = true
      instance.sprintThrough = true
      instance.thrownGoesThrough = true

      instance.flDuration = 5 + 8 * love.math.random()
      instance.flTimer = 0
      instance.flFadeOutDur = 1
      instance.normalisedSpeed = 1
      instance.image_speed = instance.spin_speed
      instance.risePrecentage = 0
      instance.xModTimer = 0
      instance.xModMagn = 0
      instance.xModMagnMax = 7
      instance.yModTimer = love.math.random() * 2 * math.pi
      instance.yModMagn = 0
      instance.yModMagnMax = 5
      instance.universalMagnNorm = 1 -- lower during descent
      -- Magnitude gets increased for this duration
      instance.dodgeMagnRaiseDuration = 0.2
    end,
    check_state = function(instance, dt)
      if instance.flTimer > instance.flDuration then
        instance.state:change_state(instance, dt, "grounded")
      end
    end,
    end_state = function(instance, dt)
    end
  },

}

local Chopper = {}

function Chopper.initialize(instance)
  instance.flying = true -- can go through walls
  instance.sprite_info = im.spriteSettings.chopper
  instance.maxHeight = -5
  instance.zo = 0
  instance.lowFlight = true
  instance.unpushable = true
  instance.hp = 4 --love.math.random(3)
  instance.maxspeed = 44
  instance.layer = 20
  instance.physical_properties.shape = ps.shapes.circleAlmost1
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.spin_speed = 0.3
  instance.universalForceMod = 0
  instance.damageableByBombsplosion = true
end

Chopper.functions = {
  enemyUpdate = function (self, dt)

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state[state.state].check_state(self, dt)
    -- Run animation state
    state[state.state].run_state(self, dt)

    sh.handleShadow(self)
  end,
}

function Chopper:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Chopper, instance, init) -- add own functions and fields
  return instance
end

return Chopper
