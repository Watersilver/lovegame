local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local inp = require "input"
local dlg = require "dialogue"
local npcTest = require "GameObjects.npcTest"
local typicalNpc = require "GameObjects.GlobalNpcs.typicalNpc"


local floor = math.floor

local NPC = {}

local cc = COLORCONST

local myText = {
  {{{cc,cc,cc,cc},"Hey there. I am the Power Toggler!"},-1, "left"},
  {{{cc,cc,cc,cc},"Wanna toggle Din's Power, Nayru's Wisdom and Farore's Courage?"}, -1, "left"},
  {{{cc,cc,cc,cc},"Done!"},-1, "left"},
  {{{cc,cc,cc,cc},"Suit yourself."},-1, "left"}
}

local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = 2
end
activateFuncs[2] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  dlg.simpleBinaryChoice.setUp("Teach me!", "No!")
  self.next = {3, 4}
end
activateFuncs[3] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  session.save.nayrusWisdom = not session.save.nayrusWisdom
  session.save.dinsPower = not session.save.dinsPower
  session.save.faroresCourage = not session.save.faroresCourage
  if self.activator then self.activator:readSave() end
  self.next = "end"
end
activateFuncs[4] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end

function NPC.initialize(instance)
  instance.myText = myText
  instance.activateFuncs = activateFuncs
  instance.onDialogueRealEnd = onDialogueRealEnd
  instance.sprite_info = im.spriteSettings.npcTest3Sprites
  instance.counter = 1
end

NPC.functions = {}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(typicalNpc, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
