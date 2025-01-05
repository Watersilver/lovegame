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
local o = require "GameObjects.objects"

local states = {
  -- WARNING MAKE EMPTY START STATE OR start_state NEVER RUNS!!!

  positionSelf = {
    run_state = function(instance, dt)
      instance.maxspeed = instance.movementspeed

      instance.stunnedFromAttack = instance.stunnedFromAttack - dt
      if instance.stunnedFromAttack < 0 then instance.stunnedFromAttack = 0 end
      if instance.stunnedFromAttack > 0 then instance.maxspeed = 0 end

      instance.image_speed = 0.2

      local _, dir = u.cartesianToPolar(
        instance.target.x - instance.x,
        instance.target.y - instance.y
      )
      local s = u.sign(dir - instance.direction) -- s > 0 == ccw
      if s == 0 then
        instance.direction = dir
      else
        local b = dir - instance.direction - math.pi
        if b == 0 then
          s = love.math.random() > 0.5 and -s or s
        elseif b > 0 then
          s = -s
        end
      end
      instance.direction = (instance.direction + s * 0.1 * math.pi * dt) % (math.pi * 2)
      if s ~= dir - instance.direction then
        instance.direction = dir
      end
      -- instance.direction = dir

      td.analogueWalk(instance, dt)
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0
      instance.image_index = 0
    end,
    check_state = function(instance, dt)
      if instance.grTimer then
        instance.state:change_state(instance, dt, "ok")
      end
    end,
    end_state = function(instance, dt)
    end
  },

}

local Swarm = {}

function Swarm.initialize(instance)
  instance.direction = math.pi * 2
  instance.sprite_info = im.spriteSettings.swarmFire
  instance.zo = 0
  instance.ballbreakerEvenIfHigh = true
  instance.grounded = true
  instance.unpushable = true
  instance.hp = 10
  instance.movementspeed = 60
  instance.maxspeed = instance.movementspeed
  instance.layer = 20
  instance.physical_properties.shape = ps.shapes.circleHalf
  instance.state = sm.new_state_machine(states)
  instance.state.state = "positionSelf"
  instance.stunnedFromAttack = 0
  session.setInstanceId(instance, 'swarm')
end

Swarm.functions = {
  enemyUpdate = function (self, dt)
    if self.attacked then
      self.stunnedFromAttack = 1
    end

    -- Get tricked by decoy
    self.target = session.decoy or pl1

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state.states[state.state].check_state(self, dt)
    -- Run animation state
    state.states[state.state].run_state(self, dt)

    sh.handleShadow(self)
  end,
}

function Swarm:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Swarm, instance, init) -- add own functions and fields
  return instance
end

return Swarm
