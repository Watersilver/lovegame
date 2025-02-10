local p = require "GameObjects.prototype"
local im = require "image"
local o = require "GameObjects.objects"

local NoBody = require "GameObjects.noBody"

local Boss2HandBack = {}

function Boss2HandBack.initialize(instance)
  instance.sprite_info = im.spriteSettings.boss2
  instance.layer = 9
  instance.deathTimer = 0.5
  instance.vy = 0
end

Boss2HandBack.functions = {
  load = function (self)
    self.sprite = im.sprites["Bosses/boss2/hand_back"]
  end,

  late_update = function (self, dt)
    local parent = self.parent
    if parent and parent.exists then
      self.x = parent.x + 9 * self.x_scale
      self.y = parent.y + 18
    else
      self.deathTimer = self.deathTimer - dt
      if self.deathTimer < 0 then
        self.vy = self.vy + 10 * dt
        self.y = self.y + self.vy
        if self.deathTimer < -10 then
          o.removeFromWorld(self)
        end
      end
    end
  end,
}

function Boss2HandBack:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(NoBody, instance, init) -- add own functions and fields
  p.new(Boss2HandBack, instance, init) -- add own functions and fields
  return instance
end

return Boss2HandBack
