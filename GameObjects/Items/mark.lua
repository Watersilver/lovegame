local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local im = require "image"

local Mark = {}

function Mark.initialize(instance)
  instance.sprite_info = {im.spriteSettings.testbrick}
  instance.image_speed = 0
  instance.image_index = 1
end

Mark.functions = {
draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]
  love.graphics.draw(
  sprite.img, frame, self.xstart, self.ystart, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  if self.body then
    -- draw
  end
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
  if self.body then
    -- draw
  end
end,

delete = function (self)
  if self.creator.mark == self then self.creator.mark = nil end
end
}

function Mark:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Mark, instance, init) -- add own functions and fields
  return instance
end

return Mark
