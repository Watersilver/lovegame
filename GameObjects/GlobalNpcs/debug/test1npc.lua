local p = require "GameObjects.prototype"
local conv = require 'GameObjects.Conversation.convoObject'
local test1 = require 'ConversationData.data.test1'
local npcProt = require 'GameObjects.GlobalNpcs.debug.npcPrototype'

local NPC = {}

function NPC.initialize(instance)
  instance.conversation = conv.addNew(test1, instance)
  session.setInstanceId(instance, 'test1convonpc')
end

NPC.functions = {}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcProt, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
