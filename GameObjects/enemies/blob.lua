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

local cc = COLORCONST

-- Write the text
local myText = {
  {
    {{{cc,cc,cc,cc},"I'm a blob"},-1, "left"},
    {{{cc,cc,cc,cc},"And I have stuff to say"},-1, "left"},
  },
  {
    {{{cc,cc,cc,cc},"You're not a blob"},-1, "left"},
    {{{cc,cc,cc,cc},"Heh"},-1, "left"},
    {{{cc,cc,cc,cc},"Or are you!"},-1, "left"},
  },
}

-- do the funcs
local activateFuncs = {
  {
    function (self, dt, textIndex)
      self.typical_activate(self, dt, textIndex)
      self.next = 2
    end,
    function (self, dt, textIndex)
      self.typical_activate(self, dt, textIndex)
      self.next = "end"
    end,
  },
  {
    function (self, dt, textIndex)
      self.typical_activate(self, dt, textIndex)
      self.next = 2
    end,
    function (self, dt, textIndex)
      self.typical_activate(self, dt, textIndex)
      self.next = 3
    end,
    function (self, dt, textIndex)
      self.typical_activate(self, dt, textIndex)
      self.next = "end"
    end,
  },
}

local function randomizeDialogue(self)
  local randomIndex = love.math.random(1, 2)
  self.myText = myText[randomIndex]
  self.activateFuncs = activateFuncs[randomIndex]
end

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
  instance.unactivatable = true
  instance.pauseWhenTalkedTo = true

  randomizeDialogue(instance)
end

Blob.functions = {

  enemyLoad = function (self)
    self.shockTimer = 0
  end,

  enemyUpdate = function (self, dt)
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
    self.unactivatable = nil
    self.hitByMdust = u.emptyFunc
  end,

  onDialogueRealEnd = function (self)
    randomizeDialogue(self)
  end,
}

local npcTest = require "GameObjects.npcTest"
local typicalNpc = require "GameObjects.GlobalNpcs.typicalNpc"

function Blob:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(npcTest, instance, init) -- add parent functions and fields
  p.new(typicalNpc, instance, init) -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Blob, instance, init) -- add own functions and fields
  return instance
end

return Blob
