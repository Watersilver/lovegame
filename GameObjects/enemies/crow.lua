local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local sm = require "state_machine"

local cos = math.cos
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
    end,
    start_state = function(instance, dt)
      instance.sightDistance = 64
      instance.image_speed = 0
      instance.image_index = 0
      instance.zo = 0
    end,
    check_state = function(instance, dt)
      if instance.lookFor and instance:lookFor(pl1) then
        instance.state:change_state(instance, dt, "rising")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  rising = {
    run_state = function(instance, dt)
      instance.zo = instance.maxHeight * instance.risePrecentage
      instance.risePrecentage = instance.risePrecentage + dt
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0.1
      instance.risePrecentage = 0
    end,
    check_state = function(instance, dt)
      if instance.zo <= instance.maxHeight then
        instance.state:change_state(instance, dt, "risen")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  risen = {
    run_state = function(instance, dt)
      instance.risenTimer = instance.risenTimer + dt
    end,
    start_state = function(instance, dt)
      instance.zo = instance.maxHeight
      instance.sightDistance = 112
      instance.image_speed = 0.1
      instance.body:setLinearVelocity(0, 0)
      instance.risenTimer = 0
    end,
    check_state = function(instance, dt)
      if instance.lookFor and instance:lookFor(pl1) then
        instance.state:change_state(instance, dt, "diving")
      elseif instance.risenTimer > instance.risenMaxDuration then
        instance.state:change_state(instance, dt, "landing")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  landing = {
    run_state = function(instance, dt)
      instance.zo = instance.maxHeight * math.cos(instance.descendPhase)
      instance.descendPhase = instance.descendPhase + dt
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0.1
      instance.descendPhase = 0
    end,
    check_state = function(instance, dt)
      if instance.zo >= 0 then
        instance.state:change_state(instance, dt, "grounded")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  diving = {
    run_state = function(instance, dt)
      instance.divingPhase = instance.divingPhase + instance.divingSpeed * dt
      local divCos = cos(instance.divingPhase)
      local vertMoveMod = divCos * divCos
      instance.zo = instance.maxHeight * vertMoveMod
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0.2
      -- in seconds
      local halftime = 0.7
      local oneDivHT = 1 / halftime
      -- will be fed in a cos ^ 2 function
      instance.divingPhase = 0
      -- will be multiplied with the dt that gets added to phase
      instance.divingSpeed = oneDivHT * pi / 2
      if pl1 then
        local speedDependency = love.math.random(0, 1) * halftime
        local newVx = pl1.vx * speedDependency + pl1.x - instance.x -- distance per second
        -- + 0.5 * ps.shapes.plshapeHeight
        local newVy = pl1.vy * speedDependency + pl1.y - instance.y -- distance per second
        instance.body:setLinearVelocity(oneDivHT * newVx, oneDivHT * newVy)
        if newVx > 0 then
          instance.x_scale = -1
        else
          instance.x_scale = 1
        end
      end
    end,
    check_state = function(instance, dt)
      if instance.divingPhase > pi then
        instance.state:change_state(instance, dt, "risen")
      end
    end,
    end_state = function(instance, dt)
    end
  },
}

local Crow = {}

function Crow.initialize(instance)
  instance.flying = true -- can go through walls
  instance.sprite_info = im.spriteSettings.crow
  instance.maxHeight = -64
  instance.risenMaxDuration = 4
  instance.zo = 0
  instance.actAszo0 = true
  instance.harmless = true
  instance.attackDodger = true
  instance.undamageable = true
  instance.grounded = false
  instance.unpushable = true
  instance.canSeeThroughWalls = true -- what it says on the tin
  instance.hp = 4 --love.math.random(3)
  instance.layer = 25
  instance.spritefixture_properties = false
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
end

Crow.functions = {
  enemyUpdate = function (self, dt)

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state[state.state].check_state(self, dt)
    -- Run animation state
    state[state.state].run_state(self, dt)

    -- check if on player level
    if pl1 then
      if self.zo > -ps.shapes.plshapeHeight then
        self.harmless = false
        self.attackDodger = false
        self.undamageable = false
      else
        self.harmless = true
        self.attackDodger = true
        self.undamageable = true
      end
    end

    sh.handleShadow(self)
  end,

  hitBySword = function (self, other, myF, otherF)
    ebh.propelledByHit(self, other, myF, otherF, 3, 1, 1, 0.5)
  end,
}

function Crow:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Crow, instance, init) -- add own functions and fields
  return instance
end

return Crow
