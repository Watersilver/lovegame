local wallVibration = require("GameObjects.BrickTestVibration")
local portal = require("GameObjects.portal")

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
  w = require("GameObjects.BrickTest"),
  rW = require("GameObjects.roundWall"),
  rW2 = require("GameObjects.roundWall2"),
  w1234 = require("GameObjects.BrickTest1234"),
  wV = wallVibration,
  torch = torch,
  sL = require("GameObjects.softLiftable"),
  rT = require("GameObjects.RockTest"),
  db = require("GameObjects.dynamicBrick"),
  db2 = require("GameObjects.dynamicBrick2"),
  f = require("GameObjects.floorTile"),
  iF = require("GameObjects.Floor.iceFloor"),
  pl = require("GameObjects.floorTile"), --placeholder
  shW = require("GameObjects.Floor.shallowWater"),
  wa = require("GameObjects.Floor.water"),
  wa2 = require("GameObjects.Floor.water1234"),
  ga = require("GameObjects.Floor.gap"),
  g = require("GameObjects.Floor.grass"),
  ld = require("GameObjects.Floor.ladder"),
  st = require("GameObjects.Floor.stairs"),
  aF = require("GameObjects.Floor.animatedFloorTile1213"),
  aF2 = require("GameObjects.Floor.animatedFloorTile1234"),
  ptl = portal,
  ptlToOutside = ptlToOutside,
  b = require("GameObjects.noBody"),
  e = require("GameObjects.edge"),
  eL = require("GameObjects.edgeLeft"),
  eR = require("GameObjects.edgeRight"),
  eD = require("GameObjects.edgeDown"),
  deD = require("GameObjects.dungeonEdgeD"),
  deL = require("GameObjects.dungeonEdgeL"),
  deR = require("GameObjects.dungeonEdgeR"),
  deU = require("GameObjects.dungeonEdgeU"),
  d = require("GameObjects.wallDown"),
  l = require("GameObjects.wallLeft"),
  r = require("GameObjects.wallRight"),
  u = require("GameObjects.wallUp"),
  twne = require("GameObjects.ThickWall.thickWallCornerNE"),
  twnw = require("GameObjects.ThickWall.thickWallCornerNW"),
  twse = require("GameObjects.ThickWall.thickWallCornerSE"),
  twsw = require("GameObjects.ThickWall.thickWallCornerSW"),
  twd = require("GameObjects.ThickWall.thickWallDown"),
  twl = require("GameObjects.ThickWall.thickWallLeft"),
  twr = require("GameObjects.ThickWall.thickWallRight"),
  twu = require("GameObjects.ThickWall.thickWallUp"),
  NpcTest = require("GameObjects.npcTest"),
  mainMenu = require("GameObjects.mainMenu")
}

return symbols_to_objects_default
