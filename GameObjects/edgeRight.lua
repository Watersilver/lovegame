local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local ec = require "GameObjects.Helpers.edge_collisions"
local dc = require "GameObjects.Helpers.determine_colliders"
local trans = require "transitions"
local game = require "game"

local edge = require "GameObjects.edge"

-- WARNING: NEVER make adjacent edges!!!
local Edge = {}

function Edge.initialize(instance)
  instance.side = "right"
end

Edge.functions = {}

function Edge:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(edge, instance, init) -- add parent functions and fields
  p.new(Edge, instance, init) -- add own functions and fields
  return instance
end

return Edge
