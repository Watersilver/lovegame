local im = require "image"
local p = require "GameObjects.prototype"
local inp = require "input"
local inv = require "inventory"
local u = require "utilities"
local cd = require "GameObjects.DialogueBubble.controlDefaults"
local npcP = require "GameObjects.npcPrototype"
local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local choiceCtrl = require "GameObjects.DialogueBubble.BasicChoiceControl"

local NPC = {}

function NPC.initialize(instance)
  instance.choicesDict = {
    yes = "Yes",
    no = "No"
  }
  instance.choices = {
    instance.choicesDict.yes,
    instance.choicesDict.no
  }
  instance.question = "Save game?"
  instance.image_speed = 0
  instance.sprite_info = im.spriteSettings.owlStatue
  instance.lightSource = {kind = "owlStatue"}

  instance.pushback = true
  instance.ballbreaker = true
  instance.unpushable = false
  instance.physical_properties.masks = {PLAYERJUMPATTACKCAT}
end

NPC.functions = {
  getDlg = function (self)
    -- return self.dlgState ~= "reacting" and self.question or "Good choice"
    if self.dlgState ~= "reacting" then
      return self.question
    else
      if self.choiceReturn.a == self.choicesDict.yes then
        return "Saved!"
      else
        return "..."
      end
    end
  end,

  getInterruptedDlg = function (self)
    return "..."
  end,

  handleHookReturn = function (self)
    self.image_index = 0
    if not self.hookReturn then
      self.dlgState = "waiting"
    elseif self.hookReturn == "ptTriggered" then
      self.image_index = 1
      self.dlgState = "asking"
    elseif self.hookReturn == "ssbWaiting" then
      self.image_index = 1
      self.dlgState = "choosing"
    elseif self.hookReturn == "ssbChose" then
      if self.choiceReturn.a == self.choicesDict.yes then
        self.image_index = 1
        session.saveGame()
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
