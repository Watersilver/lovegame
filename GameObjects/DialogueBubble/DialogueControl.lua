local inp = require "input"
local p = require "GameObjects.prototype"
local cd = require "GameObjects.DialogueBubble.controlDefaults"

-- Rename to talky or something
local NPC = {}

local defaultCont = "Once your faith, sir, persuades you to believe what your intelligence declares to be absurd, beware lest you likewise sacrifice your reason in the conduct of your life. In days gone by, there were people who said to us: \"You believe in incomprehensible, contradictory and impossible things because we have commanded you to; now then, commit unjust acts because we likewise order you to do so.\" Nothing could be more convincing. Certainly anyone who has the power to make you believe absurdities has the power to make you commit injustices. If you do not use the intelligence with which God endowed your mind to resist believing impossibilities, you will not be able to use the sense of injustice which God planted in your heart to resist a command to do evil. Once a single faculty of your soul has been tyrannized, all the other faculties will submit to the same fate. This has been the cause of all the religious crimes that have flooded the earth."
local defaultChoices = {"Yes", "No"}
function NPC.initialize(instance)
  instance.content = defaultCont
  -- instance.content = "Welcome to Reflecting Day! The one day a month we're free to drop the punchline shield and just be earnest and honest with you. Free to wax philosophical about the state of the hotdog (strong), and occasionally dive off into tangents (long and weird) that confuse and alienate our readers (sexy; you). I've got one prepared about how the Internet should have never moved on from the GIF stage, and the ability to see and hear people in real time is directly responsible for the downfall of western civilization. But there's no time for that today! Today we have to be all business, because we have a lot of business."
end
local defaultInterrupted = "See ya!"
-- 7, 17
NPC.functions = {
  getInterruptedDlg = function (self)
    return defaultInterrupted
  end,

  getDlg = function (self)
    return self.content
  end,

  getChoices = function (self)
    return self.choices
  end,

  handleHookReturn = function (self)
    if not self.hookReturn then
      self.dlgState = "waiting"
    elseif self.hookReturn == "ssbDone" then
      -- Clean up
      cd.cleanSsb(self)
      self.dlgState = "waiting"
    elseif self.hookReturn == "ssbFar" then
      self.dlgState = "interrupted"
    elseif self.hookReturn == "ptTriggered" then
      self.dlgState = "talking"
    end
  end,

  determineUpdateHook = function (self)
    if self.dlgState == "waiting" then
      -- self.blockInput = false
      self.indicatorCooldown = 0.5
      self.updateHook = cd.interactiveProximityTrigger
    elseif self.dlgState == "talking" then
      -- self.blockInput = true
      self.updateHook = cd.nearInteractiveBubble
    elseif self.dlgState == "interrupted" then
      cd.ssbInterrupted(self)
    end
  end,

  load = function (self)
    if not self.height and self.sprite then
      self.height = self.sprite.height
    end
  end,

  early_update = function (self, dt)
    if not (pl1 and pl1.exists) then return end
    if self.blockInput then
      for keyname, _ in pairs(inp.current[pl1.player]) do
        inp.current[pl1.player][keyname] = 0
        inp.previous[pl1.player][keyname] = 0
      end
    end
  end,

  update = function (self, dt)
    if self.updateHook then
      self:updateHook(dt)
    else
      self:handleHookReturn()
      self:determineUpdateHook()
    end
  end,
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
