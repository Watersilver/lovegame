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
end

Blob.functions = {

  enemyLoad = function (self)
    self.shockTimer = 0
  end,

  enemyUpdate = function (self, dt)
    -- Can't touch if not rubber
    if session.bounceRing then
      self.canBeBullrushed = true
    else
      self.canBeBullrushed = false
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
        self.sprite = im.sprites["Enemies/Blob/walk"]
      end
    else
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
      if other.creator and other.creator.takeDamage then
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
        other.creator:takeDamage(self)
      end
    end
  end,
}

function Blob:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Blob, instance, init) -- add own functions and fields
  return instance
end

return Blob
