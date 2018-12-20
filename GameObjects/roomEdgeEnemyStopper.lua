local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"

local Brick = {}

function Brick.initialize(instance)
  instance.physical_properties = {
    bodyType = "static",
    masks = {1,2,3,4,5,6,7,8,9,11,12,13,14,15,16} -- ROOMEDGECOLLIDECAT = 10
  }
  -- instance.roomEdge = "up", "down", "right", "left"
end

Brick.functions = {}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
