local p = require "GameObjects.prototype"

local npcP = require "GameObjects.npcPrototype"
local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local Sign = require "GameObjects.GlobalNpcs.sign2"

local NPC = {}

function NPC.initialize(instance)
end

NPC.functions = {
  getDlg = function (self)
    return "one's words are lies, one's words are true\n\z
    unprovoked violence will show you who's who."
  end,
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(dlgCtrl, instance) -- add parent functions and fields
  p.new(npcP, instance) -- add parent functions and fields
  p.new(Sign, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
