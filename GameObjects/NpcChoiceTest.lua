local p = require "GameObjects.prototype"
local DlgControl = require "GameObjects.DialogueBubble.DialogueControl"
local cd = require "GameObjects.DialogueBubble.controlDefaults"

local NPC = {}

function NPC.initialize(instance)
  instance.choicesDict = {
    c1 = "choice 1",
    c2 = "choice 2",
    c3 = "choice 33"
  }
  instance.choices = {
    instance.choicesDict.c1,
    instance.choicesDict.c2,
    instance.choicesDict.c3
  }
  instance.question = "Pick one"
end
-- nearInteractiveChoiceBubble
NPC.functions = {
  getDlg = function (self)
    -- return self.dlgState ~= "reacting" and self.question or "Good choice"
    if self.dlgState ~= "reacting" then
      return self.question
    else
      return self.choiceReturn.a .. "? Good choice!"
    end
  end,

  handleHookReturn = function (self)
    if not self.hookReturn then
      self.dlgState = "waiting"
    elseif self.hookReturn == "ssbDone" then
      -- Clean up
      cd.cleanSsb(self)
      self.dlgState = "waiting"
    elseif self.hookReturn == "ssbChose" then
      self.dlgState = "reacting"
    elseif self.hookReturn == "ssbFar" then
      self.dlgState = "interrupted"
    elseif self.hookReturn == "ptTriggered" then
      self.dlgState = "asking"
    elseif self.hookReturn == "ssbWaiting" then
      self.dlgState = "choosing"
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
      self.updateHook = cd.ssbToNib
    end
  end,
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(DlgControl, instance, init) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
