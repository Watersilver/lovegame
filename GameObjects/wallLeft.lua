local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local wallDown = require("GameObjects.wallDown")

local wallLeft = {}

function wallLeft.initialize(instance)
  instance.physical_properties.shape  = ps.shapes.edgeRect1x1.l
end

wallLeft.functions = {}

function wallLeft:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(wallDown, instance) -- add parent functions and fields
  p.new(wallLeft, instance, init) -- add own functions and fields
  return instance
end

return wallLeft
