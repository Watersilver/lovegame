local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"


local typeTable = {
  ["Tiles/Floor"] = {
    [0] = "deepGrass","grass","deepGrass","grass","deepGrass","grass","grass","grass",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "grass","grass","grass","grass","flowers","flowers","flowers","flowers",
    "snowGrass","snowGrass","snowGrass","snowGrass","deepSnowGrass","snow","deepSnowGrass","snowGrass",
    "snowGrass","snowGrass","snowGrass","snowGrass","snowGrass","snow","snow","snowGrass",
    "snowGrass","snowGrass","snowGrass","snowGrass","snowFlowers","snowFlowers","snowFlowers","snowFlowers",
    "grass","grass","grass","grass","grass","grass","grass","grass",
    "grass","gap","grass","grass","grass","gap","grass","grass",
    "grass","grass","grass","grass","grass","grass","grass","grass",
    "snow","snow","snow","snow","icyDirt","icyDirt","icyDirt","icyDirt",
    "snow","gap","snow","snow","icyDirt","icyDirt","icyDirt","icyDirt",
    "snow","snow","snow","snowGravel","icyDirt","icyDirt","icyDirt","icyGravel",
    "dirt","dirt","dirt","dirt","gravel","gravel","gravel","gravel",
    "dirt","dirt","dirt","dirt","gravel","gravel","gravel","gravel",
    "dirt","dirt","dirt","dirt","gravel","gravel","gravel","gravel",
    "sand","sand","sand","tile","tile","mud","mud","mud",
    "sand","sand","sand","tile","tile","mud","mud","mud",
    "sand","sand","sand","tile","tile","mud","mud","mud",
    "water","water","water","water","sea","sea","sea","sea",
    "water","water","water","water","sea","sea","sea","sea",
    "wood","tile","grass","grass","wood","wood","wood","wood",
    "wood","grass","grass","grass","wood","wood","wood","wood",
    "wood","grass","grass","grass","wood","wood","wood","wood",
    "dirtyRock","dirtyRock","gravelyRock","gap","gap","gap","gap","tile",
    "wood","wood","wood","tile","tile","tile","tile","ice",
    "tile","tile","tile","waterlily","waterlily","tile","grass","grass",
  }
}


local Tile = {}

function Tile.initialize(instance)
  instance.sprite_info = {
    {'Tiles/TestTiles', 4, 4}
  }
  instance.physical_properties = {
    bodyType = "static",
    fixedRotation = true,
    sensor = true,
    shape = ps.shapes.rect1x1,
    masks = {1,2,3,4,5,6,7,8,9,10,11,12,14,15,16}, -- FLOORCOLLIDECAT = 13
  }
  instance.image_speed = 0
  instance.image_index = 0
  instance.floorFriction = 1
  instance.floorViscosity = nil
  instance.floor = true
  instance.playerFloorTilesIndex = nil
  instance.seeThrough = true
  instance.tileType = "dirt"
end

Tile.functions = {

load = function(self)
  local sheet_name = self.sprite_info[1][1] or self.sprite_info[1].img_name
  self.tileType = typeTable[sheet_name][self.image_index] or self.tileType
end,

draw = function (self)

  -- Avoid drawing tiles I don't need to
  local x, y = self.xstart, self.ystart
  local sz2 = 16

  if x + sz2 < caml or x - sz2 > caml + camw or y + sz2 < camt or y - sz2 > camt + camh then
    return
  end
  -- if xtotal + sz2 < caml or xtotal - sz2 > caml + camw or ytotal + sz2 < camt or ytotal - sz2 > camt + camh then
  --   return
  -- end

  local sprite = self.sprite
  local frame = sprite[self.image_index]
  love.graphics.draw(
  sprite.img, frame, self.xstart, self.ystart, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end
end,

trans_draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]

  local xtotal, ytotal = trans.still_objects_coords(self)
  local sz2 = 16

  if xtotal + sz2 < caml or xtotal - sz2 > caml + camw or ytotal + sz2 < camt or ytotal - sz2 > camt + camh then
    return
  end

  love.graphics.draw(
  sprite.img, frame,
  xtotal, ytotal, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   -- draw
  -- end
end
}

function Tile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Tile, instance, init) -- add own functions and fields
  return instance
end

return Tile
