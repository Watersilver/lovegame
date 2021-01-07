local im = require "image"
local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local parent = require "GameObjects.BrickTest"
local u = require "utilities"

local angleChunk = 2 * math.pi / 8

local Brick = {}

function Brick.initialize(instance)
  instance.image_index = 4
  instance.sprite_info = im.spriteSettings.eyeStatue
  instance.physical_properties = {
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1
  }
  instance.layer = 15
end

Brick.functions = {
  lookTowards = function (self, angle)
    if not angle then
      self.image_index = 4
    elseif angle <= angleChunk * 0.5 and angle > -angleChunk * 0.5 then
      -- right
      self.image_index = 5
    elseif angle <= -angleChunk * 0.5 and angle > -angleChunk * 1.5 then
      -- right up
      self.image_index = 2
    elseif angle <= -angleChunk * 1.5 and angle > -angleChunk * 2.5 then
      -- up
      self.image_index = 1
    elseif angle <= -angleChunk * 2.5 and angle > -angleChunk * 3.5 then
      -- left up
      self.image_index = 0
    elseif angle <= -angleChunk * 3.5 or angle > angleChunk * 3.5 then
      -- left
      self.image_index = 3
    elseif angle <= angleChunk * 3.5 and angle > angleChunk * 2.5 then
      -- left down
      self.image_index = 6
    elseif angle <= angleChunk * 2.5 and angle > angleChunk * 1.5 then
      -- down
      self.image_index = 7
    elseif angle <= angleChunk * 1.5 and angle > angleChunk * 0.5 then
      -- right down
      self.image_index = 8
    end
  end,

  update = function (self, dt)
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.target and self.target.exists and self.target.x then
      local _, th = u.cartesianToPolar(self.target.x - self.x, self.target.y - self.y)
      self:lookTowards(th)
    else
      self:lookTowards()
    end
  end,
}

function Brick:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(parent, instance, init) -- add parent functions and fields
  p.new(Brick, instance, init) -- add own functions and fields
  return instance
end

return Brick
