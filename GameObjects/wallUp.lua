local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local wallDown = require("GameObjects.wallDown")

local wallUp = {}

function wallUp.initialize(instance)
  instance.physical_properties.shape  = ps.shapes.edgeRect1x1.u
end

wallUp.functions = {}

function wallUp:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(wallDown, instance) -- add parent functions and fields
  p.new(wallUp, instance, init) -- add own functions and fields
  return instance
end

return wallUp
