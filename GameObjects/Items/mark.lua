local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local im = require "image"

local Mark = {}

local floor = math.floor

local image_indexProgress = 0
local image_indexProgressDirection = 1

function Mark.initialize(instance)
  instance.sprite_info = {im.spriteSettings.mark}
  image_indexProgress = 0
  image_indexProgressDirection = 1
  instance.image_index = image_indexProgress
  instance.seeThrough = true
end

Mark.functions = {
  load = function (self)
    framesSlice = 1/self.sprite.frames
  end,

  update = function (self, dt)
    image_indexProgress = image_indexProgress + dt * image_indexProgressDirection
    if image_indexProgress >= 1 then
      image_indexProgress = 1 - framesSlice
      image_indexProgressDirection = - image_indexProgressDirection
    elseif image_indexProgress < 0 then
      image_indexProgress = framesSlice
      image_indexProgressDirection = - image_indexProgressDirection
    end
    self.image_index = floor(image_indexProgress * self.sprite.frames)
  end,

  draw = function (self)
    local sprite = self.sprite
    local frame = sprite[self.image_index]
    love.graphics.draw(
    sprite.img, frame, self.xstart, self.ystart+2, 0,
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
    xtotal, ytotal+2, 0,
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
