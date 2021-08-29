local p = require "GameObjects.prototype"
local game = require "game"
local o = require "GameObjects.objects"
local u = require "utilities"
local snd = require "sound"
local ds = require "GameObjects.delayedSound"

local Curse = {}

function Curse.initialize(instance)
  instance.timer = 0
  instance.timeDone = false
  instance.duration = 24
  instance.durDiv4 = instance.duration / 4
  instance.run = true
end

Curse.functions = {
  unsealPath = function (self)
    game.room.upTrans = {
      {
        roomTarget = "Rooms/cursedForest/dungeonRoute1.lua",
        xleftmost = 0, xrightmost = 520,
        xmod = 0, ymod = 0
      }
    }
    o.removeFromWorld(self)
    o.addToWorld(ds:new{delay = 1})
  end,

  update = function (self, dt)
    if not self.timerDone then
      -- Determine if bell will ring
      local timerPrevMod = self.timer % self.durDiv4
      -- Update timer
      self.timer = self.timer + dt
      if self.timer > self.duration then
        self.timerDone = true
        -- ring last bell and change path if player solved puzle
        snd.play(glsounds.bell);
        if pl1 and pl1.exists and pl1.x < 383
        and pl1.x > 351 and pl1.y < 287 and
        pl1.y > 255 then
          self:unsealPath()
          session.save.solvedForestChessPuzzle = true
        end
      else
        local timerMod = self.timer % self.durDiv4
        if timerPrevMod > timerMod then
          -- ring bell
          snd.play(glsounds.bell);
        end
      end
    end

  end,

  unstoppable_update = function (self)
    if self.run and session.save.solvedForestChessPuzzle then
      self:unsealPath()
    end
    self.run = false
  end
}

function Curse:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(Curse, instance, init) -- add own functions and fields
  return instance
end

return Curse
