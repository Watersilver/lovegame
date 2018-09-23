local Wall = require("GameObjects.BrickTest")
local Player = require("GameObjects.PlayaTest")
local floorTile = require("GameObjects.floorTile")
local edge = require("GameObjects.edge")
local wallDown = require("GameObjects.wallDown")
local wallLeft = require("GameObjects.wallLeft")
local wallRight = require("GameObjects.wallRight")
local wallUp = require("GameObjects.wallUp")
local NpcTest = require("GameObjects.NpcTest")
local mainMenu = require("GameObjects.mainMenu")

local symbols_to_objects_default = {
  w = Wall,
  P1 = Player,
  f = floorTile,
  e = edge,
  d = wallDown,
  l = wallLeft,
  r = wallRight,
  u = wallUp,
  NpcTest = NpcTest,
  mainMenu = mainMenu
}

return symbols_to_objects_default
