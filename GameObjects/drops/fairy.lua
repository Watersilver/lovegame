local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local Wasp = require "GameObjects.enemies.wasp"

local Fairy = {}

function Fairy.initialize(instance)
  instance.damager = false
  instance.fairy = true
  instance.sprite_info = im.spriteSettings.dropFairy
  instance.physical_properties.masks = {PLAYERATTACKCAT, PLAYERJUMPATTACKCAT, FLOORCOLLIDECAT}
end

Fairy.functions = {}

function Fairy:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Wasp, instance) -- add parent functions and fields
  p.new(Fairy, instance, init) -- add own functions and fields
  return instance
end

return Fairy
