local trans = require "transitions"

local obj = {
  draw = function (self, td)
    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    local sprite = self.sprite
    local frame = sprite[math.floor(self.image_index)]
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  trans_draw = function(self)
    self.x, self.y = self.body:getPosition()
    self:draw(true)
  end,
}
