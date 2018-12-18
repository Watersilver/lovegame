local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"
local snd = require "sound"
local expl = require "GameObjects.explode"
local o = require "GameObjects.objects"

local dc = require "GameObjects.Helpers.determine_colliders"

local fT = require "GameObjects.floorTile"

local Tile = {}

function Tile.initialize(instance)
  instance.gap = true
  instance.unsteppable = true
  instance.physical_properties.sensor = false
end

Tile.functions = {}

function Tile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(fT, instance) -- add parent functions and fields
  p.new(Tile, instance, init) -- add own functions and fields
  return instance
end

return Tile
