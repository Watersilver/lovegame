local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"

local wallDown = {}

function wallDown.initialize(instance)
  instance.physical_properties = {
    bodyType = "static",
    shape = ps.shapes.edgeRect1x1.d,
    masks = {PLAYERJUMPATTACKCAT}
  }
  instance.pushback = true
  instance.ballbreaker = true
end

wallDown.functions = {

draw = function (self)
  local sprite = self.sprite
  if sprite then
    local x, y = self.body and self.body:getPosition() or self.xstart, self.ystart
    local sz2 = 16

    if x + sz2 < caml or x - sz2 > caml + camw or y + sz2 < camt or y - sz2 > camt + camh then
      return
    end
    self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end
end,

trans_draw = function (self)
  local sprite = self.sprite
  if sprite then
    local xtotal, ytotal = trans.still_objects_coords(self)
    local sz2 = 16

    if xtotal + sz2 < caml or xtotal - sz2 > caml + camw or ytotal + sz2 < camt or ytotal - sz2 > camt + camh then
      return
    end
    self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end
end,

load = function(self)
  self.image_speed = 0
end
}

function wallDown:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(wallDown, instance, init) -- add own functions and fields
  return instance
end

return wallDown
