local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local inp = require "input"
local inv = require "inventory"
local dlg = require "dialogue"
local u = require "utilities"
local o = require "GameObjects.objects"
local game = require "game"

local npcTest = require "GameObjects.npcTest"
local typicalNpc = require "GameObjects.GlobalNpcs.typicalNpc"


local floor = math.floor

local NPC = {}

local cc = COLORCONST

-- write the text
local myText = {
  {{{cc,cc,cc,cc},"Auto."},-1, "left"},
  {{{cc,cc,cc,cc},"Activated!"},-1, "left"}
}

-- do the funcs
local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = 2
end
activateFuncs[2] = function (self, dt, textIndex)
  self.typical_activate(self, dt, textIndex)
  self.next = "end"
end

function NPC.initialize(instance)
  instance.myText = myText
  instance.activateFuncs = activateFuncs
  instance.dontDrawOverPlayer = true
  instance.onDialogueRealEnd = nil
  instance.spritefixture_properties = nil
  instance.sprite_info = nil
  instance.physical_properties = nil
  instance.update = nil -- update only does image speed for now, activate stuff is on early update
  instance.draw = nil -- is invisible
  instance.trans_draw = nil -- is invisible
end

NPC.functions = {
  load = function (self)
    if o.identified and o.identified.PlayaTest and o.identified.PlayaTest[1] then
      self.activator = o.identified.PlayaTest[1]
    end
    self.activated = true
  end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(typicalNpc, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
