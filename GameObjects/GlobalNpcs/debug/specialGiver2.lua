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
    "Power",
    "Wisdom",
    "Courage",
    "Water Walk",
    "Light",
    "Customize",
    "Piece of Heart"
  }
  instance.question = "Choose Special."
  instance.image_speed = 0.05
  instance.sprite_info = im.spriteSettings.npcTest3Sprites
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
      if self.choiceReturn.a == "Power" then
        session.save.dinsPower = not session.save.dinsPower
      elseif self.choiceReturn.a == "Wisdom" then
        session.save.nayrusWisdom = not session.save.nayrusWisdom
      elseif self.choiceReturn.a == "Courage" then
        session.save.faroresCourage = not session.save.faroresCourage
      elseif self.choiceReturn.a == "Customize" then
        session.save.customMarkAvailable = not session.save.customMarkAvailable
        session.save.customMissileAvailable = not session.save.customMissileAvailable
        session.save.customSwordAvailable = not session.save.customSwordAvailable
        session.save.customTunicAvailable = not session.save.customTunicAvailable
      elseif self.choiceReturn.a == "Water Walk" then
        session.save.walkOnWater = not session.save.walkOnWater
      elseif self.choiceReturn.a == "Light" then
        session.save.playerGlowAvailable = not session.save.playerGlowAvailable
      elseif self.choiceReturn.a == "Piece of Heart" then
        local itemInfo = (require "GameObjects.GlobalNpcs.fanfareGottenItems.pieceOfHeart").itemInfo
        local o = require "GameObjects.objects"
        local itemGetPoseAndDlg = require "GameObjects.GlobalNpcs.itemGetPoseAndDlg"
        local pieceOfHeart = itemGetPoseAndDlg:new(itemInfo)
        o.addToWorld(pieceOfHeart)
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
