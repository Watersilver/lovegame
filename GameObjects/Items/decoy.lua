local p = require "GameObjects.prototype"
local bspl = require "GameObjects.Items.bombsplosion"
local u = require "utilities"
local o = require "GameObjects.objects"
local im = require "image"
local snd = require "sound"
local trans = require "transitions"

local Decoy = {}

function Decoy.initialize(instance)
  instance.duration = 5
  instance.sprite_info = im.spriteSettings.playerSprites
  instance.x_scale = 1
  instance.y_scale = 1
  instance.vx = 0
  instance.vy = 0
  instance.alpha = 0
end

Decoy.functions = {
  load = function (self)
    snd.play(glsounds.decoy)
    self.timer = 0
    session.decoy = self
    self.xstart = self.x
    self.ystart = self.y
    if self.side == "down" then
      self.side = "up"
    elseif self.side == "up" then
      self.side = "down"
    elseif self.side == "left" then
      self.side = "right"
    else
      self.side = "left"
    end
    if self.side ~= "right" then
      self.sprite = im.sprites["Witch/mdust_" .. self.side]
    else
      self.sprite = im.sprites["Witch/mdust_left"]
      self.x_scale = -1
    end
    self.image_index = 1
  end,

  delete = function (self)
    if session.decoy == self then
      session.decoy = nil
    end
  end,

  update = function (self, dt)
    if self.timer > self.duration and session.decoy == self then
      session.decoy = nil
    end
    if self ~= session.decoy then
      self.alpha = self.alpha - dt * 5
      if self.alpha <= 0 then
        o.removeFromWorld(self)
      end
    else
      self.alpha = self.alpha + dt * 5
    end
    if self.alpha > 1 then self.alpha = 1 end
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
    local cr, cg, cb, ca = love.graphics.getColor()
    love.graphics.setColor(cr * self.alpha, cg * self.alpha, cb * self.alpha, self.alpha * COLORCONST)
    love.graphics.draw(
    sprite.img, frame, x, y, 0,
    sprite.res_x_scale*self.x_scale,
    sprite.res_y_scale*self.y_scale,
    sprite.cx, sprite.cy)
    love.graphics.setColor(cr, cg, cb, ca)
    -- love.graphics.setShader(worldShader)
  end,

  trans_draw = function(self)
    self.x, self.y = self.xstart, self.ystart
    self:draw(true)
  end,
}

function Decoy:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Decoy, instance, init) -- add own functions and fields
  return instance
end

return Decoy
