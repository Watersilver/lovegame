local p = require "GameObjects.prototype"
local im = require "image"
local ps = require "physics_settings"
local trans = require "transitions"
local nii = require "GameObjects.abstract.normalisedImageIndex"
local o = require "GameObjects.objects"
local si = require "sight"

local directionToFacing = {
  "down",
  "left",
  "up",
  "right"
}

local obj = {}

function obj.initialize(instance)
  -- If I want it to have some sprite
  instance.sprite_info = im.spriteSettings.boss5
  instance.layer = pl1.layer

  instance.direction = 1

  instance.lookFor = si.lookFor
end

obj.functions = {
  load = function(self)
    self:setFPS(0, 0)
    self:setII(2, 1)
  end,

  update = function (self)
    if not self.parent.exists then o.removeFromWorld(self) return end

    self.x = self.parent.x
    self.y = self.parent.y

    self.facing = self:getFacing()

    -- Get tricked by decoy
    self.target = session.decoy or pl1
    -- Look for player
    if self.lookFor then self.canSeePlayer = self:lookFor(self.target, {ignore = {self.parent}}) end

    if self.direction == 4 then
      self.x_scale = -1
      self:setIIx(1)
    else
      self.x_scale = 1
      self:setIIx(self.direction - 1)
    end
  end,

  getFacing = function (self)
    return directionToFacing[self.direction]
  end,

  lookUp = function (self)
    self.direction = 3
  end,

  lookDown = function (self)
    self.direction = 1
  end,

  lookLeft = function (self)
    self.direction = 2
  end,

  lookRight = function (self)
    self.direction = 4
  end
}

function obj:new(init)
  local instance = p:new(init) -- add parent functions and fields
  p.new(nii, instance) -- add parent functions and fields
  p.new(obj, instance) -- add own functions and fields
  return instance
end

return obj
