local p = require "GameObjects.prototype"
local Nothing = require "GameObjects.drops.nothing"
local im = require "image"
local snd = require "sound"

local o = require "GameObjects.objects"

local Drop = {}

local function onPlayerTouch()
  snd.play(glsounds.getRupee)
  local rupees = session.save.rupees or 0
  rupees = math.min(rupees + 1, 9999)
  session.save.rupees = rupees
end

function Drop.initialize(instance)
  instance.sprite_info = im.spriteSettings.dropRupee
  instance.onPlayerTouch = onPlayerTouch
end

Drop.functions = {}

function Drop:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Nothing, instance, init) -- add own functions and fields
  p.new(Drop, instance, init) -- add own functions and fields
  return instance
end

return Drop
