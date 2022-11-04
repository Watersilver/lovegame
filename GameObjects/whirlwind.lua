local p = require "GameObjects.prototype"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local snd = require "sound"
local trans = require "transitions"

local Fire = {}

function Fire.initialize(instance)
  instance.duration = 2
  instance.sprite_info = {im.spriteSettings.whirlwind}
  instance.x_scale = 1
  instance.y_scale = 1
  instance.eye = nil -- Object that is the eye of the storm
  instance.image_index = 0
  instance.twistSpeed = 0.2
end

Fire.functions = {
  load = function (self)
    snd.play(glsounds.wind)
    self.timer = 0
    self.xstart = self.x
    self.ystart = self.y
  end,

  destroy = function (self)
    if self.timer == 0 and self.eye and self.eye.exists and self.eye.onWhirlwindEnd then
      self.eye:onWhirlwindEnd(self)
    end
  end,

  update = function (self, dt)

    -- Determine coordinates for transition
    -- if self.eye and self.eye.exists then
    --   if self.eye.body then
    --     local x, y = self.eye.body:getPosition()
    --     self.x = x
    --     self.y = y
    --   else
    --     self.x = self.eye.x or self.eye.xstart
    --     self.y = self.eye.y or self.eye.ystart
    --   end
    -- end
    self.xlast = self.x
    self.ylast = self.y

    -- See how long whirlwind lasts
    if self.timer > self.duration then
      o.removeFromWorld(self)
    end

    -- Determine x scale
    self.x_scale = u.sign(math.sin(self.timer * 30))
    if self.x_scale == 0 then self.x_scale = 1 end

    if self.timer == 0 and self.eye and self.eye.exists and self.eye.onWhirlwindStart then
      self.eye:onWhirlwindStart(self)
    end

    -- update timer
    self.timer = self.timer + dt
  end,

  draw = function(self, td)
    local x, y = self.x, self.y

    if td then
      x, y = trans.moving_objects_coords(self)
    end

    self.x, self.y = x, y

    local sprite = self.sprite
    local frame = sprite[0]
    -- local worldShader = love.graphics.getShader()

    -- love.graphics.setShader(self.myShader)
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale*self.x_scale,
    sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    -- love.graphics.setShader(worldShader)
  end,

  trans_draw = function(self)
    self.x, self.y = self.xlast, self.ylast
    self:draw(true)
  end,
}

function Fire:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Fire, instance, init) -- add own functions and fields
  return instance
end

return Fire
