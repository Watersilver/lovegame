local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local gsh = require "gamera_shake"
local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local cd = require "GameObjects.DialogueBubble.controlDefaults"
local o = require "GameObjects.objects"

local s_info = {
  {'NPCs/BoolKnight/down1', 2, padding = 2, width = 15, height = 16},
  {'NPCs/BoolKnight/down2', 2, padding = 2, width = 15, height = 16},
}

local BoolKnight = {}

function BoolKnight.initialize(instance)
  instance.sprite_info = s_info
  instance.hp = 1
  instance.image_speed = 0.05
  instance.physical_properties.bodyType = "static"
  instance.physical_properties.shape = ps.shapes.plshape
  instance.harmless = true
  instance.ids[#instance.ids+1] = "boolKnight"
end

local dlgMethods = {}
dlgMethods.getDlg = function (self)
  local dlg
  local goRight = "Take the rightmost northern exit."
  local goLeft = "Take the leftmost northern exit."
  if self.anchor.liar then
    dlg = "I know everything."
    if self.anchor.rightWay then
      dlg = self.anchor.rightWay == 1 and goRight or goLeft
    end
  else
    dlg = "I don't know shit."
    if self.anchor.rightWay then
      dlg = self.anchor.rightWay == 1 and goLeft or goRight
    end
  end
  return dlg
end

dlgMethods.waitingHook = function (self, dt)
  cd.interactiveProximityTrigger(self, dt)
end

dlgMethods.determineUpdateHook = function (self)
  if self.dlgState == "waiting" then
    self.indicatorCooldown = 0.5
    self.updateHook = dlgMethods.waitingHook
  elseif self.dlgState == "talking" then
    self.updateHook = cd.ssb.auto.sound.func
  elseif self.dlgState == "interrupted" then
    cd.ssbInterrupted(self)
  end
end

BoolKnight.functions = {
  delete = function (self)
    o.removeFromWorld(self.dlgControl)
  end,

  die = function (self)
    o.removeFromWorld(self)
    local BoolKnightEscape = (require "GameObjects.InRooms.cursedForest.r08.boolKnightEscape")
    local runningKnight = BoolKnightEscape:new{
      x = self.x, y = self.y, xstart = self.x, ystart = self.y,
      layer = self.layer, liar = self.liar, sprite_info = self.sprite_info,
      parentSprite = self.sprite
    }
    o.addToWorld(runningKnight)
  end,

  enemyLoad = function (self)
    self.dlgControl = dlgCtrl:new{
      height = self.sprite.height,
      x = self.x, y = self.y,
      xstart = self.x, ystart = self.y,
      getDlg = self.getDlg or dlgMethods.getDlg,
      determineUpdateHook = dlgMethods.determineUpdateHook,
      anchor = self
    }
    o.addToWorld(self.dlgControl)
    if self.x > 200 then
      self.sprite = im.sprites["NPCs/BoolKnight/down2"]
    end
  end,

  enemyUpdate = function (self, dt)
    self.dlgControl.x = self.x
    self.dlgControl.y = self.y
  end,
}

function BoolKnight:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(BoolKnight, instance, init) -- add own functions and fields
  return instance
end

return BoolKnight
