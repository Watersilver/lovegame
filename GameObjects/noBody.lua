local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local u = require "utilities"

local NoBody = {}

function NoBody.initialize(instance)
  instance.sprite_info = {
    {'Tiles/TestTiles', 4, 7}
  }
  instance.image_speed = 0
  instance.image_index = 0
end

NoBody.functions = {
draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]
  local worldShader = love.graphics.getShader()
  love.graphics.setShader(self.myShader)
  love.graphics.draw(
  sprite.img, frame, self.x or self.xstart, self.y or self.ystart, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  love.graphics.setShader(worldShader)
end,

trans_draw = function (self)
  local sprite = self.sprite
  local frame = sprite[self.image_index]

  local xtotal, ytotal = trans.still_objects_coords(self)

  local worldShader = love.graphics.getShader()
  love.graphics.setShader(self.myShader)
  love.graphics.draw(
  sprite.img, frame,
  xtotal, ytotal, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.cx, sprite.cy)
  love.graphics.setShader(worldShader)
end
}

function NoBody:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(NoBody, instance, init) -- add own functions and fields
  return instance
end

return NoBody
