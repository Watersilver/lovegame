local u = require "utilities"
local ps = require "physics_settings"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local o = require "GameObjects.objects"
local game = require "game"
local im = require "image"
local ebh = require "enemy_behaviours"

local shdrs = require "Shaders.shaders"
local deathShader = shdrs.bossDeathShader

local WreckingBall = {}

function WreckingBall.initialize(instance)
  instance.goThroughEnemies = true
  instance.goThroughPlayer = true
  instance.grounded = true
  instance.flying = true
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.canLeaveRoom = true
  -- instance.shielded = true
  -- instance.shieldWall = true
  instance.attackDodger = true
  instance.sprite_info = im.spriteSettings.boss4
  instance.physical_properties.shape = ps.shapes.missile
end

WreckingBall.functions = {
  determineComponents = function (self)
    local ball = self.creator
    self.attackDmg = (ball.attackDmg - (ball.spikedup and 1 or 0)) * 0.9
    self.explosive = ball.explosive
    self.impact = ball.impact
    if self.impact and self.impact > 10 then
      self.impact = 10
    end
    self.blowUpForce = ball.blowUpForce
    if self.high then
      self.harmless = true
    else
      self.harmless = false
    end
  end,

  load = function (self)
    self.sprite = im.sprites["Bosses/boss4/chainLink"]
    self.x, self.y = self.targetx, self.targety
    self:determineComponents()
  end,

  enemyUpdate = function (self, dt)
    if not self.creator or not self.creator.exists then return o.removeFromWorld(self) end
    if self.creator.dying then
      self.harmless = true
      self.dying = true
      self.myShader = deathShader
      self.body:setLinearVelocity(0, 0)
      return
    end

    -- if self.targetx, self.targetx then
      self.body:setPosition(self.targetx, self.targety)
      self.x, self.y = self.targetx, self.targety
    -- else
    --   self.x, self.y = 0, 0
    -- end
    self:determineComponents()
  end,

  late_update = function (self)
  end,

  hitBySword = function (self, other, myF, otherF)
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  hitByBombsplosion = function (self, other, myF, otherF)
  end,

  hitByBullrush = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
  end,

  draw = function (self)

    -- Draw enemy the default way
    et.functions.draw(self)

    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end,
}

function WreckingBall:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(WreckingBall, instance, init) -- add own functions and fields
  return instance
end

return WreckingBall
