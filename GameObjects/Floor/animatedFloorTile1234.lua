local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"

local fT = require "GameObjects.floorTile"
local aT = require "GameObjects.Floor.animatedFloorTile1213"

local Tile = {}

function Tile.initialize(instance)
  instance.globimage_index = "globimage_index1234"
end

Tile.functions = {}

function Tile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(fT, instance) -- add parent functions and fields
  p.new(aT, instance) -- add parent functions and fields
  p.new(Tile, instance, init) -- add own functions and fields
  return instance
end

return Tile
