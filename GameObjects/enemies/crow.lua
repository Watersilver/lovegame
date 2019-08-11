local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local sm = require "state_machine"

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
      instance.zo = instance.zo + dt * instance.riseSpeed
    end,
    start_state = function(instance, dt)
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
    end,
    start_state = function(instance, dt)
      instance.zo = instance.maxHeight
      instance.sightDistance = 96
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
    end
  },
}

local Crow = {}

function Crow.initialize(instance)
  instance.flying = true -- can go through walls
  instance.sprite_info = im.spriteSettings.crow
  instance.riseSpeed = -44
  instance.maxHeight = -10
  instance.zo = 0
  instance.actAszo0 = true
  instance.harmless = true
  instance.attackDodger = true
  instance.undamageable = true
  instance.grounded = false
  instance.unpushable = true
  instance.canSeeThroughWalls = true -- what it says on the tin
  instance.hp = 4 --love.math.random(3)
  instance.layer = 27
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
