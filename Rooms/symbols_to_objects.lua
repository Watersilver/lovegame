local Wall = require("GameObjects.BrickTest")
local Player = require("GameObjects.PlayaTest")
local floorTile = require("GameObjects.floorTile")
local animatedFloorTile1213 = require("GameObjects.animatedFloorTile1213")
local animatedFloorTile1234 = require("GameObjects.animatedFloorTile1234")
local noBody = require("GameObjects.noBody")
local edge = require("GameObjects.edge")
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
  P1 = Player,
  f = floorTile,
  aF = animatedFloorTile1213,
  aF2 = animatedFloorTile1234,
  b = noBody,
  e = edge,
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
