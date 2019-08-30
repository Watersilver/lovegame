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
  if self.activator then
    if self.activator.body then self.activator.body:setType("static") end
    if self.activator.player then inp.disable_controller(self.activator.player) end
  end
end

local myText = {
  {{{cc,cc,cc,cc},"Hey there. I am the Spell Giver!"},-1, "left"},
  {{{cc,cc,cc,cc},"Wanna learn all spells?",{0.5*cc,cc*0.8,cc,cc},"\n(Choose 'Teach me' to unlock every equippable spell.",{cc,cc*0.2,cc*0.2,cc}," Warning: If you don't want to have the full game abilities spoiled, choose 'No'.",{0.5*cc,cc*0.8,cc,cc},")"},-1, "left"},
  {{{cc,cc,cc,cc},"Done! You now know: Sword, magic missile, grip, mark recall, jump and water walk(passive). You can open your inventory with space(default) and swap spell positions by pressing the corresponding buttons."},-1, "left"},
  {{{cc,cc,cc,cc},"Suit yourself."},-1, "left"}
}

local activateFuncs = {}
activateFuncs[1] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  self.next = 2
end
activateFuncs[2] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  dlg.simpleBinaryChoice.setUp("Teach me!", "No!")
  self.next = {3, 4}
end
activateFuncs[3] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  session.save.hasSword = "sword"
  session.save.hasJump = "jump"
  session.save.hasMissile = "missile"
  session.save.hasMark = "mark"
  session.save.hasRecall = "recall"
  session.save.hasGrip = "grip"
  session.save.walkOnWater = true
  if self.activator then self.activator:readSave() end
  self.next = "end"
end
activateFuncs[4] = function (self, dt, textIndex)
  typical_activate(self, dt, textIndex)
  self.next = "end"
end

function NPC.initialize(instance)
  instance.sprite_info = im.spriteSettings.npcTest3Sprites
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
      if self.activator then
        if self.activator.body then self.activator.body:setType("dynamic") end
        if self.activator.player then inp.enable_controller(self.activator.player) end
      end
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
