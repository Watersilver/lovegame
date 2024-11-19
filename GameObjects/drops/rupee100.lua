local p = require "GameObjects.prototype"
local Nothing = require "GameObjects.drops.nothing"
local itemGetPoseAndDlg = require "GameObjects.GlobalNpcs.itemGetPoseAndDlg"
local im = require "image"
local snd = require "sound"
local ps = require "physics_settings"

local itemInfo = (require "GameObjects.GlobalNpcs.fanfareGottenItems.rupee100").itemInfo

local o = require "GameObjects.objects"

local lighting = require "ScreenEffects.lighting.lighting"
local trans = require "transitions"
local utilities = require "utilities"
local game= require "game"

local Drop = {}

local function onPlayerTouch()
  local rupees100 = itemGetPoseAndDlg:new(itemInfo)
  rupees100.image_speed = 0.2
  rupees100.frame_speed_mods = {
    [0] = 0.25
  }
  o.addToWorld(rupees100)
end

function Drop.initialize(instance)
  instance.sprite_info = itemInfo.itemSprite
  instance.onPlayerTouch = onPlayerTouch
  instance.shadowHeightMod = 0
  instance.image_speed = 0.2
  instance.frame_speed_mods = {
    [0] = 0.25
  }
end

Drop.functions = {
  unstoppable_update = function (self)
    local x, y = self.xstart, self.ystart + (self.zo or 0)
    local a = utilities.compute_alpha_from_table(self.image_index, self.sprite.frames, {
      first = 0.7,
      last = 0.7,
      [0] = 0.7,
      [3] = 0.9,
      [4] = 0.9,
      [5] = 0.9,
      [9] = 0.7
    }, self.onPreviousRoom, game.transitioning)
    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.still_objects_coords(self)
    end
    lighting.applyLight{
      type = 'rupee100',
      x = x,
      y = y,
      rgba = {
        g = 0.8,
        r = 1,
        b = 0.4,
        a = a
      }
    }
  end
}

function Drop:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Nothing, instance, init) -- add own functions and fields
  p.new(Drop, instance, init) -- add own functions and fields
  return instance
end

return Drop
