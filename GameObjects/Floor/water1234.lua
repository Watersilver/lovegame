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
local aT = require "GameObjects.Floor.animatedFloorTile1213"
local aFT = require "GameObjects.Floor.animatedFloorTile1234"

local Tile = {}

function Tile.initialize(instance)
  instance.floorViscosity = "water"
  instance.floorFriction = 0.6
  instance.unsteppable = true
  instance.water = 'Witch/defaultWaterRipples'
  instance.physical_properties.sensor = false
end

Tile.functions = {}

function Tile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(fT, instance) -- add parent functions and fields
  p.new(aT, instance) -- add parent functions and fields
  p.new(aFT, instance) -- add parent functions and fields
  p.new(Tile, instance, init) -- add own functions and fields
  return instance
end

return Tile
