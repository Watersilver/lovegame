local u = require "utilities"
local snd = require "sound"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"

local defaultSound = glsounds.secret

local DelayedSound = {}

function DelayedSound.initialize(instance)
  instance.delay = 1
end

DelayedSound.functions = {
  load = function (self)
    if type(self.sound) == "string" then
      self.sound = snd.load_sound{self.sound}
    else
      self.sound = defaultSound
    end
  end,

  update = function (self, dt)
    if self.delay < 0 then
      snd.play(self.sound)
      o.removeFromWorld(self)
    end

    self.delay = self.delay - dt
  end,
}

function DelayedSound:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(DelayedSound, instance, init) -- add own functions and fields
  return instance
end

return DelayedSound
