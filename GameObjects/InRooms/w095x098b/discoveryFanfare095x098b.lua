local p = require "GameObjects.prototype"
local snd = require "sound"
local o = require "GameObjects.objects"

local PC = {}

function PC.initialize(instance)
end

PC.functions = {
update = function (self, dt)
  if not session.save.disc095x098 then snd.play(glsounds.secret) end
  session.save.disc095x098 = true
  o.removeFromWorld(self)
end
}

function PC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(PC, instance, init) -- add own functions and fields
  return instance
end

return PC
