local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"
local im = require "image"

local fT = require "GameObjects.floorTile"

local Tile = {}

function Tile.initialize(instance)
  instance.globimage_index = "globimage_index1213"
  instance.image_index = 0
end

Tile.functions = {
draw = function (self)
  local x, y = self.xstart, self.ystart
  local sz2 = 16

  if x + sz2 < caml or x - sz2 > caml + camw or y + sz2 < camt or y - sz2 > camt + camh then
    return
  end

  local sprite = self.sprite
  local frame = sprite[self.image_index + im[self.globimage_index]]
  love.graphics.draw(
  sprite.img, frame, x, y, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end
end,

trans_draw = function (self)
  local xtotal, ytotal = trans.still_objects_coords(self)
  local sz2 = 16
  if xtotal + sz2 < caml or xtotal - sz2 > caml + camw or ytotal + sz2 < camt or ytotal - sz2 > camt + camh then
    return
  end

  local sprite = self.sprite
  local frame = sprite[self.image_index + im[self.globimage_index]]

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
  p.new(fT, instance) -- add parent functions and fields
  p.new(Tile, instance, init) -- add own functions and fields
  return instance
end

return Tile
