local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local wallDown = require("GameObjects.wallDown")

local thickWallCorner = {}

function thickWallCorner.initialize(instance)
  instance.physical_properties = {bodyType = "static"}
  instance.physical_properties.thickWall = {
    ps.shapes.edgeRect1x1.d,
    ps.shapes.thickWallInner.d,
    ps.shapes.edgeRect1x1.r,
    ps.shapes.thickWallInner.r
  }
end

thickWallCorner.functions = {}

function thickWallCorner:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(wallDown, instance) -- add parent functions and fields
  p.new(thickWallCorner, instance, init) -- add own functions and fields
  return instance
end

return thickWallCorner
