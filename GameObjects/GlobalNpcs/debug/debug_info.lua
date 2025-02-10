local p = require "GameObjects.prototype"
local conv = require 'GameObjects.Conversation.convoObject'
local convodata = require 'ConversationData.data.debug_info_convo'
local npcProt = require 'GameObjects.GlobalNpcs.debug.npcPrototype'
local im = require 'image'

local NPC = {}

function NPC.initialize(instance)
  instance.conversation = conv.addNew(convodata, instance)
  instance.conversation:setIdToObject('debug_info', instance)
  instance.sprite_info = im.spriteSettings.npcTest2Sprites
end

NPC.functions = {}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcProt, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
