local p = require "GameObjects.prototype"
local conv = require 'GameObjects.Conversation.convoObject'
local test1 = require 'ConversationData.data.test1'
local npcProt = require 'GameObjects.GlobalNpcs.debug.npcPrototype'
local objects = require 'GameObjects.objects'

local NPC = {}

function NPC.initialize(instance)
  instance.conversation = conv.addNew(test1, instance)
  instance.conversation:setIdToObject('test1convonpc', instance)
  instance.conversation:listen('jump', function(force)
    instance:jump(tonumber(force))
  end)
  instance.vz = 0
end

NPC.functions = {

  load = function (self)
    self.conversation:listen('twirl', function()
      local o = objects.identified['test2convonpc']
      if o then
        o[1]:twirl()
      end
    end)
  end,

  jump = function (self, force)
    self.vz = (force or 0) * (-100)
  end,

  update = function (self, dt)
    npcProt.functions.update(self, dt)

    self.vz = self.vz + dt * 500

    self.zo = self.zo + self.vz * dt

    if self.zo >= 0 then
      self.zo = 0
      self.vz = 0
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
