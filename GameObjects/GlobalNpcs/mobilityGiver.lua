local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local game = require "game"
local inp = require "input"
local dlg = require "dialogue"
local npcTest = require "GameObjects.NpcTest"


local floor = math.floor

local NPC = {}

local cc = COLORCONST

local function typical_activate(self, dt, textIndex)
  dlg.simpleWallOfText.setUp(
    self.myText[textIndex],
    self.y,
    self.onDialogueEnd
  )
  dlg.enable = true
  self.activator.body:setType("static")
  inp.disable_controller(self.activator.player)
end

local myText = {
  {{{cc,cc,cc,cc},"You're awfully sluggish. And your shoes look quite slippery..."},-1, "left"},
  {{{cc,cc,cc,cc},"I can make your shoes a bit less slippery and improve your mobility. Do you want me to?"},-1, "left"},
  {{{cc,cc,cc,cc},"Done!"},-1, "left"},
  {{{cc,cc,cc,cc},"All right then..."},-1, "left"}
}

local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  self.next = 2
end
activateFuncs[2] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  dlg.simpleBinaryChoice.setUp("Sure.", "Nah.")
  self.next = {3, 4}
end
activateFuncs[3] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  session.save.playerMobility = 600
  session.save.playerBrakes = 9
  self.activator:readSave()
  self.next = "end"
end
activateFuncs[4] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  self.next = "end"
end

function NPC.initialize(instance)
  instance.sprite_info = im.spriteSettings.npcTest2Sprites
  instance.counter = 1
  instance.myText = myText
  instance.onDialogueEnd = function()
    if type(instance.next) == "table" then
      instance.counter = instance.next[dlg.cursor+1] -- cursor starts from 0, arrays start from 1, so add 1
    else
      instance.counter = instance.next
    end
    if instance.counter == "end" then
      instance.active = false
    else
      instance.activated = true
      dlg.enabled = true
    end
  end
end

NPC.functions = {
  activate = function (self, dt)
    if self.activated then
      activateFuncs[self.counter](self, dt, self.counter)
    elseif self.active then
    else
      self.counter = 1
      self.activator.body:setType("dynamic")
      inp.enable_controller(self.activator.player)
    end
  end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
