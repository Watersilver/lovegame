local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local wallDown = require("GameObjects.wallDown")

local thickWallCorner = {}

function thickWallCorner.initialize(instance)
  instance.physical_properties = {bodyType = "static"}
  instance.physical_properties.thickWall = {
    ps.shapes.edgeRect1x1.u,
    ps.shapes.thickWallInner.u,
    ps.shapes.edgeRect1x1.l,
    ps.shapes.thickWallInner.l
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
