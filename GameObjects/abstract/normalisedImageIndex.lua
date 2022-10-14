local p = require "GameObjects.prototype"
local im = require "image"
local trans = require "transitions"
local u = require "utilities"

local obj = {}

function obj.initialize(instance)
  instance.sprite_info = im.spriteSettings.bladeTrap

  -- image index normalised coordinates
  -- Remember, 0 and 1 are both the first frame and in between are theothers
  instance.iinX = 0
  instance.iinY = 0
  instance.iinvX = 0
  instance.iinvY = 0
  instance.x = 0
  instance.y = 0
end

obj.functions = {
  -- Convert non normalised coordinates for image index
  setIIx = function (self, x)
    self.iinX = self.sprite.framesX == 1 and 0 or x / self.sprite.framesX % 1
  end,
  setIIy = function (self, y)
    self.iinY = self.sprite.framesY == 1 and 0 or y / self.sprite.framesY % 1
  end,
  setII = function (self, x, y)
    self:setIIx(x)
    self:setIIy(y)
  end,

  -- Get image index from normalised coordinates
  getII = function (self)
    local x = u.round(self.sprite.framesX * self.iinX) % self.sprite.framesX
    local y = u.round(self.sprite.framesY * self.iinY) % self.sprite.framesY

    return y * self.sprite.framesX + x
  end,

  setFPSx = function (self, frames)
    self.iinvX = frames / self.sprite.framesX
  end,
  setFPSy = function (self, frames)
    self.iinvY = frames / self.sprite.framesY
  end,
  setFPS = function (self, framesX, framesY)
    self:setFPSx(framesX)
    self:setFPSy(framesY)
  end,

  -- Used by draw and trans_draw
  customDraw = function (self, frame, x, y)
    local sprite = self.sprite
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale, sprite.res_y_scale,
    sprite.cx, sprite.cy)
  end,

  draw = function (self)
    if self.invisible then return end
    local x, y = self.x, self.y

    -- Apply normalized image speed
    self.iinX = (self.iinX + self.iinvX * delta_time) % 1
    self.iinY = (self.iinY + self.iinvY * delta_time) % 1

    local frame = self.sprite[self:getII()]

    self:customDraw(frame, x, y)
  end,

  trans_draw = function (self)
    if self.invisible then return end
    local x, y = trans.moving_objects_coords(self)
    local frame = self.sprite[self:getII()]

    self:customDraw(frame, x, y)
  end
}

function obj:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(obj, instance) -- add own functions and fields
  return instance
end

return obj
