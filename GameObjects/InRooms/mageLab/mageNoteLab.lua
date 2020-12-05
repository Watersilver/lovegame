local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local trans = require "transitions"
local inp = require "input"
local ls = require "lightSources"
local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local cd = require "GameObjects.DialogueBubble.controlDefaults"
local quests = require "quests"

local floor = math.floor

local NPC = {}

function NPC.initialize(instance)
  instance.nossbTriangle = true
  instance.ssbStayOnScreen = true
  instance.content = "Finally I created the summoning spell. \z
  It will summon the courageous one from the other world. "..GCON.heroWorld..". \z
  My despair has forced me to resort to abduction but it is the only way. \z
  The outworlder must cast the Seal in the Shrine of Secrets lest the empire consume all. \z
  However one must have the power of the nine Mystical Spells to cast the Seal. \z
  Most are bound deep in the ancient dungeons of "..GCON.shidun..". One I have here. \z
  I will take the outworlder to the other spells. We must not fail."
end

NPC.functions = {
  load = function (self)
    dlgCtrl.functions.load(self);
    session.startQuest("mainQuest2");
  end,

  update = function (self, dt)
    dlgCtrl.functions.update(self, dt)
  end,

  handleHookReturn = function (self)
    if not self.hookReturn then
      self.dlgState = "waiting"
    elseif self.hookReturn == "ssbDone" then
      -- Clean up
      cd.cleanSsb(self)
      self.dlgState = "waiting"
      -- Make note and set save.
      session.startQuest("mainQuest3");
      session.startQuest("mysticalSpells1");
      session.save.readMageJournal1 = true
    elseif self.hookReturn == "ssbFar" then
      self.dlgState = "interrupted"
    elseif self.hookReturn == "ptTriggered" then
      self.dlgState = "talking"
    end
  end,
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(dlgCtrl, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
