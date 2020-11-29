local p = require "GameObjects.prototype"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local snd = require "sound"
local trans = require "transitions"
local ls = require "lightSources"

local TorchLight = {}

function TorchLight.initialize(instance)
  instance.lightSource = {kind = "playerTorch"}
  instance.flickerTick = 0
  instance.flickerPeriod = 1 / 30 -- in secs
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
      self.lightSource.image_index = love.math.random(0, 2)
      if self.lightSource.image_index == 2 then self.lightSource.image_index = nil end
    end
  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    self.x, self.y = x, y

    -- Draw lightsource
    self.lightSource.x, self.lightSource.y = x, y
    ls.drawSource(self.lightSource)
  end,

  trans_draw = function(self)
    self.x, self.y = self.xlast, self.ylast
    self:draw(true)
  end,
}

function TorchLight:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(TorchLight, instance, init) -- add own functions and fields
  return instance
end

return TorchLight
