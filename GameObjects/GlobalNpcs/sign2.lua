local im = require "image"
local p = require "GameObjects.prototype"
local o = require "GameObjects.objects"
local inp = require "input"
local inv = require "inventory"
local u = require "utilities"
local cd = require "GameObjects.DialogueBubble.controlDefaults"
local npcP = require "GameObjects.npcPrototype"
local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local dc = require "GameObjects.Helpers.determine_colliders"
local drops = require "GameObjects.drops.drops"
local expl = require "GameObjects.explode"
local ps = require "physics_settings"

local function throw_collision(self)
  expl.commonExplosion(self, im.spriteSettings.woodDestruction)
  drops.normal(self.x, self.y)
end

local NPC = {}

function NPC.initialize(instance)
  instance.image_speed = 0
  instance.sprite_info = im.spriteSettings.sign
  instance.spritefixture_properties = nil
  instance.yProxOffset = 8
  instance.closenessThresh = 8
  instance.throw_collision = throw_collision
  instance.layer = 15
  instance.physical_properties = {
    tile = {"u", "d", "l", "r"},
    edgetable = ps.shapes.edgeRect1x1
  }
  instance.forceFacing = "up"

  instance.pushback = not session.save.dinsPower
  instance.liftable = true
  instance.ballbreaker = true
  instance.unpushable = false
  instance.physical_properties.masks = {PLAYERJUMPATTACKCAT}
end

NPC.functions = {
  getDlg = function (self)
    return "I'm a new sign"
  end,

  getInterruptedDlg = function (self)
    return "..."
  end,

  handleHookReturn = function (self)
    if not self.hookReturn then
      self.dlgState = "waiting"
    elseif self.hookReturn == "ptTriggered" then
      self.dlgState = "talking"
    elseif self.hookReturn == "ssbDone" then
      -- Clean up
      cd.cleanSsb(self)
      self.dlgState = "waiting"
    elseif self.hookReturn == "ssbFar" or self.hookReturn == "ssbLookedAway" then
      self.dlgState = "interrupted"
    end
  end,

  determineUpdateHook = function (self)
    if self.dlgState == "waiting" then
      self.indicatorCooldown = 0.5
      self.updateHook = cd.interactiveProximityTrigger
    elseif self.dlgState == "talking" then
      self.updateHook = cd.nearInteractiveBubble
    elseif self.dlgState == "interrupted" then
      cd.ssbInterrupted(self)
    end
  end,

  beginContact = function(self, a, b, coll, aob, bob)

    -- Find which fixture belongs to whom
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)
    if (other.immasword and session.save.dinsPower) or other.immabombsplosion then
      self:throw_collision()
      o.removeFromWorld(self)
      self.beginContact = nil
    end
  end
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(dlgCtrl, instance) -- add parent functions and fields
  p.new(npcP, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
