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

local proj = require "GameObjects.enemies.projectile"

---@param pattern 'snipe' | 'shotgun' | 'spray' | 'random'
local function createProjectile(eye, dir, pattern)
  local startSpriteName = 'Enemies/Missiles/spinmissile'
  local angleIsDirection = false
  local imgsp = 0.25
  if pattern == 'snipe' then
    snd.play(glsounds.bossShotSnipe)
    startSpriteName = "Enemies/Missiles/directionalmissile"
    angleIsDirection = true
  elseif pattern == "shotgun" then
    snd.play(glsounds.bossShotShotgun)
    startSpriteName = "Enemies/Missiles/multimissile"
  elseif pattern == "spray" then
    snd.play(glsounds.bossShotSpray)
    startSpriteName = "Enemies/Missiles/spinmissile"
  elseif pattern == "random" then
    snd.play(glsounds.bossShotRandom)
    startSpriteName = "Enemies/Missiles/spinmissile2"
    imgsp = 0.5
  end
  o.addToWorld(proj:new{
    xstart = eye.x, ystart = eye.y,
    attackDmg = 2, layer = 15,
    direction = dir,
    doesntGoThroughSolids = true,
    notBreakableByMissile = true,
    ballbreaker = false,
    sprite_info = im.spriteSettings.missiles,
    image_speed = imgsp,
    startSpriteName = startSpriteName,
    angleIsDirection = angleIsDirection
  })
end

local function newAttackPattern(startingTimer)
  return {
    minIdle = 1,
    forceIdleTimer = startingTimer or 0,
    attacks = {
      snipe = {
        init = function (self, attackPattern, eye)
          if eye.otherEye.exists then
            self.times = love.math.random(1, 3)
          else
            self.times = love.math.random(2, 5)
          end
          self.frequency = 0.1 + love.math.random() * 0.5
          self.timer = 0
        end,
        update = function (self, attackPattern, eye, dt)
          self.timer = self.timer - dt
          if self.timer < 0 then
            self.timer = self.frequency
            self.times = self.times - 1

            local _, dir = u.cartesianToPolar(eye.head.target.x - eye.x, eye.head.target.y - eye.y)
            createProjectile(eye, dir, 'snipe')

            if self.times <= 0 then
              attackPattern.attack = nil
              return
            end
          end
        end
      },

      shotgun = {
        init = function (self, attackPattern, eye)
          if eye.otherEye.exists then
            self.times = love.math.random(1, 2)
          else
            self.times = love.math.random(1, 4)
          end
          self.frequency = 0.5 + love.math.random() * 0.5
          self.timer = 0
          self.pattern = love.math.random(0, 1)
        end,
        update = function (self, attackPattern, eye, dt)
          self.timer = self.timer - dt
          if self.timer < 0 then
            self.timer = self.frequency
            self.times = self.times - 1

            local piPieces = 7
            local step = math.pi / piPieces
            local dir = step
            local maxDir = dir * (piPieces - 1) + 0.01
            if self.pattern == 1 then
              dir = dir + step * 0.5
            end
            while dir < maxDir do
              createProjectile(eye, dir, 'shotgun')
              dir = dir + step
            end

            self.pattern = 1 - self.pattern

            if self.times <= 0 then
              attackPattern.attack = nil
              return
            end
          end
        end
      },

      spray = {
        init = function (self, attackPattern, eye)
          self.frequency = 0.19
          self.rate = 1
          if not eye.otherEye.exists then
            self.frequency = self.frequency * 0.5
            self.rate = 2
          end
          self.timer = 1 + love.math.random() * 2
          self.startingPhase = love.math.random() * math.pi
        end,
        update = function (self, attackPattern, eye, dt)
          local prevMod = self.timer % self.frequency
          self.timer = self.timer - dt

          if prevMod < self.timer % self.frequency then
            local dir = math.abs(math.sin(self.timer * self.rate + self.startingPhase)) * math.pi
            createProjectile(eye, dir, 'spray')
          end


          if self.timer < 0 then
            attackPattern.attack = nil
            return
          end
        end
      },

      random = {
        init = function (self, attackPattern, eye)
          self.frequency = 0.19
          self.rate = 1
          if not eye.otherEye.exists then
            self.frequency = self.frequency * 0.5
            self.rate = 2
          end
          self.timer = 1 + love.math.random() * 2
        end,
        update = function (self, attackPattern, eye, dt)
          local prevMod = self.timer % self.frequency
          self.timer = self.timer - dt

          if prevMod < self.timer % self.frequency then
            local dir = (math.pi / 7) * (1 + 5 * love.math.random())
            createProjectile(eye, dir, 'random')
          end


          if self.timer < 0 then
            attackPattern.attack = nil
            return
          end
        end
      }
    },
    update = function (self, eye, dt)
      if self.idleTimer then
        self.idleTimer = self.idleTimer - dt
        if self.idleTimer <= 0 then self.idleTimer = nil end
      else
        if (eye.eyelid_index == 0 or eye.eyeChanged) and not eye.head.invulnerable then
          if self.attack then
            self.attack:update(self, eye, dt)
          else
            self:selectAttack(eye, dt)
            self.idleTimer = self.forceIdleTimer or math.max(self.minIdle, 4 * love.math.random())
            self.forceIdleTimer = nil
          end
        else
          self.idleTimer = self.minIdle
        end
        if not eye.otherEye.exists and self.idleTimer then
          self.idleTimer = self.idleTimer * 0.5
        end
      end
    end,
    selectAttack = function (self, eye, dt)
      local attackIndex
      -- if eye.otherEye.exists then
      --   attackIndex = u.chooseKeyFromTable(attacks, 1)
      -- else
        attackIndex = u.chooseKeyFromTable(self.attacks)
      -- end
      self.attack = self.attacks[attackIndex]
      self.attack:init(self, eye)
    end
  }
end

local Boss2Eye = {}

function Boss2Eye.initialize(instance)
  instance.goThroughEnemies = true
  instance.grounded = true
  instance.levitating = true
  instance.layer = 8
  instance.sprite_info = im.spriteSettings.boss2
  instance.hp = 50
  instance.missileDamageMod = 2.5
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.side = 1
  instance.shielded = false
  -- instance.shieldWall = true
  instance.physical_properties.shape = ps.shapes.bosses.boss2.eye
  instance.spritefixture_properties = nil
  instance.image_index = 0
  instance.eyelidState = 4
  instance.drop = "noDrop"
  instance.shieldTimer = 0
  instance.fullyOpenTimer = 0
  instance.attackPattern = newAttackPattern()

  instance.hpPrev = instance.hp
end

Boss2Eye.functions = {
  lookTowards = function (self, angle)
    local angleChunk = 2 * math.pi / 8
    if not angle then
      self.image_index = 0
    elseif angle <= angleChunk * 0.5 and angle > -angleChunk * 0.5 then
      -- right
      self.image_index = 3
    elseif angle <= -angleChunk * 0.5 and angle > -angleChunk * 1.5 then
      -- right up
      self.image_index = 4
    elseif angle <= -angleChunk * 1.5 and angle > -angleChunk * 2.5 then
      -- up
      self.image_index = 5
    elseif angle <= -angleChunk * 2.5 and angle > -angleChunk * 3.5 then
      -- left up
      self.image_index = 6
    elseif angle <= -angleChunk * 3.5 or angle > angleChunk * 3.5 then
      -- left
      self.image_index = 7
    elseif angle <= angleChunk * 3.5 and angle > angleChunk * 2.5 then
      -- left down
      self.image_index = 8
    elseif angle <= angleChunk * 2.5 and angle > angleChunk * 1.5 then
      -- down
      self.image_index = 1
    elseif angle <= angleChunk * 1.5 and angle > angleChunk * 0.5 then
      -- right down
      self.image_index = 2
    end
  end,

  getRorL = function(self)
    return (self.side > 0) and 'l' or 'r'
  end,

  load = function (self)
    self.sprite = im.sprites["Bosses/boss2/eye_" .. self:getRorL()]
    self.eyelidSprite = im.sprites["Bosses/boss2/eyelid_" .. self:getRorL()]
  end,

  enemyUpdate = function (self, dt)
    self.eyelid_index = u.clamp(0, self.shielded and 4 or (self.pain and 2 or self.eyelidState), 4)

    if not self.head.enabled then return end

    -- Rage sprite change
    if not self.eyeChanged then
      if not self.otherEye.exists then
        self.eyeChanged = true
        self.bulgingCounter = 0
        self.sprite = im.sprites["Bosses/boss2/swoleneye_" .. self:getRorL()]
      else
        if pl1 then
          local r, th = u.cartesianToPolar(pl1.x - self.x, pl1.y - self.y)
          self:lookTowards(th)
          if self.image_index == 1 and r < 20 then
            self.image_index = 0
          end
        end
      end
    else
      self.bulgingCounter = (self.bulgingCounter + dt * 5) % 6

      self.image_index = math.floor(self.bulgingCounter)

      if self.image_index == 5 then self.image_index = 1 end
      if self.image_index >= 3 then self.image_index = 2 end
    end

    -- Attack behaviour
    self.attackPattern:update(self, dt)

    -- Recover from pain
    self.shieldTimer = self.shieldTimer - dt
    if self.shieldTimer < 0 then
      self.shieldTimer = 0
      self.fullyOpenTimer = self.fullyOpenTimer - dt
      self.shielded = false
      if self.pain then self.pain = 1 end
    end

    if self.fullyOpenTimer < 0 then
      self.fullyOpenTimer = 0
      self.pain = nil
    end
  end,

  late_update = function (self)
    local head = self.head
    if not head then return o.removeFromWorld(self) end

    -- offset from middle of head
    local xoffset, yoffset
    xoffset = self.side * 23
    yoffset = 4
    xoffset, yoffset = u.rotate2d(xoffset, yoffset, head.angle)

    local x, y = xoffset + head.x, yoffset + head.y
    self.body:setPosition(x, y)
    self.x, self.y = x, y
    self.angle = head.angle
  end,

  hitBySword = function (self, other, myF, otherF)
    if not self.head.enabled then return end

    ebh.damagedByHit(self, other, myF, otherF)
    self:gotHurt()
  end,

  hitByMissile = function (self, other, myF, otherF)
    if not self.head.enabled then return end

    ebh.damagedByHit(self, other, myF, otherF)
    self:gotHurt()
  end,

  hitByThrown = function (self, other, myF, otherF)
  end,

  hitByBombsplosion = function (self, other, myF, otherF)
  end,

  hitByBullrush = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
  end,

  destroy = function (self)
    -- What happens when I get destroyed.
    self.head:takeDamage()
    self.head.sightLoss = self.head.sightLoss + 1
    if self.otherEye.exists and self.otherEye.hp > self.hpPrev then
      self.otherEye.hp = 75 - math.floor(self.otherEye.hp / 2)
    end
  end,

  draw = function (self)

    if self.invisible then return end
    if not self.head then return end

    local xtotal, ytotal = self.head.x, self.head.y

    if self.spritebody then
      if self.spritejoint and (not self.spritejoint:isDestroyed()) then self.spritejoint:destroy() end
      self.spritebody:setPosition(xtotal, ytotal)
      self.spritejoint = love.physics.newWeldJoint(self.spritebody, self.body, 0,0)
    end

    local sprite = self.sprite
    local frames = self.sprite.frames
    while self.image_index >= frames do
      self.image_index = self.image_index - frames
    end
    local frame = sprite[math.floor(self.image_index)]

    if self.drawIntPos then
      xtotal, ytotal = u.round(xtotal), u.round(ytotal)
    end

    local worldShader = love.graphics.getShader()
    love.graphics.setShader(self.myShader)

    -- Draw the eyes
    love.graphics.draw(
    sprite.img, frame, xtotal, ytotal, self.angle,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)

    -- Draw the eyelids
    --  - (self.head or {mouth_gape_state = 0}).mouth_gape_state * 8
    local eyelidFrame = self.eyelidSprite[self.eyelid_index]
    love.graphics.draw(
    self.eyelidSprite.img, eyelidFrame, xtotal, ytotal, self.angle,
    self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
    sprite.cx, sprite.cy)

    love.graphics.setShader(worldShader)
  end,

  gotHurt = function (self)
    if not self.otherEye.exists then return end
    self.shielded = true
    self.shieldTimer = 1
    self.fullyOpenTimer = 0.5
    self.pain = 2
  end,

  refreshComponents = function (self)
    self.bombGoesThrough = true
    self.goThroughPlayer = not self.head.enabled
    self.pushback = self.head.enabled
    self.harmless = not self.head.enabled
    self.ballbreaker = self.head.enabled
    self.attackDodger = not self.head.enabled
  end,
}

function Boss2Eye:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss2Eye, instance, init) -- add own functions and fields
  return instance
end

return Boss2Eye
