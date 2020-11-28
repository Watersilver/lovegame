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
    "Sword",
    "Jump",
    "Missile",
    "Mark",
    "Recall",
    "Grip",
    "Bomb",
    "Run",
    "Magic dust",
    "All",
  }
  instance.question = "Choose a spell to toggle."
  instance.image_speed = 0.05
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

  handleHookReturn = function (self)
    if not self.hookReturn then
      self.dlgState = "waiting"
    elseif self.hookReturn == "ptTriggered" then
      self.dlgState = "asking"
    elseif self.hookReturn == "ssbWaiting" then
      self.dlgState = "choosing"
    elseif self.hookReturn == "ssbChose" then
      if self.choiceReturn.a == "All" then
        if session.save.hasSword then session.save.hasSword = nil
        else session.save.hasSword = "sword" end
        if session.save.hasJump then session.save.hasJump = nil
        else session.save.hasJump = "jump" end
        if session.save.hasMissile then session.save.hasMissile = nil
        else session.save.hasMissile = "missile" end
        if session.save.hasMark then session.save.hasMark = nil
        else session.save.hasMark = "mark" end
        if session.save.hasRecall then session.save.hasRecall = nil
        else session.save.hasRecall = "recall" end
        if session.save.hasGrip then session.save.hasGrip = nil
        else session.save.hasGrip = "grip" end
        if session.save.hasBomb then session.save.hasBomb = nil
        else session.save.hasBomb = "bomb" end
        if session.save.hasSpeed then session.save.hasSpeed = nil
        else session.save.hasSpeed = "speed" end
        if session.save.hasMystery then session.save.hasMystery = nil
        else session.save.hasMystery = "mystery" end
      elseif self.choiceReturn.a == "Sword" then
        if session.save.hasSword then session.save.hasSword = nil
        else session.save.hasSword = "sword" end
      elseif self.choiceReturn.a == "Jump" then
        if session.save.hasJump then session.save.hasJump = nil
        else session.save.hasJump = "jump" end
      elseif self.choiceReturn.a == "Missile" then
        if session.save.hasMissile then session.save.hasMissile = nil
        else session.save.hasMissile = "missile" end
      elseif self.choiceReturn.a == "Mark" then
        if session.save.hasMark then session.save.hasMark = nil
        else session.save.hasMark = "mark" end
      elseif self.choiceReturn.a == "Recall" then
        if session.save.hasRecall then session.save.hasRecall = nil
        else session.save.hasRecall = "recall" end
      elseif self.choiceReturn.a == "Grip" then
        if session.save.hasGrip then session.save.hasGrip = nil
        else session.save.hasGrip = "grip" end
      elseif self.choiceReturn.a == "Bomb" then
        if session.save.hasBomb then session.save.hasBomb = nil
        else session.save.hasBomb = "bomb" end
      elseif self.choiceReturn.a == "Run" then
        if session.save.hasSpeed then session.save.hasSpeed = nil
        else session.save.hasSpeed = "speed" end
      elseif self.choiceReturn.a == "Magic dust" then
        if session.save.hasMystery then session.save.hasMystery = nil
        else session.save.hasMystery = "mystery" end
      end
      asp.emptySpellSlots()
      if pl1 then pl1:readSave() end
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
