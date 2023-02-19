local p = require "GameObjects.prototype"
local trans = require "transitions"
local lighting = require 'ScreenEffects.lighting.lighting'

local Light = {}

function Light.initialize(instance)
end

Light.functions = {
  load = function (self)
    self.x = self.xstart
    self.y = self.ystart
    self.xlast = self.x
    self.ylast = self.y
  end,

  update = function (self, dt)

    -- Determine coordinates for transition
    self.xlast = self.x
    self.ylast = self.y
  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    lighting.applyLight{
      type = "door",
      x = x,
      y = y
    }
  end,

  trans_draw = function(self)
    self.x, self.y = self.xlast, self.ylast

    local x, y = trans.moving_objects_coords(self)

    lighting.applyLight{
      type = "door",
      x = x,
      y = y
    }
  end,
}

function Light:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Light, instance, init) -- add own functions and fields
  return instance
end

return Light
