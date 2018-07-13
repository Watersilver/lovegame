local ps = require "physics_settings"
local im = require "image"
local inp = require "input"
local p = require "GameObjects.prototype"
local mo = require "movement"
local fsm = require "finite_state_machine"

local Playa = {}


function Playa.initialize(instance)
  instance.ids[#instance.ids+1] = "PlayaTest"
  instance.physical_properties = {
    bodyType = "dynamic",
    fixedRotation = true,
    density = 80,
    shape = ps.shapes.lowr1x1,
    gravityScaleFactor = 0,
    restitution = 0,
    friction = 0
  }
  instance.sprite_info = {
    {'witch_walk_down', 4, padding = 2, width = 16, height = 16},
    {'GuyWalk', 4, width = 16, height = 16},
    {'Test', 1, padding = 0},
    {'Plrun_strip12', 12, padding = 0, width = 16, height = 16},
    spritefixture_properties = {
      shape = ps.shapes.rect1x1
    }
  }
  instance.player = "player1"
  instance.layer = 3
  instance.movement_state = fsm.new_state_machine{
    state = "start",
    start = {
    check_state = function(instance, dt)
      if true then
        instance.movement_state:change_state(instance, dt, "normal")
      end
    end,
    end_state = function(instance, dt)
    end
  },
    normal = {
    run_state = function(instance, dt)
      -- Apply movement table
      mo.top_down(instance, dt)
    end,

    check_state = function(instance, dt)
    end,

    start_state = function(instance, dt)
    end,

    end_state = function(instance, dt)
    end
    }
  }
  instance.animation_state = fsm.new_state_machine{
    state = "start",
    start = {
    check_state = function(instance, dt)
      if true then
        instance.animation_state:change_state(instance, dt, "downwalk")
      end
    end,
    end_state = function(instance, dt)
    end
    },
    downwalk = {
    run_state = function(instance, dt)
    end,

    check_state = function(instance, dt)
    end,

    start_state = function(instance, dt)
    end,

    end_state = function(instance, dt)
    end
    }
  }
end

Playa.functions = {
  update = function(self, dt)

    -- Return movement table based on the long term action you want to take (Npcs)
    -- Return movement table based on the given input (Players)
    self.input = inp.current[self.player]

    local ms = self.movement_state
    -- Check movement state
    ms[ms.state].check_state(self, dt)
    -- Run movement state
    ms[ms.state].run_state(self, dt)

    local as = self.animation_state
    -- Check animation state
    as[as.state].check_state(self, dt)
    -- Run animation state
    as[as.state].run_state(self, dt)

    self.sprite.rot = self.sprite.rot + self.sprite.rotspeed
    self.image_index = (self.image_index + dt*60*self.image_speed) % self.sprite.frames
  end,

  draw = function(self)
    local x, y = self.body:getPosition()
    self.x, self.y = x, y
    local sprite = self.sprite
    local frame = sprite[math.floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, x, y, sprite.rot,
    sprite.res_x_scale*sprite.sx, sprite.res_y_scale*sprite.sy,
    sprite.ox, sprite.oy)
    -- love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
  end,

  load = function(self)
    self.image_speed = 0.1
  end,

  preSolve = function(self, a, b, coll)
    -- coll:setEnabled(false)
  end,

  postSolve = function(self, a, b, coll, normalimpulse, tangentimpulse)
    -- fuck = normalimpulse
    -- debugtxt = tangentimpulse
  end
}

function Playa:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Playa, instance, init) -- add own functions and fields
  return instance
end

return Playa
