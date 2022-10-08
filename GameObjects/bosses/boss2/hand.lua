local u = require "utilities"
local ps = require "physics_settings"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local o = require "GameObjects.objects"
local game = require "game"
local im = require "image"
local gsh = require "gamera_shake"
local ebh = require "enemy_behaviours"

local b1fo = require "GameObjects.bosses.boss2.boss2fallorb"

local leftmost = 34.24
local rightmost = 365.76

local Boss2Hand = {}

function Boss2Hand.initialize(instance)
  instance.goThroughEnemies = true
  instance.grounded = true
  instance.levitating = true
  instance.layer = 11
  instance.sprite_info = im.spriteSettings.boss2
  instance.hp = 11
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  -- instance.shielded = true
  -- instance.shieldWall = true
  instance.physical_properties.shape = ps.shapes.bosses.boss2.hand
  instance.spritefixture_properties = nil
  instance.image_index = 0
  instance.drop = "noDrop"
  instance.goThroughPlayer = true
  local moreSounds = snd.load_sounds({
    handTouchGround = {"Effects/Oracle_Boss_BigBoom"},
    handTouchGroundGently = {"Effects/smallBoom"}
  })
  instance.sounds.handTouchGround = moreSounds.handTouchGround
  instance.sounds.handTouchGroundGently = moreSounds.handTouchGroundGently
end

Boss2Hand.functions = {
  load = function (self)
    self.sprite = im.sprites["Bosses/boss2/HandFront"]

    local HandBack = require "GameObjects.bosses.boss2.handBack"
    self.handBack = HandBack:new{
      x_scale = self.x_scale, parent = self
    }
    o.addToWorld(self.handBack)

    -- minHeight gets fed to me by head
    self.targetX = nil -- 0 - 1
  end,

  enemyUpdate = function (self, dt)
    if not self.head.enabled then return end

    if self.slamming then
      self.slamming = self.slamming + dt
      -- Slam will last for pi = time * self.slamTimeFactor => time = pi / self.slamTimeFactor secs
      -- determine xSlam from that
      local xSlamFactor = self.slamming / (math.pi / self.slamTimeFactor)
      if xSlamFactor > 1 then xSlamFactor = 1 end
      self.xSlam = self.xSlamStart + xSlamFactor * (self.targetX - self.xSlamStart)
      self.ySlam = self.minHeight - math.sin(self.slamming * self.slamTimeFactor) * self.sprite.height * 1.8
      if self.ySlam > self.minHeight then
        self.slamming = nil
        self.ySlam = nil
        self.xSlam = nil
        -- Maybe nilify only if I am close enough
        self.targetX = nil
        self.slammed = true
      end
    end

    local x = self.body:getPosition()
    local min, max = self:getMovementRange()
    x = self.xSlam and (min + self.xSlam * (max - min)) or x
    if self.dyingY then self.dyingY = self.dyingY - dt * 44 end
    local y
    if self.ySlam and self.dyingY then
      y = math.min(self.dyingY, self.ySlam)
    elseif self.ySlam then
      y = self.ySlam
    elseif self.dyingY then
      y = self.dyingY
    end
    y = y or self.minHeight
    self.body:setPosition(x, y)
    self.y = y

    -- Dying hand shake
    if self.dyingY then
      if not self.shakeX then
        self.shakeX, self.shakeY = 0
        self.shakeTime = 0
        self.invulnerable = 100
      end

      if self.dyingY < self.minHeight - self.sprite.height * 1.8 then
        self.dyingY = self.minHeight - self.sprite.height * 1.8
        if not self.lastShakes then self.lastShakes = 0.3 end
        self.lastShakes = self.lastShakes - dt
        if self.lastShakes < 0 then
          if self.invulnerable then self.invulnerable = 0 end
        end
      end
      self.shakeTime = self.shakeTime - dt
      if self.shakeTime < 0 then
        self.shakeTime = 0.05
        -- self.shakeX = love.math.random() - 0.5
        -- self.shakeY = love.math.random() - 0.5
        -- self.shakeX, self.shakeY = u.normalize2d(self.shakeX, self.shakeY)
        self.shakeX, self.shakeY = u.polarToCartesian(love.math.random() * 2, math.pi * 2 * love.math.random())
      end
      self.x, self.y = self.x + self.shakeX, self.y + self.shakeY
    end

    if self.slammed then
      if pl1 and pl1.exists and pl1.zo == 0 then
        pl1.zvel = 66
      end
      snd.play(self.sounds.handTouchGround)

      -- Create orb b1fo
      if love.math.random() < 0.3 then
        o.addToWorld(b1fo:new{
          breakOnLanding = true,
          xstart = love.math.random(24, 376),
          ystart = love.math.random(104, 216)
        })
        gsh.newShake(mainCamera, "displacement")
      else
      gsh.newShake(mainCamera, "displacement", 0.5)
      end
    end
    self.slammed = false
  end,

  hitBySword = function (self, other, myF, otherF)
    -- if not self.head.enabled or self.slamming then return end
    if not self.head.enabled then return end

    if self.head.blind then
      ebh.damagedByHit(self, other, myF, otherF)
    else
      self:slam(true)
    end
  end,

  hitByMissile = function (self, other, myF, otherF)
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  hitByBombsplosion = function (self, other, myF, otherF)
    if not self.head.enabled then return end

    if self.head.blind then
      ebh.damagedByHit(self, other, myF, otherF)
    else
      self:slam(true)
    end
  end,

  hitByBullrush = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
  end,

  destroy = function (self)
    -- What happens when I get destroyed.
    if self.otherHand.exists and self.otherHand.hp > 1 then
      self.otherHand.hp = 22 - math.floor(self.otherHand.hp / 2)
    end
    self.head:takeDamage()
  end,

  die = function (self)
    if not self.dyingY then
      self.dyingY = self.ySlam or self.minHeight
      self.head.handsLoss = self.head.handsLoss + 1
    end

    if self.dyingY <= self.minHeight - self.sprite.height * 1.8 then
      self.handBack.image_index = 1
      ebh.die(self)
    end
  end,

  -- draw = function (self)
  --
  --   -- Draw enemy the default way
  --   et.functions.draw(self)
  --
  --   -- Draw extra stuff like eyes and hands.
  --
  --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end,

  getMovementRange = function (self)
    local min, max = leftmost, rightmost
    if self.otherHand.exists then
      if self.x_scale == -1 then
        -- am left hand
        min = self.otherHand.x + self.sprite.width * 3
      else
        -- am right hand
        max = self.otherHand.x - self.sprite.width * 3
      end
    else
      if self.x_scale == -1 then
        -- am left hand
        min = leftmost + self.sprite.width * 3
      else
        -- am right hand
        max = rightmost - self.sprite.width * 3
      end
    end
    return min, max
  end,

  slam = function (self, randomizeX)
    if not self.slamming then
      self.slamTimeFactor = 7
      self.slamming = 0
      self.xSlam = 0
      self.ySlam = 0
      local min, max = self:getMovementRange()
      self.xSlamStart = (self.x - min) / (max - min)
      if randomizeX then self.targetX = love.math.random()
      elseif not self.targetX then self.targetX = self.xSlamStart end

      if not self.otherHand.exists then
        self.targetX = u.clamp(self.xSlamStart -.1, self.targetX, self.xSlamStart + .1)
      end
    end
  end,

  refreshComponents = function (self)
    self.bombGoesThrough = true
    self.pushback = self.head.enabled and self.head.blind
    self.harmless = not self.head.enabled
    self.ballbreaker = self.head.enabled
    self.attackDodger = not self.head.enabled
  end,
}

function Boss2Hand:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss2Hand, instance, init) -- add own functions and fields
  return instance
end

return Boss2Hand
