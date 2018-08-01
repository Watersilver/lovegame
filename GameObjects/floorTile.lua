local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"

local Tile = {}

function Tile.initialize(instance)
  instance.sprite_info = {
    {'Tiles/TestTiles', 4, 4}
  }
  instance.image_speed = 0
  instance.image_index = 0
end

Tile.functions = {
draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]
  love.graphics.draw(
  sprite.img, frame, self.xstart, self.ystart, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  if self.body then
    for i, fixture in ipairs(self.fixtures) do
      local shape = fixture:getShape()
      love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
    end
  end
end,
}

function Tile:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Tile, instance, init) -- add own functions and fields
  return instance
end

return Tile
