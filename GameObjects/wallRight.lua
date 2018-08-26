local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local wallDown = require("GameObjects.wallDown")

local wallRight = {}

function wallRight.initialize(instance)
  instance.physical_properties.shape  = ps.shapes.edgeRect1x1.r
end

wallRight.functions = {}

function wallRight:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(wallDown, instance) -- add parent functions and fields
  p.new(wallRight, instance, init) -- add own functions and fields
  return instance
end

return wallRight
