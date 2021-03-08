local p = require "GameObjects.prototype"
local parent = require "GameObjects.dynamicBrick"
local expl = require "GameObjects.explode"

local bt = {}

function bt.initialize(instance)
  instance.physical_properties.mass = 20
  instance.liftable = true
  instance.throw_collision = expl.commonExplosion
end

bt.functions = {}

function bt:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(parent, instance) -- add parent functions and fields
  p.new(bt, instance, init) -- add own functions and fields
  return instance
end

return bt
