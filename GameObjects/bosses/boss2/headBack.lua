local p = require "GameObjects.prototype"
local im = require "image"
local o = require "GameObjects.objects"
local gsh = require "gamera_shake"
local snd = require "sound"

local NoBody = require "GameObjects.noBody"

local Boss2HandBack = {}

function Boss2HandBack.initialize(instance)
  instance.sprite_info = im.spriteSettings.boss2
  instance.layer = 6
  instance.deathTimer = 1
  instance.vy = 0
  instance.image_index = 0
  instance.sounds = {
    handTouchGround = glsounds.bigBoom
  }
end

Boss2HandBack.functions = {
  load = function (self)
    self.sprite = im.sprites["Bosses/boss2/skullsection"]
    if self.isJaw then
      self.sprite = im.sprites["Bosses/boss2/jaw"]
      self.deathTimer = 0
    end
  end,

  late_update = function (self, dt)
    local parent = self.parent
    if parent and parent.exists then
      self.x = parent.x
      self.y = parent.y
    else
      self.deathTimer = self.deathTimer - dt
      if self.deathTimer < 0 then
        self.vy = self.vy + 10 * dt
        self.y = self.y + self.vy
        if self.deathTimer < -1.5 then
          o.removeFromWorld(self)
          if not self.isJaw then
            snd.play(self.sounds.handTouchGround)
            gsh.newShake(mainCamera, "displacement", 3)
          end
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
