local p = require "GameObjects.prototype"
local u = require "utilities"
local cd = require "GameObjects.DialogueBubble.controlDefaults"
local npcP = require "GameObjects.npcPrototype"
local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local snd = require "sound"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local game = require "game"
local o = require "GameObjects.objects"

local truePainDlgTable = {
  {weight = 1, value = "AIEEEEE!!!"},
  {weight = 1, value = "OWEEE!!!"},
  {weight = 1, value = "YIKES!!!"},
}

local liesPainDlgTable = {
  {weight = 1, value = "Feels great!"},
  {weight = 1, value = "Thank you!"},
  {weight = 1, value = "I love it."},
}

local NPC = {}

function NPC.initialize(instance)
  instance.image_speed = 0.15
  instance.zo = 0
  instance.zvel = 0
  instance.gravity = 350
  instance.startMovingTimer = 1
  instance.physical_properties = nil

  local speed = 70
  instance.xvel, instance.yvel = u.polarToCartesian(speed, 2 * math.pi * love.math.random())
end

NPC.functions = {
  getDlg = function (self)
    if self.liar then
      return u.chooseFromWeightTable(liesPainDlgTable)
    else
      return u.chooseFromWeightTable(truePainDlgTable)
    end
  end,

  handleHookReturn = function (self)
    if not self.hookReturn then
      self.dlgState = "waiting"
    elseif self.hookReturn == "ssbDone" then
      -- Clean up
      cd.cleanSsb(self)
      self.dlgState = "finished"
    end
  end,

  determineUpdateHook = function (self)
    if self.dlgState == "waiting" then
      self.updateHook = cd.ssb.auto.sound.func
    elseif self.dlgState == "finished" then
      self.hookReturn = "end"
    end
  end,

  load = function (self)
    dlgCtrl.functions.load(self)
    self.sprite = self.parentSprite
  end,

  update = function (self, dt)
    dlgCtrl.functions.update(self, dt)

    -- Animate
    self.image_index = (self.image_index + dt*60*self.image_speed)
    while self.image_index >= self.sprite.frames do
      self.image_index = self.image_index - self.sprite.frames
    end

    -- Jump repeatedly
    self.landed = false
    if self.zvel == 0 and self.zo == 0 then
      self.zvel = 111
      self.landed = true

      if mainCamera then
        if not u.isOutsideGamera(self, mainCamera) then
          snd.play(glsounds.enemyJump)
        end
      else
        snd.play(glsounds.enemyJump)
      end
    end

    -- Move
    self.startMovingTimer = self.startMovingTimer - dt
    if self.startMovingTimer < 0 and (self.landed or self.moving) then
      self.moving = true
      self.startMovingTimer = 0
      self.x, self.y = self.x + self.xvel * dt, self.y + self.yvel * dt
    end

    -- Handle z axis
    td.zAxis(self, dt)
    sh.handleShadow(self)

    if u.isOutsideRoom(self, game.room) then
      o.removeFromWorld(self)
    end
  end,
}

function NPC:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcP, instance) -- add parent functions and fields
  p.new(dlgCtrl, instance) -- add parent functions and fields
  p.new(NPC, instance, init) -- add own functions and fields
  return instance
end

return NPC
