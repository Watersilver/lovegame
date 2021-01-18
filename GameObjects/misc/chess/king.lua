local im = require "image"
local ps = require "physics_settings"
local p = require "GameObjects.prototype"
local parent = require "GameObjects.misc.chess.piece"

local King = {}

function King.initialize(instance)
  instance.sprite_info = im.spriteSettings.king
  instance.physical_properties.shape = ps.shapes.circle1
  instance.spritefixture_properties = {shape = ps.shapes.kingSprite}
  instance.spriteOffset = 13
end

King.functions = {}

function King:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(parent, instance, init) -- add parent functions and fields
  p.new(King, instance, init) -- add own functions and fields
  return instance
end

return King
