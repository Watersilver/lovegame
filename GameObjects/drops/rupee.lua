local p = require "GameObjects.prototype"
local Nothing = require "GameObjects.drops.nothing"
local im = require "image"
local snd = require "sound"

local o = require "GameObjects.objects"

local Drop = {}

local function onPlayerTouch()
  snd.play(glsounds.getRupee)
  session.addMoney(1)
end

function Drop.initialize(instance)
  instance.sprite_info = im.spriteSettings.dropRupee
  instance.onPlayerTouch = onPlayerTouch
  instance.shadowHeightMod = -2
end

Drop.functions = {}

function Drop:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Nothing, instance, init) -- add own functions and fields
  p.new(Drop, instance, init) -- add own functions and fields
  return instance
end

return Drop
