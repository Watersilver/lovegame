local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local td = require "movement"; td = td.top_down
local sm = require "state_machine"
local u = require "utilities"

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
        instance.state:change_state(instance, dt, "mimicing")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  mimicing = {
    run_state = function(instance, dt)
      -- Mimic movement
      if instance.target.body then
        local vx, vy = instance.target.body:getLinearVelocity()
        instance.body:setLinearVelocity(instance.xMirrorDir * vx, instance.yMirrorDir * vy)
      else
        instance.body:setLinearVelocity(0, 0)
      end

      -- Calculate velocity and speed
      local vx, vy = instance.body:getLinearVelocity()
      local speed = u.magnitude2d(vx, vy)

      -- Calculate image speed
      instance.image_speed = speed * 0.002

      -- If target is almost still don't change facing
      if speed < 1 then return end
      local _, dir = u.cartesianToPolar(instance.body:getLinearVelocity())
      local bigSlice = math.pi * 0.75
      local smallSlice = math.pi * 0.25
      if dir >= bigSlice or dir <= -bigSlice then
        instance.facing = "left"
      elseif dir <= smallSlice and dir >= -smallSlice then
        instance.facing = "right"
      elseif dir > -bigSlice and dir < -smallSlice then
        instance.facing = "up"
      elseif dir < bigSlice and dir > smallSlice then
        instance.facing = "down"
      end
      if instance.facing ~= "right" then
        instance.sprite = im.sprites["Enemies/Mimic/walk_" .. instance.facing]
        instance.x_scale = 1
      else
        instance.sprite = im.sprites["Enemies/Mimic/walk_left"]
        instance.x_scale = -1
      end
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if instance.invulnerable then
        if instance.hp <= 0 then
          instance.invulnerable = 0.25
        end
        instance.state:change_state(instance, dt, "damaged")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  damaged = {
    run_state = function(instance, dt)
      td.stand_still(instance)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if instance.invulnerableEnd then
        instance.state:change_state(instance, dt, "mimicing")
      end
    end,
    end_state = function(instance, dt)
    end
  },
}

local Mimic = {}

function Mimic.initialize(instance)
  instance.sprite_info = im.spriteSettings.mimic
  instance.hp = 5 --love.math.random(3)
  instance.layer = 20
  instance.physical_properties.shape = ps.shapes.rectThreeFourths
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.invframesMod = 5.5
  instance.xMirrorDir = -1
  instance.yMirrorDir = -1
  instance.shielded = true
  instance.weakShield = true
  instance.shieldWall = true
  instance.pushback = true
  instance.attackDmg = 3
end

Mimic.functions = {
  enemyUpdate = function (self, dt)

    -- Get tricked by decoy
    self.target = session.decoy or pl1

    -- do stuff depending on state
    local state = self.state
    -- Check state
    state[state.state].check_state(self, dt)
    -- Run state
    state[state.state].run_state(self, dt)
  end,
}

function Mimic:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Mimic, instance, init) -- add own functions and fields
  return instance
end

return Mimic
