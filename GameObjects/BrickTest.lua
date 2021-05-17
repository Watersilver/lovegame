local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"

local Brick = {}

function Brick.initialize(instance)
  instance.physical_properties = {
    tile = true,
    edgetable = ps.shapes.edgeRect1x1
  }
  instance.sprite_info = {
    {'Brick', 2, 2}
  }
  instance.pushback = true
  instance.ballbreaker = true
end

Brick.functions = {
draw = function (self)
  local x, y = self.body and self.body:getPosition() or self.xstart, self.ystart
  local sz2 = 16

  if x + sz2 < caml or x - sz2 > caml + camw or y + sz2 < camt or y - sz2 > camt + camh then
    return
  end

  local sprite = self.sprite
  local int_image_index = math.floor(self.image_index)
  local frame = sprite[int_image_index]
  love.graphics.draw(
  sprite.img, frame, x, y, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   for i, fixture in ipairs(self.fixtures) do
  --     local shape = fixture:getShape()
  --     love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
  --   end
  -- end
end,

trans_draw = function (self)
  local xtotal, ytotal = trans.still_objects_coords(self)
  local sz2 = 16

  if xtotal + sz2 < caml or xtotal - sz2 > caml + camw or ytotal + sz2 < camt or ytotal - sz2 > camt + camh then
    return
  end

  local sprite = self.sprite
  local int_image_index = math.floor(self.image_index)
  local frame = sprite[int_image_index]
  love.graphics.draw(
  sprite.img, frame, xtotal, ytotal, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  -- if self.body then
  --   for i, fixture in ipairs(self.fixtures) do
  --     local shape = fixture:getShape()
  --     love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
  --   end
  -- end
end,

lift_delete = function(self)
end
}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
