local im = require "image"
local p = require "GameObjects.prototype"
local inp = require "input"
local inv = require "inventory"
local asp = require "GameObjects.Helpers.add_spell"
local u = require "utilities"
local cd = require "GameObjects.DialogueBubble.controlDefaults"
local npcP = require "GameObjects.npcPrototype"
local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local choiceCtrl = require "GameObjects.DialogueBubble.BasicChoiceControl"

local NPC = {}

function NPC.initialize(instance)
  instance.choices = {
    "Armor lvl 0",
    "Armor lvl 1",
    "Armor lvl 2",
    "Armor lvl 3",
    "Athletics lvl 0",
    "Athletics lvl 1",
    "Athletics lvl 2",
    "Athletics lvl 3",
    "Magic lvl 0",
    "Magic lvl 1",
    "Magic lvl 2",
    "Magic lvl 3",
    "Swordsmanship lvl 0",
    "Swordsmanship lvl 1",
    "Swordsmanship lvl 2",
    "Swordsmanship lvl 3",
  }
  instance.question = "Choose a skill to learn."
  instance.image_speed = 0.05
  instance.sprite_info = im.spriteSettings.npcTest2Sprites
end

NPC.functions = {
  getDlg = function (self)
    -- return self.dlgState ~= "reacting" and self.question or "Good choice"
    if self.dlgState ~= "reacting" then
      return self.question
    else
      -- I can also do stuff when picking response
      return self.choiceReturn.a .. " it is, then!"
    end
  end,

  getInterruptedDlg = function (self)
    return "Whatever."
  end,

  getChoiceLevel = function (self)
    if self.choiceReturn.a:find("0") then return 0
    elseif self.choiceReturn.a:find("1") then return 1
    elseif self.choiceReturn.a:find("2") then return 2
    elseif self.choiceReturn.a:find("3") then return 3
    end
  end,
  handleHookReturn = function (self)
    if not self.hookReturn then
      self.dlgState = "waiting"
    elseif self.hookReturn == "ptTriggered" then
      self.dlgState = "asking"
    elseif self.hookReturn == "ssbWaiting" then
      self.dlgState = "choosing"
    elseif self.hookReturn == "ssbChose" then
      if self.choiceReturn.a:find("Armor lvl") then
        session.save.armorLvl = self:getChoiceLevel()
      elseif self.choiceReturn.a:find("Magic lvl") then
        session.save.magicLvl = self:getChoiceLevel()
      elseif self.choiceReturn.a:find("Athletics lvl") then
        session.save.athleticsLvl = self:getChoiceLevel()
      elseif self.choiceReturn.a:find("Swordsmanship lvl") then
        session.save.swordLvl = self:getChoiceLevel()
      end
      self.dlgState = "reacting"
    elseif self.hookReturn == "ssbDone" then
      -- Clean up
      cd.cleanSsb(self)
      self.dlgState = "waiting"
    elseif self.hookReturn == "ssbFar" then
      self.dlgState = "interrupted"
    end
  end,

  determineUpdateHook = function (self)
    if self.dlgState == "waiting" then
      -- self.blockInput = false
      self.indicatorCooldown = 0.5
      self.updateHook = cd.interactiveProximityTrigger
    elseif self.dlgState == "asking" then
      -- self.blockInput = true
      self.updateHook = cd.nearInteractiveChoiceBubble
    elseif self.dlgState == "interrupted" then
      cd.ssbInterrupted(self)
    elseif self.dlgState == "choosing" then
      self.updateHook = cd.choiceChecker
    elseif self.dlgState == "reacting" then
      self.updateHook = cd.ssbToSsspb
    end
  end,

  update = function (self, dt)
    dlgCtrl.functions.update(self, dt)
    self.image_index = (self.image_index + dt*60*self.image_speed)
    while self.image_index >= self.sprite.frames do
      self.image_index = self.image_index - self.sprite.frames
    end
  end,
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcP, instance) -- add parent functions and fields
  p.new(dlgCtrl, instance) -- add parent functions and fields
  p.new(choiceCtrl, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
