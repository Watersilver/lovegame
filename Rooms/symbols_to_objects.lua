local Wall = require("GameObjects.BrickTest")
local Player = require("GameObjects.PlayaTest")
local floorTile = require("GameObjects.floorTile")
local edge = require("GameObjects.edge")

local symbols_to_objects_default = {
  w = Wall,
  P1 = Player,
  f = floorTile,
  e = edge
}

return symbols_to_objects_default
