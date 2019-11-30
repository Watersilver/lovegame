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
  {{{cc,cc,cc,cc},"I am the Level Manager."},-1, "left"},
  {{{cc,cc,cc,cc},"I can raise the level of everything upgradable on you by 1."},-1, "left"},
  {{{cc,cc,cc,cc},"If you're level 3, it'll reset to 0."},-1, "left"},
  {{{cc,cc,cc,cc},"Done!"},-1, "left"},
  {{{cc,cc,cc,cc},"All right then..."},-1, "left"}
}

local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = 2
end
activateFuncs[2] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = 3
end
activateFuncs[3] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  dlg.simpleBinaryChoice.setUp("DO IT!", "Nah.")
  self.next = {4, 5}
end
activateFuncs[4] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  session.save.athleticsLvl = (session.save.athleticsLvl or 0) + 1
  if session.save.athleticsLvl > 3 then session.save.athleticsLvl = 0 end
  session.save.armorLvl = (session.save.armorLvl or 0) + 1
  if session.save.armorLvl > 3 then session.save.armorLvl = 0 end
  session.save.swordLvl = (session.save.swordLvl or 0) + 1
  if session.save.swordLvl > 3 then session.save.swordLvl = 0 end
  session.save.magicLvl = (session.save.magicLvl or 0) + 1
  if session.save.magicLvl > 3 then session.save.magicLvl = 0 end
  self.next = "end"
end
activateFuncs[5] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end

function NPC.initialize(instance)
  instance.myText = myText
  instance.activateFuncs = activateFuncs
  instance.sprite_info = im.spriteSettings.npcTest2Sprites
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
