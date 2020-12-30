local p = require "GameObjects.prototype"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local snd = require "sound"
local trans = require "transitions"
local ls = require "lightSources"

local Light = {}

function Light.initialize(instance)
  instance.lightSource = {kind = "downEntranceLight"}
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

    -- Draw lightsource
    self.lightSource.x, self.lightSource.y = x, y
    ls.drawSource(self.lightSource)
  end,

  trans_draw = function(self)
    self.x, self.y = self.xlast, self.ylast

    x, y = trans.moving_objects_coords(self)

    -- Draw lightsource
    self.lightSource.x, self.lightSource.y = x, y
    ls.drawSource(self.lightSource)
  end,
}

function Light:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Light, instance, init) -- add own functions and fields
  return instance
end

return Light
