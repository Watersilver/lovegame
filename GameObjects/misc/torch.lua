local im = require "image"
local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local parent = require "GameObjects.BrickTest"
local tl = require "GameObjects.torchLight"
local o = require "GameObjects.objects"

local Brick = {}

function Brick.initialize(instance)
  instance.image_index = 0
  instance.sprite_info = im.spriteSettings.torch
  instance.physical_properties = {
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1
  }
  instance.layer = 15
end

Brick.functions = {
  load = function(self)
    self.image_speed = 0.1
    if self.startOut then
      self:goOut(true)
    else
      self:light(true)
    end
    self.startOut = nil
  end,

  update = function (self, dt)
    self.image_index = (self.image_index + dt*60*self.image_speed) % self.sprite.frames

    if self.lit and self.duration then
      self.timer = self.timer + dt
      if self.timer > self.duration then
        self:goOut()
      end
    end
  end,

  light = function (self, init)
    if self.lit then return end
    self.lit = true
    self.image_index = 0
    self.sprite = im.sprites["Misc/Torch/lit"]
    self.timer = 0
    if self.lightEffect then
      o.removeFromWorld(self.lightEffect)
      self.lightEffect = nil
    end
    self.lightEffect = tl:new{
      xstart = self.xstart, ystart = self.ystart,
      x = self.xstart, y = self.ystart,
    }
    o.addToWorld(self.lightEffect)
    self:onLit(init)
  end,

  goOut = function (self, init)
    if not self.lit then return end
    self.lit = false
    self.image_index = 0
    self.sprite = im.sprites["Misc/Torch/out"]
    if self.lightEffect then
      o.removeFromWorld(self.lightEffect)
      self.lightEffect = nil
    end
    self:onOut(init)
  end,

  onLit = function (self, init)
  end,

  onOut = function (self, init)
  end,
}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(parent, instance, init) -- add parent functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
