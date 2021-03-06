local p = require "GameObjects.prototype"
local Nothing = require "GameObjects.drops.nothing"
local itemGetPoseAndDlg = require "GameObjects.GlobalNpcs.itemGetPoseAndDlg"
local im = require "image"
local snd = require "sound"
local ps = require "physics_settings"

local itemInfo = (require "GameObjects.GlobalNpcs.fanfareGottenItems.rupee200").itemInfo

local o = require "GameObjects.objects"

local Drop = {}

local function onPlayerTouch()
  local rupees200 = itemGetPoseAndDlg:new(itemInfo)
  o.addToWorld(rupees200)
end

function Drop.initialize(instance)
  instance.sprite_info = itemInfo.itemSprite
  instance.onPlayerTouch = onPlayerTouch
  instance.shadowHeightMod = 0
end

Drop.functions = {}

function Drop:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Nothing, instance, init) -- add own functions and fields
  p.new(Drop, instance, init) -- add own functions and fields
  return instance
end

return Drop
