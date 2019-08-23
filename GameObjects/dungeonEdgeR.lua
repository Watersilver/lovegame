local p = require "GameObjects.prototype"
local DungeonEdgeD = require "GameObjects.DungeonEdgeD"

local DungeonEdge = {}

-- local speed = 45
--
-- local plVelocity = {
--   down = {0, speed},
--   up = {0, -speed},
--   left = {-speed, 0},
--   right = {speed, 0},
-- }

function DungeonEdge.initialize(instance)
  instance.side = "right"
end

DungeonEdge.functions = {}

function DungeonEdge:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(DungeonEdgeD, instance, init) -- add parent functions and fields
  p.new(DungeonEdge, instance, init) -- add own functions and fields
  return instance
end

return DungeonEdge
