local p = require "GameObjects.prototype"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local snd = require "sound"
local trans = require "transitions"

local Fire = {}

function Fire.initialize(instance)
  instance.duration = 2
  instance.sprite_info = {im.spriteSettings.fire}
  instance.x_scale = 1
  instance.y_scale = 1
  instance.fuel = nil -- Object that is burning
  instance.image_index = 0
  instance.image_speed = 0.3
end

Fire.functions = {
  load = function (self)
    snd.play(glsounds.fire)
    self.timer = 0
    self.xstart = self.x
    self.ystart = self.y
  end,

  destroy = function (self)
    if self.fuel then
      if self.fuel.grass then
        self.fuel.noExplosion = true
        self.fuel:getDestroyed(nil, self.fuel.fixture)
      elseif self.fuel.onFireEnd then
        self.fuel:onFireEnd()
      end
    end
  end,

  update = function (self, dt)

    -- Determine coordinates for transition
    if self.fuel and self.fuel.exists then
      if self.fuel.body then
        local x, y = self.fuel.body:getPosition()
        self.x = x
        self.y = y
      else
        self.x = self.fuel.x or self.fuel.xstart
        self.y = self.fuel.y or self.fuel.ystart
      end
    end
    self.xlast = self.x
    self.ylast = self.y

    -- See how long fire lasts
    if self.timer > self.duration then
      o.removeFromWorld(self)
    end

    -- Determine image index
    self.image_index = (self.image_index + dt*60*self.image_speed)
    local frames = self.sprite.frames
    while self.image_index >= frames do
      -- Fire shows its first frame only once
      self.image_index = self.image_index - frames + 1
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
    local frame = sprite[math.floor(self.image_index)]
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
