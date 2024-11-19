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
  snd.play(glsounds.getRupee)
  session.addMoney(1)
end

function Drop.initialize(instance)
  instance.sprite_info = im.spriteSettings.dropRupee
  instance.onPlayerTouch = onPlayerTouch
  instance.image_speed = 0.2
  instance.frame_speed_mods = {
    [0] = 0.25
  }
end

Drop.functions = {
  unstoppable_update = function (self)
    local x, y = self.xstart, self.ystart + (self.zo or 0)
    local a = utilities.compute_alpha_from_table(self.image_index, self.sprite.frames, {
      first = 0.4,
      last = 0.4,
      [0] = 0.4,
      [2] = 0.5,
      [7] = 0.4
    }, self.onPreviousRoom, game.transitioning)
    if game.transitioning and game.transitioning.type == 'scrolling' then
      x, y = trans.still_objects_coords(self)
    end
    lighting.applyLight{
      type = 'rupee',
      x = x,
      y = y,
      rgba = {
        g = 1,
        r = 0.2,
        b = 0.8,
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
