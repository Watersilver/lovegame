local p = require "GameObjects.prototype"
local npcProt = require 'GameObjects.GlobalNpcs.debug.npcPrototype'

local NPC = {}

function NPC.initialize(instance)
  session.setInstanceId(instance, 'test2convonpc')
  instance.twirling = false
end

NPC.functions = {
  twirl = function (self)
    self.twirling = true
  end,

  update = function (self, dt)
    npcProt.functions.update(self, dt)
    if self.twirling then
      self.angle = self.angle + dt * math.pi * 2 * 3

      if self.angle >= math.pi * 2 then
        self.angle = 0
        self.twirling = false
      end
    end
  end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcProt, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
