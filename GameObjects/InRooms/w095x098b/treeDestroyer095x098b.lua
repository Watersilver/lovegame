local game = require "game"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local expl = require "GameObjects.explode"
local im = require "image"
local snd = require "sound"


local dc = require "GameObjects.Helpers.determine_colliders"

local PC = {}

function PC.initialize(instance)
  instance.trees = {}

  -- beginContact
  instance.missileCheck = function(self, a, b, coll, aob, bob)
    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Check if hit by missile
    if other.immamissile == true then
      self.attacked = true
      for _, tree in ipairs(instance.trees) do
        o.removeFromWorld(tree)
        local explOb = expl:new{
          x = tree.x or tree.xstart, y = tree.y or tree.ystart,
          layer = tree.explLayer or tree.layer,
          explosionNumber = 1,
          sprite_info = {im.spriteSettings.bushDestruction},
          image_speed = 0.3,
          sounds = snd.load_sounds({explode = {"Effects/Oracle_Bush_Cut"}})
        }
        o.addToWorld(explOb)
      end
      instance.timer = 1
      session.save.td095x099 = true
    end
  end
end

PC.functions = {
update = function (self, dt)

  if not self.insertedTrees then
    for _, object in ipairs(o.draw_layers[13]) do
      table.insert(self.trees, object)
      object.beginContact = self.missileCheck
      if session.save.td095x099 then o.removeFromWorld(object) end
    end
    if session.save.td095x099 then o.removeFromWorld(self) end
    self.insertedTrees = true
  end

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
