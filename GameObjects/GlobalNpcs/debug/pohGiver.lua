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
    "21",
    "20",
    "19",
    "18",
    "17",
    "16",
    "15",
    "14",
    "13",
    "12",
    "11",
    "10",
    "9",
    "8",
    "7",
    "6",
    "5",
    "4",
    "3",
    "2",
    "1",
    "0"
  }
  instance.question = "Choose Extra hearts."
  instance.image_speed = 0.05
  instance.sprite_info = im.spriteSettings.npcTest3Sprites
  instance.onHookReturnListeners.ssbChose = instance.ssbChose
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

  ssbChose = function (self)
    -- Choice is self.choiceReturn.a
    session.save.piecesOfHeart = math.min(tonumber(self.choiceReturn.a) * 4, GCON.maxPOHs)
    if pl1 then
      pl1:readSave()
      pl1.health = pl1.maxHealth
    end
    self.dlgState = "reacting"
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
