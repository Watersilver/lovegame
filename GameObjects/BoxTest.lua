local ps = require "physics_settings"
local p = require "GameObjects.prototype"

local lp = love.physics

local bt = {}

function bt.initialize(instance)
  instance.physical_properties = {
    bodyType = "dynamic",
    density = 40,
    shape = ps.shapes.rect1x1,
    restitution = 0
  }
end

bt.functions = {
  update = function(self)
  end
  ,
  draw = function(self)
    love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
  end
  ,
  load = function(self)
    -- set up physical properties
  end
}

function bt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(bt, instance, init) -- add own functions and fields
  return instance
end

return bt
