local p = require "GameObjects.prototype"
local npcProt = require 'GameObjects.GlobalNpcs.debug.npcPrototype'

local NPC = {}

function NPC.initialize(instance)
  session.setInstanceId(instance, 'test2convonpc')
end

NPC.functions = {}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcProt, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
