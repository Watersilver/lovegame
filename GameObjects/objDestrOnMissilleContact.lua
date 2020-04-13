local game = require "game"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local expl = require "GameObjects.explode"
local im = require "image"
local snd = require "sound"
local emptyFunc = (require "utilities").emptyFunc


local dc = require "GameObjects.Helpers.determine_colliders"

local PC = {}

function PC.initialize(instance)
  instance.objs = {}

  instance.saveNote = false -- Provide to only happen once
  instance.objDestLayer = 13 -- change in init if you want
  instance.soundEffect = "Oracle_Bush_Cut" -- change in init if you want
  instance.graphicEffect = "bushDestruction" -- change in init if you want
  instance.fanfareWaitTime = 1
end

PC.functions = {
  load = function (self)
    -- beginContact for destructible object (destob)
    local missileCheck = function(destob, a, b, coll, aob, bob)
      -- Find which fixture belongs to whom
      local other, myF, otherF = dc.determine_colliders(destob, aob, bob, a, b)

      -- Check if hit by missile
      if other.immamissile == true then
        destob.attacked = true
        for _, obj in ipairs(self.objs) do
          o.removeFromWorld(obj)
          local explOb = expl:new{
            x = obj.x or obj.xstart, y = obj.y or obj.ystart,
            layer = obj.explLayer or obj.layer,
            explosionNumber = 1,
            sprite_info = {im.spriteSettings[self.graphicEffect]},
            image_speed = 0.3,
            sounds = snd.load_sounds({explode = {"Effects/" .. self.soundEffect}})
          }
          o.addToWorld(explOb)
        end
        self.timer = self.fanfareWaitTime
        if self.saveNote and type(self.saveNote) == "string" then
          session.save[self.saveNote] = true
        end
      end
    end

    local alreadyDestroyed = self.saveNote and session.save[self.saveNote]
    for _, object in ipairs(o.draw_layers[self.objDestLayer]) do
      if not object.onPreviousRoom then
        table.insert(self.objs, object)
        object.beginContact = missileCheck
        if alreadyDestroyed then
          o.removeFromWorld(object)
          if object.draw then object.draw = emptyFunc end
          if object.trans_draw then object.trans_draw = emptyFunc end
        end
      end
    end
    if alreadyDestroyed then o.removeFromWorld(self) end
  end,

  update = function (self, dt)

    if self.timer then

      if self.timer < 0 then
        snd.play(glsounds.secret)
        o.removeFromWorld(self)
      end

      self.timer = self.timer - dt

    end

  end
}

function PC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(PC, instance, init) -- add own functions and fields
  return instance
end

return PC
