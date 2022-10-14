local p = require "GameObjects.prototype"
local im = require "image"
local ps = require "physics_settings"
local trans = require "transitions"
local sm = require "state_machine"
local o = require "GameObjects.objects"
local u = require "utilities"

-- Parent objects
local et = require "GameObjects.enemyTest"
local nii = require "GameObjects.abstract.normalisedImageIndex"

-- Components
local b5h = require "GameObjects.bosses.boss5.boss5head"
local b5r = require "GameObjects.bosses.boss5.boss5ring"

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "next")
      end
    end,
    end_state = function(instance, dt)
    end
  },
  next = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
    end
  },
}

local obj = {}

function obj.initialize(instance)
  -- If I want it to have some sprite
  instance.sprite_info = im.spriteSettings.boss5
  instance.layer = pl1.layer

  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"

  instance.invisible = true

  instance.head = b5h:new{parent = instance}
  o.addToWorld(instance.head)

  instance.ring = b5r:new{parent = instance}
  o.addToWorld(instance.ring)
end

obj.functions = {
  load = function (self)
  end,

  enemyUpdate = function (self, dt)
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    -- do stuff depending on state
    local state = self.state
    state.states[state.state].check_state(self, dt)
    state.states[state.state].run_state(self, dt)

    -- fuck = self.head.canSeePlayer and "Yo" or "no"
  end,

  draw = function (self)
  end,

  -- beginContact = function(self, a, b, coll)
  -- end,

  -- endContact = function(self, a, b, coll)
  -- end,

  -- preSolve = function(self, a, b, coll)
  -- end,
}

function obj:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(nii, instance) -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(obj, instance) -- add own functions and fields
  return instance
end

return obj
