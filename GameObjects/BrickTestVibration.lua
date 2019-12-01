local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local parent = require "GameObjects.BrickTest"

local Brick = {}

function Brick.initialize(instance)
  instance.globimage_index = "globimage_index4loop"
end

Brick.functions = {
update = function (self, dt)
  -- self.imagePhase = (self.imagePhase + 3 * dt) % 8
  -- while self.imagePhase > 8 do self.imagePhase = self.imagePhase - 8 end
  -- if self.imagePhase > 4 then
  --   self.image_index = self.imageIndexStart + 4 -(self.imagePhase - 4)
  -- else
  --   self.image_index = self.imagePhase + self.imageIndexStart
  -- end
  self.image_index = self.imageIndexStart + im[self.globimage_index]
end,

load = function(self)
  self.image_speed = 3
  self.imagePhase = 0
  self.imageIndexStart = self.image_index
end,
}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(parent, instance, init) -- add own functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
