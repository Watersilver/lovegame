local Wall = require("GameObjects.BrickTest")
local softLiftable = require("GameObjects.softLiftable")
local Player = require("GameObjects.PlayaTest")
local floorTile = require("GameObjects.floorTile")
local animatedFloorTile1213 = require("GameObjects.Floor.animatedFloorTile1213")
local animatedFloorTile1234 = require("GameObjects.Floor.animatedFloorTile1234")
local shallowWater = require("GameObjects.Floor.shallowWater")
local water = require("GameObjects.Floor.water")
local grass = require("GameObjects.Floor.grass")
local gap = require("GameObjects.Floor.gap")
local ladder = require("GameObjects.Floor.ladder")
local stairs = require("GameObjects.Floor.stairs")
local noBody = require("GameObjects.noBody")
local edge = require("GameObjects.edge")
local edgeLeft = require("GameObjects.edgeLeft")
local edgeRight = require("GameObjects.edgeRight")
local edgeDown = require("GameObjects.edgeDown")
local wallDown = require("GameObjects.wallDown")
local wallLeft = require("GameObjects.wallLeft")
local wallRight = require("GameObjects.wallRight")
local wallUp = require("GameObjects.wallUp")
local thickWallCornerNE = require("GameObjects.ThickWall.thickWallCornerNE")
local thickWallCornerNW = require("GameObjects.ThickWall.thickWallCornerNW")
local thickWallCornerSE = require("GameObjects.ThickWall.thickWallCornerSE")
local thickWallCornerSW = require("GameObjects.ThickWall.thickWallCornerSW")
local thickWallDown = require("GameObjects.ThickWall.thickWallDown")
local thickWallLeft = require("GameObjects.ThickWall.thickWallLeft")
local thickWallRight = require("GameObjects.ThickWall.thickWallRight")
local thickWallUp = require("GameObjects.ThickWall.thickWallUp")
local NpcTest = require("GameObjects.NpcTest")
local mainMenu = require("GameObjects.mainMenu")

local symbols_to_objects_default = {
  w = Wall,
  sL = softLiftable,
  P1 = Player,
  f = floorTile,
  shW = shallowWater,
  wa = water,
  ga = gap,
  g = grass,
  ld = ladder,
  st = stairs,
  aF = animatedFloorTile1213,
  aF2 = animatedFloorTile1234,
  b = noBody,
  e = edge,
  eL = edgeLeft,
  eR = edgeRight,
  eD = edgeDown,
  d = wallDown,
  l = wallLeft,
  r = wallRight,
  u = wallUp,
  twne = thickWallCornerNE,
  twnw = thickWallCornerNW,
  twse = thickWallCornerSE,
  twsw = thickWallCornerSW,
  twd = thickWallDown,
  twl = thickWallLeft,
  twr = thickWallRight,
  twu = thickWallUp,
  NpcTest = NpcTest,
  mainMenu = mainMenu
}

return symbols_to_objects_default
