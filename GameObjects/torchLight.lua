local p = require "GameObjects.prototype"
local trans = require "transitions"
local lighting = require 'ScreenEffects.lighting.lighting'

local TorchLight = {}

function TorchLight.initialize(instance)
  instance.flickerTick = 0
  instance.flickerPeriod = 1 / 30 -- in secs
  instance.flickerIndex = 0
end

TorchLight.functions = {
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

    -- Light source stuff
    self.flickerTick = self.flickerTick + dt
    if self.flickerTick > self.flickerPeriod then
      self.flickerTick = self.flickerTick - self.flickerPeriod
      self.flickerIndex = love.math.random(0, 2)
      if self.flickerIndex == 2 then self.flickerIndex = nil end
    end
  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    lighting.applyLight{
      type = 'torch',
      rgba = {
        r = 0.8,
        g = 0.3,
        b = 0,
        a = 1
      },
      x = x,
      y = y,
      image_index = self.flickerIndex
    }
    lighting.applyLight{
      type = 'massive',
      rgba = {
        r = 0.8,
        g = 0.3,
        b = 0,
        a = 0.5
      },
      x = x,
      y = y
    }
  end,

  trans_draw = function(self)
    self.x, self.y = self.xlast, self.ylast

    local x, y = trans.moving_objects_coords(self)

    lighting.applyLight{
      type = 'torch',
      rgba = {
        r = 0.8,
        g = 0.3,
        b = 0,
        a = 1
      },
      x = x,
      y = y,
      image_index = self.flickerIndex
    }

    -- TODO: Outgoing lights shrink and incoming grow
    -- to avoid uglyness of suddenly appearing dissapearing lights
    lighting.applyLight{
      type = 'massive',
      rgba = {
        r = 0.8,
        g = 0.3,
        b = 0,
        a = 0.5
      },
      x = x,
      y = y
    }
  end,
}

function TorchLight:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(TorchLight, instance, init) -- add own functions and fields
  return instance
end

return TorchLight
