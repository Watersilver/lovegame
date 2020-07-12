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
      instance.grTimer = instance.grTimer - dt
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0
      instance.image_index = 0
      instance.zo = 0
      instance.body:setLinearVelocity(0, 0)
      instance.grTimer = u.chooseFromChanceTable{
        {chance = 0.5, value = 2},
        {chance = 0.4, value = 4},
        {chance = 0.05, value = 6},
        {chance = 0.05, value = 0.5},
      }
    end,
    check_state = function(instance, dt)
      if instance.grTimer < 0 then
        instance.state:change_state(instance, dt, "flying")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  flying = {
    run_state = function(instance, dt)
      instance.flTimer = instance.flTimer - dt

      instance.zo = instance.zo - dt
      if instance.zo < instance.maxHeight then
        instance.zo = instance.maxHeight
      end

      -- Movement behaviour
      ebh.bounceOffScreenEdge(instance)
      if instance.behaviourTimer < 0 then
        instance.direction = love.math.random() * 2 * pi
        instance.behaviourTimer = u.chooseFromChanceTable{
          {chance = 0.5, value = 2},
          {chance = 0.45, value = 1},
          {chance = 0.05, value = 3},
        }
      end
      if instance.invulnerable then
        instance.direction = nil
      end
      td.analogueWalk(instance, dt)
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0.2
      instance.flTimer = u.chooseFromChanceTable{
        {chance = 0.5, value = 3},
        {chance = 0.45, value = 5},
        {chance = 0.05, value = 7},
      }
      instance.behaviourTimer = 0
    end,
    check_state = function(instance, dt)
      if instance.flTimer < 0 then
        instance.state:change_state(instance, dt, "landing")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  landing = {
    run_state = function(instance, dt)

      local oneMinLP = (1 - instance.landingProgress)

      -- Lower self
      instance.zo = instance.maxHeight * oneMinLP

      -- Lower image speed
      instance.image_speed = instance.image_speedStart * oneMinLP

      -- Lower speed
      local vx, vy = instance.body:getLinearVelocity()
      if not instance.invulnerable then
        instance.body:setLinearVelocity(oneMinLP * instance.vxStart, oneMinLP * instance.vyStart)
      end

      -- Update landing progress
      instance.landingProgress = instance.landingProgress + dt

      -- Movement behaviour
      ebh.bounceOffScreenEdge(instance)
    end,
    start_state = function(instance, dt)
      instance.landingProgress = 0
      instance.image_speedStart = instance.image_speed
      instance.vxStart, instance.vyStart = instance.body:getLinearVelocity()
    end,
    check_state = function(instance, dt)
      if instance.landingProgress > 1 then
        instance.state:change_state(instance, dt, "grounded")
      end
    end,
    end_state = function(instance, dt)
    end
  },

}

local Bat = {}

function Bat.initialize(instance)
  instance.flying = true -- can go through walls
  instance.sprite_info = im.spriteSettings.bat
  instance.maxHeight = -3
  instance.zo = 0
  instance.ballbreakerEvenIfHigh = true
  instance.controlledFlight = true
  instance.lowFlight = true
  instance.grounded = true
  instance.unpushable = true
  instance.hp = 1 --love.math.random(3)
  instance.maxspeed = 60
  instance.layer = 20
  instance.physical_properties.shape = ps.shapes.circleHalf
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.shadowHeightMod = -2
end

Bat.functions = {
  enemyUpdate = function (self, dt)

    -- Get tricked by decoy
    self.target = session.decoy or pl1

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state[state.state].check_state(self, dt)
    -- Run animation state
    state[state.state].run_state(self, dt)

    sh.handleShadow(self)
  end,
}

function Bat:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Bat, instance, init) -- add own functions and fields
  return instance
end

return Bat
