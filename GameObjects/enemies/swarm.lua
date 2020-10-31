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
      instance.image_speed = instance.speed * 0.01
      local _, dir = u.cartesianToPolar(
        instance.target.x - instance.x,
        instance.target.y - instance.y
      )
      instance.direction = dir

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

local SworderTemplate = {}

function SworderTemplate.initialize(instance)
  instance.sprite_info = im.spriteSettings.bat
  instance.zo = 0
  instance.ballbreakerEvenIfHigh = true
  instance.grounded = true
  instance.unpushable = true
  instance.hp = 10
  instance.maxspeed = 60
  instance.layer = 20
  instance.physical_properties.shape = ps.shapes.circleHalf
  instance.state = sm.new_state_machine(states)
  instance.state.state = "positionSelf"
  instance.sawPlayer = 0
end

SworderTemplate.functions = {
  enemyUpdate = function (self, dt)

    -- Get tricked by decoy
    self.target = session.decoy or pl1

    -- Determine target
    if self.facing then
      if self:lookFor(self.target) then
        self.sawPlayer = self.sawPlayer + dt
      else
        self.sawPlayer = self.sawPlayer - dt
      end
    else
      self.sawPlayer = self.sawPlayer - dt
    end
    if self.sawPlayer < 0 then self.sawPlayer = 0 end

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state.states[state.state].check_state(self, dt)
    -- Run animation state
    state.states[state.state].run_state(self, dt)

    sh.handleShadow(self)
  end,
}

function SworderTemplate:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(SworderTemplate, instance, init) -- add own functions and fields
  return instance
end

return SworderTemplate
