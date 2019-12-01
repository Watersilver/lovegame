local p = require "GameObjects.prototype"
local fT = require "GameObjects.floorTile"

local Tile = {}

function Tile.initialize(instance)
  instance.floorFriction = 0.2
end

Tile.functions = {}

function Tile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(fT, instance) -- add parent functions and fields
  p.new(Tile, instance, init) -- add own functions and fields
  return instance
end

return Tile
