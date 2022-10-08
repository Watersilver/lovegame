local u = require "utilities"
local ps = require "physics_settings"
local im = require "image"
local shdrs = require "Shaders.shaders"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local o = require "GameObjects.objects"
local sm = require "state_machine"
local game = require "game"
local expl = require "GameObjects.explode"
local gsh = require "gamera_shake"

local hitShader = shdrs.enemyHitShader
local deathShader = shdrs.bossDeathShader

-- At this y the hand perfectly grips the ground
local handMinHeight = 98.75
local defaultHeadHeight = 65

-- Does initial hands appearance
local function initRaiseHand(instance, hand)
  local y = 107 - 40 * math.sin(instance.stateTimer * 2)
  local x = hand.body:getPosition()
  hand.body:setPosition(x, y)
  if hand.layer < 14 and instance.stateTimer > 1 then
    o.change_layer(hand, 14)
  end
  if y > handMinHeight and hand.layer == 14 then
    y = handMinHeight
    hand.startGrab = true
    snd.play(instance.sounds.handTouchGround)
    gsh.newShake(mainCamera, "displacement")
    instance.stateTimer = 0
    game.room.music_info = "jabbajabba"
    snd.bgmV2.getMusicAndload()
  end
end

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "preCutscene")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  preCutscene = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if not pl1 or not pl1.exists then return end
      -- if pl1.y < 162 then
      if pl1.y < 146 then
        instance.state:change_state(instance, dt, "startCutscene")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  startCutscene = {
    run_state = function(instance, dt)
      if pl1 and pl1.exists then
        if pl1.zo == 0 then
          pl1.sprite = im.sprites["Witch/still_up"]
          pl1.x_scale = 1
        end
      end
      instance.prevStateTimer = instance.stateTimer
      instance.stateTimer = instance.stateTimer + dt
      if (instance.prevStateTimer < 3 and instance.stateTimer > 3) then
        snd.play(instance.sounds.crumble)
        gsh.newShake(mainCamera, "displacement")
      end
    end,
    start_state = function(instance, dt)
      if pl1 and pl1.exists then
        local xsc = pl1.x_scale
        pl1.animation_state:change_state(pl1, dt, "cutscene")
        pl1.body:setLinearVelocity(0, 0)
        pl1.x_scale = xsc
      end
      instance.stateTimer = 0
      instance.prevStateTimer = 0
      instance.stateDuration = 5
      snd.play(instance.sounds.crumble)
      gsh.newShake(mainCamera, "displacement")
    end,
    check_state = function(instance, dt)
      if instance.stateTimer > instance.stateDuration then
        instance.state:change_state(instance, dt, "rise")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  rise = {
    run_state = function(instance, dt)
      local rh = instance.rightHand
      local lh = instance.leftHand
      if not rh.startGrab then
        initRaiseHand(instance, rh)
      elseif not lh.startGrab then
        initRaiseHand(instance, lh)
      else
        if instance.step == 0 then
          instance.step = 1
          instance.body:setLinearVelocity(0, -10)
        elseif instance.step == 1 then
          if instance.y < defaultHeadHeight then
            instance.body:setLinearVelocity(0, 0)
            local x = instance.body:getPosition()
            instance.body:setPosition(x, defaultHeadHeight)
            instance.step = 2
            instance.stateTimer = 0
            instance.y = defaultHeadHeight
          end

          local strain = 20 * instance.stateTimer % 2
          strain = math.floor(strain)
          if strain == 0 then instance.y = instance.y + 1
          else instance.y = instance.y - 1 end
        elseif instance.step == 2 then
          -- if instance.stateTimer > 0.5 then
          if instance.stateTimer > 1.75 then
            instance.step = 3
            instance.stateTimer = 0
          end
        elseif instance.step == 3 then
          instance.leftEye.eyelidState = 1
          instance.rightEye.eyelidState = 1
          -- if instance.stateTimer > 1.25 then
          if instance.stateTimer > 0.05 then
            instance.step = 4
            instance.stateTimer = 0
          end
        elseif instance.step == 4 then
          instance.leftEye.eyelidState = 0
          instance.rightEye.eyelidState = 0
          -- if instance.stateTimer > 1.25 then
          if instance.stateTimer > 1.2 then
            instance.step = 5
            instance.stateTimer = 0
            instance.laughPrev = 0
          end
        elseif instance.step == 5 then
          local laugh = 15 * instance.stateTimer % 4
          laugh = math.floor(laugh)

          instance.image_index = (laugh ~= 3) and laugh or 1

          if instance.image_index == 0 then
            instance.y = defaultHeadHeight
          elseif instance.image_index == 1 then
            instance.y = defaultHeadHeight + 4
          elseif instance.image_index == 2 then
            instance.y = defaultHeadHeight + 8
          end

          if instance.laughPrev ~= laugh then
            instance.leftEye.eyelidState = love.math.random(0, 2)
            instance.rightEye.eyelidState = love.math.random(0, 2)
          end

          instance.laughPrev = laugh

          if instance.stateTimer > 2.3 and instance.image_index == 0 then
            instance.step = 6
            instance.leftEye.eyelidState = 0
            instance.rightEye.eyelidState = 0
            instance.laughPrev = nil
            instance.stateTimer = 0
            instance.y = defaultHeadHeight
          end
        end
      end

      instance.prevStateTimer = instance.stateTimer
      instance.stateTimer = instance.stateTimer + dt
    end,
    start_state = function(instance, dt)
      instance.stateTimer = 0
      instance.prevStateTimer = 0
      instance.stateDuration = nil
      instance.step = 0
    end,
    check_state = function(instance, dt)
      if instance.step == 6 and instance.stateTimer > 1 then
        instance.state:change_state(instance, dt, "startBattle")
      end
    end,
    end_state = function(instance, dt)
      instance.leftHand.startGrab = nil
      instance.rightHand.startGrab = nil
    end
  },

  startBattle = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
      if pl1 and pl1.exists then
        pl1.animation_state:change_state(pl1, dt, "upstill")
      end
      instance:toggleEnabled(true)
    end,
    check_state = function(instance, dt)
      instance.state:change_state(instance, dt, "battle")
    end,
    end_state = function(instance, dt)
    end
  },

  battle = {
    run_state = function(instance, dt)
      if instance.leftHand.exists and instance.rightHand.exists and instance.leftHand.hp > 0 and instance.rightHand.hp > 0 and not instance.leftHand.slamming and not instance.rightHand.slamming then
        if instance.stateTimer > instance.stateDuration then
          instance.stateDuration = love.math.random() * (3 - instance.sightLoss)
          instance.stateTimer = 0
          if not instance.prevSlamHand then
            if love.math.random() < 0.5 then
              instance.rightHand:slam(true)
              instance.prevSlamHand = "right"
            else
              instance.leftHand:slam(true)
              instance.prevSlamHand = "left"
            end
          elseif instance.prevSlamHand == "right" then
            if love.math.random() < 0.1 then
              instance.rightHand:slam(true)
              instance.prevSlamHand = "right"
            else
              instance.leftHand:slam(true)
              instance.prevSlamHand = "left"
            end
          else
            if love.math.random() < 0.9 then
              instance.rightHand:slam(true)
              instance.prevSlamHand = "right"
            else
              instance.leftHand:slam(true)
              instance.prevSlamHand = "left"
            end
          end
        end
      end

      instance.prevStateTimer = instance.stateTimer
      instance.stateTimer = instance.stateTimer + dt

      instance.angleTimer = instance.blind and instance.angleTimer + dt * 15 or 0
      instance.angle = 0.05 * math.sin(instance.angleTimer)
    end,
    start_state = function(instance, dt)
      instance.prevSlamHand = nil
      instance.stateDuration = love.math.random() * (3 - instance.sightLoss)
      instance.stateTimer = instance.stateDuration
      instance.prevStateTimer = 0
      instance.angleTimer = 0
    end,
    check_state = function(instance, dt)
      if instance.handsLoss > 0 then
        instance.state:change_state(instance, dt, "singleHand")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  singleHand = {
    run_state = function(instance, dt)
      instance.angleTimer = instance.angleTimer + dt * 30
      instance.angle = 0.05 * math.sin(instance.angleTimer)

      if not instance:oneArmed() then return end

      local finalHand = instance:finalHand()

      local nextStep = nil
      if instance.step == 0 then
        if instance.prevStep ~= instance.step then
          instance.stepTimer = 0
        end

        instance.stepTimer = instance.stepTimer + dt * 5

        instance.lastYOffset = math.sin(instance.stepTimer) * 48

        if instance.lastYOffset < 0 then
          nextStep = 1
        end
      elseif instance.step == 1 then
        finalHand:slam(true)
        nextStep = 2

      elseif instance.step == 2 then
        if finalHand.slamming then
          instance.lastYOffset = - math.sin(finalHand.slamming * finalHand.slamTimeFactor) * 8
        else
          instance.lastYOffset = 0
          nextStep = 0
        end
      end

      instance.prevStep = instance.step
      instance.step = nextStep or instance.step
    end,
    start_state = function(instance, dt)
      if not instance.angleTimer then instance.angleTimer = 0 end

      instance.lastYOffset = 0
      instance.prevStep = nil
      instance.step = 0
    end,
    check_state = function(instance, dt)
      if instance.dismembered then
        instance.state:change_state(instance, dt, "cartoonPhysics")
      end
    end,
    end_state = function(instance, dt)
      instance.angle = 0
    end
  },

  cartoonPhysics = {
    run_state = function(instance, dt)
      instance.currentY = instance.currentY - dt * 55
      instance.y = instance.currentY
      if instance.y < instance.stateY then instance.y = instance.stateY end
      instance.body:setPosition(instance.stateX, instance.stateY)
      instance.stateTimer = instance.stateTimer - dt

      -- add instance here to avoid flickering
      -- because the old sprite will be replaced
      -- with head front immediatelly while adding
      -- a gameobject takes one frame
      if instance.stateTimer < 0 then
        local HeadBack = require "GameObjects.bosses.boss2.headBack"
        instance.headBack = HeadBack:new{
          parent = instance
        }
        o.addToWorld(instance.headBack)
      end
    end,
    start_state = function(instance, dt)
      instance.stateX, instance.stateY = instance.body:getPosition()
      instance.currentY = instance.lastY + (instance.lastYOffset or 0)
      instance.stateTimer = 1
    end,
    check_state = function(instance, dt)
      if instance.stateTimer < 0 then
        instance.state:change_state(instance, dt, "fall")
      end
    end,
    end_state = function(instance, dt)
      o.change_layer(instance, 14)
      instance.sprite = im.sprites["Bosses/boss2/HeadFront"]
      instance.iminOverride = 0
    end
  },

  fall = {
    run_state = function(instance, dt)
      local x, y = instance.body:getPosition()

      instance.stateVY = instance.stateVY + instance.stateGravity * dt

      instance.body:setPosition(x, y + instance.stateVY)
      instance.body:setLinearVelocity(0, 0)
    end,
    start_state = function(instance, dt)
      instance.maxHeight = defaultHeadHeight + 6
      instance.stateGravity = 5
      instance.stateVY = 0
      local x, y = instance.body:getPosition()
      y = y - 13
      instance.body:setPosition(x, y)
      instance.y = y
    end,
    check_state = function(instance, dt)
      local _, y = instance.body:getPosition()

      if y > instance.maxHeight then
        instance.state:change_state(instance, dt, "teethGrab")
      end
    end,
    end_state = function(instance, dt)
      local x = instance.body:getPosition()
      instance.body:setPosition(x, instance.maxHeight)
    end
  },

  teethGrab = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(0, 0)
      instance.body:setPosition(instance.stateX, instance.stateY)

      instance.shakeTimer = instance.shakeTimer + dt
      if instance.shakeTimer > instance.shakeFrequency then
        instance.shakeTimer = 0
        instance.shakeX, instance.shakeY = u.polarToCartesian(love.math.random() * 0.3, math.pi * 2 * love.math.random())
      end
      if instance.hp <= 0 then return end
      instance.x, instance.y = instance.x + instance.shakeX, instance.y + instance.shakeY
    end,
    start_state = function(instance, dt)
      local x, y = instance.body:getPosition()
      instance.stateX, instance.stateY = x, y
      instance.iminOverride = 1
      snd.play(instance.sounds.handTouchGround)
      gsh.newShake(mainCamera, "displacement")
      instance.shakeTimer = 0
      instance.shakeFrequency = 0.04
      instance.shakeX, instance.shakeY = 0, 0
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
    end
  }
}

local Boss2 = {}

function Boss2.initialize(instance)
  instance.goThroughEnemies = true
  instance.grounded = true
  instance.grounded = false
  instance.levitating = true
  instance.layer = 7
  instance.sprite_info = im.spriteSettings.boss2
  instance.hp = 10
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.sightLoss = 0
  instance.handsLoss = 0
  -- instance.shielded = true
  -- instance.shieldWall = true
  instance.physical_properties.shape = ps.shapes.bosses.boss2.head
  instance.spritefixture_properties = nil
  instance.image_index = 0
  instance.sounds = snd.load_sounds({
    hit = {"Effects/Oracle_Boss_Hit"},
    fatalHit = {"Effects/Oracle_Boss_Die"},
    crumble = {"Effects/Oracle_FloorCrumble"},
    handTouchGround = {"Effects/Oracle_Boss_BigBoom"},
    handTouchGroundGently = {"Effects/smallBoom"}
  })

  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
end

Boss2.functions = {
  oneArmed = function (self)
    if self.leftHand.exists and not self.rightHand.exists then return true end
    if not self.leftHand.exists and self.rightHand.exists then return true end
    return false
  end,

  finalHand = function (self)
    if not self:oneArmed() then return nil end
    if self.leftHand.exists then return self.leftHand end
    return self.rightHand
  end,

  load = function (self)
    self.body:setPosition(game.room.width * 0.5, game.room.height * 0.5 + 5)
    local x, y = self.body:getPosition()
    local handDistance = 109
    local handHeight = -18

    -- Make hands and eyes
    local Eye = require "GameObjects.bosses.boss2.eye"
    self.leftEye = Eye:new{
      head = self
    }
    o.addToWorld(self.leftEye)
    self.rightEye = Eye:new{
      side = -1,
      head = self
    }
    o.addToWorld(self.rightEye)
    self.leftEye.otherEye = self.rightEye
    self.rightEye.otherEye = self.leftEye
    local Hand = require "GameObjects.bosses.boss2.hand"
    self.leftHand = Hand:new{
      xstart = x + handDistance,
      ystart = y + handHeight,
      x_scale = -1,
      minHeight = handMinHeight,
      head = self
    }
    o.addToWorld(self.leftHand)
    self.rightHand = Hand:new{
      xstart = x - handDistance,
      ystart = y + handHeight,
      minHeight = handMinHeight,
      head = self
    }
    o.addToWorld(self.rightHand)
    self.leftHand.otherHand = self.rightHand
    self.rightHand.otherHand = self.leftHand

    -- Everything set up. Now disable this and children untill
    -- player triggers starting cutscene and battle
    self:toggleEnabled(false)
  end,

  enemyUpdate = function (self, dt)
    -- Get ticked by decoy
    self.target = session.decoy or pl1

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state.states[state.state].check_state(self, dt)
    -- Run animation state
    state.states[state.state].run_state(self, dt)

    -- Special boss shader handling
    if self.dying then
      self.myShader = hitShader
    elseif self.invulnerable then
      self.myShader = nil
      if math.floor(7 * self.invulnerable % 2) == 1 then
        self.myShader = hitShader
      end
    else
      self.myShader = nil
    end
  end,

  late_update = function (self, dt)
    if self.enabled and self.handsLoss == 0 and self.leftHand.exists and self.rightHand.exists then
      local x = (self.rightHand.x + self.leftHand.x) * 0.5
      local y = defaultHeadHeight - 0.5 * (self.leftHand.y + self.rightHand.y - 2 * handMinHeight)
      self.body:setPosition(x, defaultHeadHeight)
      self.y = y
      -- self.lastX = x
      self.lastY = y
    elseif self.handsLoss == 1 then
      local x, y = self.body:getPosition()
      self.lastY = self.lastY - dt * 44
      if self.lastY < y then
        self.lastY = y
      end
      -- Move towards non missing hand
      local xSpeed = self:oneArmed() and 33 or 22
      local distFromHand = 44
      local target = x
      if not self.leftHand.exists or self.leftHand.dyingY then
        target = self.rightHand.x + distFromHand
      elseif not self.rightHand.exists or self.rightHand.dyingY then
        target = self.leftHand.x - distFromHand
      end

      if target > x then
        x = x + dt * xSpeed
      elseif target < x then
        x = x - dt * xSpeed
      end

      self.body:setPosition(x, defaultHeadHeight)
      self.y = self.lastY + (self.lastYOffset or 0)
    end

    -- Check if blind
    if not self.blind then
      if not self.rightEye.exists and not self.leftEye.exists then
        self:becomeBlinded()
      end
    end

    -- Check if dismembered
    if not self.dismembered then
      if self.handsLoss > 1 then
        self:becomeDismembered()
      end
    end

    if self.enabled then
      self.image_index = self.greatPain and 2 or (self.blind and 1 or 0)

      -- if self.blind and not self.dismembered then
      --   -- < 68 mouth visible
      -- end

      -- Reaction to taking damage
      if self.invulnerable then
        if self.invulnerable > 0.2 then
          self.image_index = 2
        else
          self.image_index = self.greatPain and 2 or 1
        end
      end
    end

    if self.iminOverride then
      self.image_index = self.iminOverride
    end
  end,

  lostHp = function (self)
    if self.hp <= 0 then
      self.dying = true
      self.invulnerable = 2
      snd.play(self.sounds.fatalHit)
    else
      self:takeDamage()
      self.invulnerable = 0.3
    end
  end,

  hitBySword = function (self, other, myF, otherF)
    if not self.dismembered or self.dying then return end

    self.hp = self.hp - 2

    self:lostHp()
  end,

  hitByMissile = function (self, other, myF, otherF)
    if not self.dismembered or self.dying then return end

    self.hp = self.hp - 1

    self:lostHp()
  end,

  hitByThrown = function (self, other, myF, otherF)
    if not self.dismembered or self.dying then return end

    self.hp = self.hp - 3

    self:lostHp()
  end,

  hitByBombsplosion = function (self, other, myF, otherF)
    if not self.dismembered or self.dying then return end

    self.hp = self.hp - 4

    self:lostHp()
  end,

  hitByBullrush = function (self, other, myF, otherF)
  end,

  hitSolidStatic = function (self, other, myF, otherF)
  end,

  die = function (self)
    local explOb = expl:new{
      x = self.x or self.xstart, y = self.y or self.ystart,
      layer = self.layer,
      explosionNumber = self.explosionNumber or 9,
      explosion_sprite = self.explosionSprite or im.spriteSettings.testsplosion,
      image_speed = self.explosionSpeed or 0.5,
      explodeDistance = 40,
      onlySoundOnce = true,
      sounds = snd.load_sounds({explode = {"Effects/Oracle_Boss_Explode"}})
    }
    o.addToWorld(explOb)
    o.removeFromWorld(self)
    game.room.music_info = snd.silence
    snd.bgmV2.getMusicAndload()
  end,

  -- draw = function (self)
  --
  --   -- Draw enemy the default way
  --   et.functions.draw(self)
  --
  --   -- Draw extra stuff like eyes and hands.
  --
  --   -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  -- end,

  destroy = function (self)
    -- What happens when I get destroyed.
  end,

  toggleEnabled = function (self, enabled)
    self.enabled = enabled
    self:refreshComponents()
  end,

  becomeBlinded = function (self)
    self.blind = true
    self:refreshComponents()
  end,

  becomeDismembered = function (self)
    self.dismembered = true
    self:refreshComponents()
  end,

  takeDamage = function (self)
    snd.play(self.sounds.hit)
    self.invulnerable = 1
    self.greatPain = self.handsLoss > 0
  end,

  refreshComponents = function (self)
    self.bombGoesThrough = true
    self.goThroughPlayer = not self.enabled
    self.pushback = self.enabled
    self.harmless = not self.enabled or self.dismembered
    self.ballbreaker = self.blind and self.enabled
    self.attackDodger = not self.enabled
    if self.leftHand.exists then self.leftHand:refreshComponents() end
    if self.rightHand.exists then self.rightHand:refreshComponents() end
    if self.leftEye.exists then self.leftEye:refreshComponents() end
    if self.rightEye.exists then self.rightEye:refreshComponents() end
  end,
}

function Boss2:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss2, instance, init) -- add own functions and fields
  return instance
end

return Boss2
