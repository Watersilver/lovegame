local p = require "GameObjects.prototype"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local snd = require "sound"
local td = require "movement"; td = td.top_down

local sh = require "GameObjects.shadow"

local BnD = {}

function BnD.initialize(instance)
  -- instance.sprite_info = {im.spriteSettings.fire}
  instance.x_scale = 1
  instance.y_scale = 1
  instance.image_index = 0
  instance.image_speed = 0
  instance.zo = 0
  instance.zvel = 15
  instance.gravity = 45
  instance.hasShadow = false
  instance.bounceDir = u.choose(math.pi, 0) + u.choose(-1, 1) * math.pi * 0.25 * love.math.random()
  instance.bounceSpeed = 2 + 10 * love.math.random()
end

function BnD.quickBnD(bouncingObj, args)
  local init = {
    sprite_info = bouncingObj.sprite_info,
    layer = bouncingObj.layer,
    x = bouncingObj.x,
    xstart = bouncingObj.x,
    y = bouncingObj.y,
    ystart = bouncingObj.y
  }
  if args.init then
    for key, val in pairs(args.init) do
      init[key] = val;
    end
  end
  local bndInstance = BnD:new(init)
  o.addToWorld(bndInstance)
end

BnD.functions = {
  load = function (self)
    self.xstart = self.x
    self.ystart = self.y
    self.vx, self.vy = u.polarToCartesian(self.bounceSpeed, self.bounceDir)
  end,

  update = function (self, dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    self.xlast = self.x
    self.ylast = self.y

    if self.zo == 0 and self.zvel == 0 then
      o.removeFromWorld(self)
    end

    if self.xscaleReversalFreq then
      if not self.xscaleReversalTimer then self.xscaleReversalTimer = 0 end
      if self.xscaleReversalTimer > self.xscaleReversalFreq then
        self.xscaleReversalTimer = self.xscaleReversalTimer - self.xscaleReversalFreq
        self.x_scale = -self.x_scale
      end
      self.xscaleReversalTimer = self.xscaleReversalTimer + dt
    end

    td.zAxis(self, dt)

    if self.hasShadow then
      sh.handleShadow(self)
    end

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
    sprite.img, frame, x, y + self.zo, 0,
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

function BnD:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(BnD, instance, init) -- add own functions and fields
  return instance
end

return BnD
