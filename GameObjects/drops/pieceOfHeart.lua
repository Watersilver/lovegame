local p = require "GameObjects.prototype"
local Nothing = require "GameObjects.drops.nothing"
local itemGetPoseAndDlg = require "GameObjects.GlobalNpcs.itemGetPoseAndDlg"
local im = require "image"
local snd = require "sound"
local ps = require "physics_settings"
local o = require "GameObjects.objects"

local itemInfo = (require "GameObjects.GlobalNpcs.fanfareGottenItems.pieceOfHeart").itemInfo

local o = require "GameObjects.objects"

local Drop = {}

local function onPlayerTouch()
  local pieceOfHeart = itemGetPoseAndDlg:new(itemInfo)
  session.save.randomPiecesOfHeart = (session.save.randomPiecesOfHeart or 0) + 1
  o.addToWorld(pieceOfHeart)
end

function Drop.initialize(instance)
  instance.sprite_info = itemInfo.itemSprite
  instance.onPlayerTouch = onPlayerTouch
  instance.shadowHeightMod = 0
end

Drop.functions = {
  load = function (self)
    self.x = self.xstart
    self.y = self.ystart
    if session.onScreenPOC then
      self.onPlayerTouch = nil
      o.removeFromWorld(self)
    end
    session.onScreenPOC = (session.onScreenPOC or 0) + 1
  end,

  delete = function (self)
    session.onScreenPOC = session.onScreenPOC - 1
    if session.onScreenPOC <= 0 then session.onScreenPOC = nil end
  end
}

function Drop:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Nothing, instance, init) -- add own functions and fields
  p.new(Drop, instance, init) -- add own functions and fields
  return instance
end

return Drop
