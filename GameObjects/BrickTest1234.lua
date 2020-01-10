local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local parent = require "GameObjects.BrickTest"
local parentAlt = require "GameObjects.floorTile"

local Brick = {}

function Brick.initialize(instance)
  instance.globimage_index = "globimageFast_index1234"
  if session.save.walkOnWater then
    instance.floorViscosity = "ladder"
    instance.climbable = true
  end
  instance.pushback = false
  instance.ballbreaker = false
end

Brick.functions = {
update = function (self, dt)
  self.image_index = self.imageIndexStart + im[self.globimage_index]
  -- self.image_index = math.floor((self.image_index + self.image_speed) % sprite.frames)
end,

load = function(self)
  self.image_speed = 3
  self.imageIndexStart = self.image_index
end,
}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(session.save.walkOnWater and parentAlt or parent, instance, init) -- add own functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
