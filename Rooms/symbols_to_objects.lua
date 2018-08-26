local Wall = require("GameObjects.BrickTest")
local Player = require("GameObjects.PlayaTest")
local floorTile = require("GameObjects.floorTile")
local edge = require("GameObjects.edge")
local wallDown = require("GameObjects.wallDown")
local wallLeft = require("GameObjects.wallLeft")
local wallRight = require("GameObjects.wallRight")
local wallUp = require("GameObjects.wallUp")

local symbols_to_objects_default = {
  w = Wall,
  P1 = Player,
  f = floorTile,
  e = edge,
  d = wallDown,
  l = wallLeft,
  r = wallRight,
  u = wallUp
}

return symbols_to_objects_default
