local p = require "GameObjects.prototype"
local bspl = require "GameObjects.Items.bombsplosion"
local u = require "utilities"
local o = require "GameObjects.objects"

local ChainReaction = {}

function ChainReaction.initialize(instance)
  instance.freq = 0.1
  instance.radius = 16 * 10
  instance.explosions = 20
end

ChainReaction.functions = {
  load = function (self)
    self.timer = self.freq
  end,

  update = function (self, dt)
    if self.timer >= self.freq then
      self.timer = 0
      local xmod, ymod
      if self.currentExplosionNum then
        xmod, ymod = u.polarToCartesian(love.math.random(self.radius), love.math.random(2 * math.pi))
        self.currentExplosionNum = self.currentExplosionNum + 1
      else
        xmod, ymod = 0, 0
        self.currentExplosionNum = 1
      end
      local boom = bspl:new{
        x = self.x + xmod,
        y = self.y + ymod,
        layer = self.layer,
        dustAccident = true
      }
      o.addToWorld(boom)
      if self.currentExplosionNum >= self.explosions then
        o.removeFromWorld(self)
      end
    end
    self.timer = self.timer + dt
  end,
}

function ChainReaction:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(ChainReaction, instance, init) -- add own functions and fields
  return instance
end

return ChainReaction
