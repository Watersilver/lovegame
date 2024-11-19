local p = require "GameObjects.prototype"
local conv = require 'GameObjects.Conversation.convoObject'
local mage_lab_note_convo = require 'ConversationData.data.mage_lab_note_convo'

local NPC = {}

function NPC.initialize(instance)
  instance.conversation = conv.addNew(mage_lab_note_convo, instance)
  session.setInstanceId(instance, 'mage_lab_note')
end

NPC.functions = {
  load = function ()
    session.startQuest("mainQuest2");
  end,

  -- Make note and set save.
  -- session.startQuest("mainQuest3");
  -- session.startQuest("mysticalSpells1");
  -- session.save.readMageJournal1 = true
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
