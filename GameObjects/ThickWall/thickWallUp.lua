local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local wallDown = require("GameObjects.wallDown")

local thickWallUp = {}

function thickWallUp.initialize(instance)
  instance.physical_properties = {bodyType = "static"}
  instance.physical_properties.thickWall = {
    ps.shapes.edgeRect1x1.u,
    ps.shapes.thickWallInner.u
  }
end

thickWallUp.functions = {}

function thickWallUp:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(wallDown, instance) -- add parent functions and fields
  p.new(thickWallUp, instance, init) -- add own functions and fields
  return instance
end

return thickWallUp
