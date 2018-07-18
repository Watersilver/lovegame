local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"

local Brick = {}

function Brick.initialize(instance)
  instance.physical_properties = {
    tile = true,
    edgetable = ps.shapes.edgeRect1x1
  }
  instance.sprite_info = {
    {'Brick', 2, 2}
  }
end

Brick.functions = {
draw = function (self)
  local x, y = self.body and self.body:getPosition() or self.xstart, self.ystart
  local sprite = self.sprite
  self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
  local frame = sprite[self.image_index]
  love.graphics.draw(
  sprite.img, frame, x, y, 0,
  sprite.res_x_scale, sprite.res_y_scale,
  sprite.ox, sprite.oy)
  if self.body then
    for i, fixture in ipairs(self.fixtures) do
      local shape = fixture:getShape()
      love.graphics.line(self.body:getWorldPoints(shape:getPoints()))
    end
  end
end,
load = function(self)
  self.image_speed = 0
  self.image_index = math.random() > 0.5 and 0 or 3
end
}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
