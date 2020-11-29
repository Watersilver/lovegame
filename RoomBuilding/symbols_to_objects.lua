local Wall = require("GameObjects.BrickTest")
local softLiftable = require("GameObjects.softLiftable")
local rockTest = require("GameObjects.RockTest")
local floorTile = require("GameObjects.floorTile")
local animatedFloorTile1213 = require("GameObjects.Floor.animatedFloorTile1213")
local animatedFloorTile1234 = require("GameObjects.Floor.animatedFloorTile1234")
local shallowWater = require("GameObjects.Floor.shallowWater")
local water = require("GameObjects.Floor.water")
local water1234 = require("GameObjects.Floor.water1234")
local grass = require("GameObjects.Floor.grass")
local gap = require("GameObjects.Floor.gap")
local ladder = require("GameObjects.Floor.ladder")
local stairs = require("GameObjects.Floor.stairs")
local noBody = require("GameObjects.noBody")
local edge = require("GameObjects.edge")
local edgeLeft = require("GameObjects.edgeLeft")
local edgeRight = require("GameObjects.edgeRight")
local edgeDown = require("GameObjects.edgeDown")
local dungeonEdgeD = require("GameObjects.dungeonEdgeD")
local dungeonEdgeL = require("GameObjects.dungeonEdgeL")
local dungeonEdgeR = require("GameObjects.dungeonEdgeR")
local dungeonEdgeU = require("GameObjects.dungeonEdgeU")
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
local wallVibration = require("GameObjects.BrickTestVibration")
local NpcTest = require("GameObjects.npcTest")
local portal = require("GameObjects.portal")
local mainMenu = require("GameObjects.mainMenu")

local torch = {
  new = function (_, init)
    init.light = true
    return wallVibration:new(init)
  end
}

local ptlToOutside = {
  new = function (_, init)
    init.light = true
    return portal:new(init)
  end
}

local symbols_to_objects_default = {
  w = Wall,
  rW = require("GameObjects.roundWall"),
  rW2 = require("GameObjects.roundWall2"),
  w1234 = require("GameObjects.BrickTest1234"),
  wV = wallVibration,
  torch = torch,
  sL = softLiftable,
  rT = rockTest,
  f = floorTile,
  iF = require("GameObjects.Floor.iceFloor"),
  pl = floorTile, --placeholder
  shW = shallowWater,
  wa = water,
  wa2 = water1234,
  ga = gap,
  g = grass,
  ld = ladder,
  st = stairs,
  aF = animatedFloorTile1213,
  aF2 = animatedFloorTile1234,
  ptl = portal,
  ptlToOutside = ptlToOutside,
  b = noBody,
  e = edge,
  eL = edgeLeft,
  eR = edgeRight,
  eD = edgeDown,
  deD = dungeonEdgeD,
  deL = dungeonEdgeL,
  deR = dungeonEdgeR,
  deU = dungeonEdgeU,
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
