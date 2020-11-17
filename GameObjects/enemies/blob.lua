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

local function shock(self, player)
  if player and player.takeDamage then
    if self.image_index < 1 then
      self.shockSide = 1
    elseif self.image_index < 3 and self.image_index >= 2 then
      self.shockSide = 2
    else
      self.shockSide = love.math.random(2)
    end
    self.shockTimer = self.shockDuration
    self.attackShakeMagn = 5
    self.attackShakeDur = 1.5
    self.attackDmg = self.attackDmgShock
    self.altHurtSound = self.shockSound
    self.shocking = true
    self.sprite = im.sprites["Enemies/Blob/shock"]
    self.canBeBullrushed = false
    if self.transformed then
      self.harmless = false
      player:takeDamage(self)
      self.harmless = true
    else
      player:takeDamage(self)
    end
    self.canBeBullrushed = true
  end
end

local Blob = {}

function Blob.initialize(instance)
  instance.sprite_info = im.spriteSettings.blob
  instance.hp = 3
  instance.image_speed = 0.1
  instance.physical_properties.shape = ps.shapes.rect13x16
  instance.maxspeed = 13
  instance.attackDmgWalk = 2
  instance.attackDmgShock = 4
  instance.attackDmg = instance.attackDmgWalk
  instance.shockDuration = 5
  instance.shockSound = snd.load_sound({"Effects/Oracle_Link_Shock"})
  instance.walkSprite = "walk"
  instance.unpushable = false
end

local dlgMethods = {}
dlgMethods.getDlg = function (self)
  return u.chooseFromWeightTable{
    {weight = 1, value = "I'm a blob, And I have stuff to say"},
    {weight = 1, value = "You're not a blob. Heh. Or are you!"},
  }
end

dlgMethods.waitingHook = function (self, dt)
  if self.canTalk then
    cd.interactiveProximityTrigger(self, dt)
  end
end

dlgMethods.determineUpdateHook = function (self)
  if self.dlgState == "waiting" then
    -- self.blockInput = false
    self.indicatorCooldown = 0.5
    self.updateHook = dlgMethods.waitingHook
  elseif self.dlgState == "talking" then
    -- self.blockInput = true
    self.updateHook = cd.singleSimpleSelfPlayingBubble
  elseif self.dlgState == "interrupted" then
    cd.ssbInterrupted(self)
  end
end

Blob.functions = {
  delete = function (self)
    o.removeFromWorld(self.dlgControl)
  end,

  enemyLoad = function (self)
    self.shockTimer = 0
    self.dlgControl = dlgCtrl:new{
      height = self.sprite.height,
      x = self.x, y = self.y,
      xstart = self.x, ystart = self.y,
      canTalk = false,
      getDlg = dlgMethods.getDlg,
      determineUpdateHook = dlgMethods.determineUpdateHook
    }
    o.addToWorld(self.dlgControl)
  end,

  enemyUpdate = function (self, dt)
    self.dlgControl.x = self.x
    self.dlgControl.y = self.y
    if session.bounceRing then
      self.sprintThrough = false
    else
      self.sprintThrough = true
    end

    if self.shockTimer > 0 then
      -- I am shocking
      self.shockTimer = self.shockTimer - dt
      if self.shockSide == 2 then
        self.image_index = love.math.random(0, 1)
      else
        self.image_index = love.math.random(2, 3)
      end
      self.direction = nil
      if self.shockTimer <= 0 then
        self.attackShakeMagn = nil
        self.attackShakeDur = nil
        self.attackDmg = self.attackDmgWalk
        self.altHurtSound = nil
        self.shocking = nil
      end
    else
      self.sprite = im.sprites["Enemies/Blob/" .. self.walkSprite]
      -- I am walking
      local vx, vy = self.body:getLinearVelocity()
      self.speed = math.sqrt(vx*vx + vy*vy)
      -- Movement behaviour
      if self.behaviourTimer < 0 then
        self.direction = math.pi * 2 * love.math.random()
        self.behaviourTimer = love.math.random(2)
      end
      if self.invulnerable then
        self.direction = nil
      end
    end

    td.analogueWalk(self, dt)
  end,

  hitBySword = function (self, other, myF, otherF)
    -- Rubber ring protects you from shock
    if session.bounceRing then
      et.functions.hitBySword(self, other, myF, otherF)
    else
      shock(self, other.creator)
    end
  end,

  hitByBullrush = function (self, other, myF, otherF)
    if session.bounceRing then
      et.functions.hitByBullrush(self, other, myF, otherF)
    else
      shock(self, other)
    end
  end,

  hitByMdust = function (self, other, myF, otherF)
    other.create(self)
    self.walkSprite = "transwalk"
    self.transformed = true
    self.harmless = true
    self.dlgControl.canTalk = true
    self.unactivatable = nil
    self.hitByMdust = u.emptyFunc
  end,
}

local npcTest = require "GameObjects.npcTest"
local typicalNpc = require "GameObjects.GlobalNpcs.typicalNpc"

function Blob:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Blob, instance, init) -- add own functions and fields
  return instance
end

return Blob
