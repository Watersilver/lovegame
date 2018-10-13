local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"

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
end

Tile.functions = {
draw = function (self)
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
