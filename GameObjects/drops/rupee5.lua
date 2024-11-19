local p = require "GameObjects.prototype"
local Nothing = require "GameObjects.drops.nothing"
local im = require "image"
local snd = require "sound"

local lighting = require "ScreenEffects.lighting.lighting"
local trans = require "transitions"
local utilities = require "utilities"
local game= require "game"

local Drop = {}

local function onPlayerTouch()
  snd.play(glsounds.getRupee5)
  session.addMoney(5)
end

function Drop.initialize(instance)
  instance.sprite_info = im.spriteSettings.dropRupee5
  instance.onPlayerTouch = onPlayerTouch
  instance.shadowHeightMod = -2
  instance.image_speed = 0.2
  instance.frame_speed_mods = {
    [0] = 0.25
  }
end

Drop.functions = {
  unstoppable_update = function (self)
    local x, y = self.xstart, self.ystart + (self.zo or 0)
    local a = utilities.compute_alpha_from_table(self.image_index, self.sprite.frames, {
      first = 0.5,
      last = 0.5,
      [0] = 0.5,
      [3] = 0.6,
      [8] = 0.5
    }, self.onPreviousRoom, game.transitioning)
    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.still_objects_coords(self)
    end
    lighting.applyLight{
      type = 'rupee5',
      x = x,
      y = y,
      rgba = {
        g = 0.5,
        r = 1,
        b = 0.5,
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
