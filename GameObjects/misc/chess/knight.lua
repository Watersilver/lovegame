local im = require "image"
local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local parent = require "GameObjects.misc.chess.piece"

local Queen = {}

function Queen.initialize(instance)
  instance.sprite_info = im.spriteSettings.knight
  instance.physical_properties.shape = ps.shapes.circleThreeFourths
  instance.spritefixture_properties = {shape = ps.shapes.rookSprite}
  instance.spriteOffset = 2
end

Queen.functions = {}

function Queen:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(parent, instance, init) -- add parent functions and fields
  p.new(Queen, instance, init) -- add own functions and fields
  return instance
end

return Queen
