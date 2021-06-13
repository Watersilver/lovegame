local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local gsh = require "gamera_shake"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local sm = require "state_machine"
local u = require "utilities"
local game = require "game"
local o = require "GameObjects.objects"
local expl = require "GameObjects.explode"

local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local cd = require "GameObjects.DialogueBubble.controlDefaults"

local wreckingBall = require "GameObjects.bosses.boss4.wreckingBall"

local shdrs = require "Shaders.shaders"
local hitShader = shdrs.enemyHitShader
local deathShader = shdrs.bossDeathShader

local pi = math.pi

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "cutscene")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  wait = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(0, 0)
      instance.waittimer = instance.waittimer - dt
    end,
    start_state = function(instance, dt)
      instance.waittimer = instance.waittimer or 1
    end,
    check_state = function(instance, dt)
      if instance.waittimer <= 0 then
        instance.state:change_state(instance, dt, "still")
      end
    end,
    end_state = function(instance, dt)
      instance.waittimer = nil
    end
  },

  still = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(0, 0)
    end,
    start_state = function(instance, dt)
      instance.ball:contract()
      instance.ball:toggleSpikes(false)
    end,
    check_state = function(instance, dt)
      if instance.ball.attached then
        -- Choose next state
        instance.state:change_state(instance, dt, u.chooseFromWeightTable{
          {value = "bounceAround", weight = 100},
          {value = "jump", weight = 75},
          {value = "swing", weight = (instance:isShieldBroken() and 200 or 100)},
          {value = "powerThrow", weight = instance.justPowerThrowed and 0 or 90}
        })
        instance.justPowerThrowed = false
      end
    end,
    end_state = function(instance, dt)
    end
  },

  pull = {
    run_state = function(instance, dt)

      if instance.step == 0 then
        snd.play(glsounds.enemyJump)
        instance.zvel = -100
        instance.step = 1
      elseif instance.step == 1 then
        instance.body:setLinearVelocity(0, 0)
        instance.zo = instance.zo + instance.zvel * dt
        instance.zvel = instance.zvel + instance.grav * dt
        if instance.zo >= 0 then
          instance.step = 2
          instance.zo = 0
          if instance.ball.state.state ~= "grabbed" then
            instance.step = 999
          end
        end
      else
        instance.pulltime = instance.pulltime + dt

        local _, dir = u.cartesianToPolar(instance.target.x - instance.x, instance.target.y - instance.y)
        instance.body:setLinearVelocity(u.polarToCartesian(10, dir + math.pi))

        local bdist, bdir = u.cartesianToPolar(instance.x - instance.ball.x, instance.y - instance.ball.y)
        instance.ball.body:applyForce(u.polarToCartesian(math.min(1000, 100 + instance.pulltime * 133) * instance.ball.body:getMass(), bdir))
      end

    end,
    start_state = function(instance, dt)
      instance.hand_index = 0
      instance.walk_anim_speed = 10
      instance.step = 0
      instance.grav = 400
      instance.pulltime = 0
      instance.ball:emote("fear")
    end,
    check_state = function(instance, dt)
      if instance.step == 999 then
        instance.ball:emote("neutral")
        instance.state:change_state(instance, dt, "still")
      elseif instance.step == 777 then
        instance.state:change_state(instance, dt, "wait")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  jump = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(0, 0)
      if instance.step == 0 then
        if instance.ball.attached then
          instance.step = 1
        end
      elseif instance.step == 1 then
        instance.timer = instance.timer - dt
        if instance.timer > 2.25 then
          instance.hand_index = 1
        elseif instance.timer > 1.25 then
          instance.hand_index = 0
        elseif instance.timer > 1 then
          instance.hand_index = 1
        elseif instance.timer > 0.75 then
          instance.hand_index = 0
          instance.ball:emote("crazy")
        elseif instance.timer > 0.5 then
          instance.hand_index = 1
        elseif instance.timer > 0.25 then
          instance.hand_index = 0
        else
          instance.step = 2
          instance.ball:emote("madlaugh")
        end
      elseif instance.step == 2 then
        instance.hand_index = 1
        instance.ball:stopState()
        instance.step = 3
        instance.ball.body:setPosition(instance:getHandPosition(2))
        instance.timer = 0.5
      elseif instance.step == 3 then
        instance.ball.zo = instance.ball.zo - dt * instance.jspeed
        if instance.timer < 0 then
          instance.step = 4
          instance.timer = 1.25
          instance.ball:emote("mania")
        end
        instance.timer = instance.timer - dt
      elseif instance.step == 4 then
        instance.ball.zo = instance.ball.zo - dt * instance.jspeed
        instance.zo = instance.zo - dt * instance.jspeed
        if instance.timer < 0 then
          instance.step = 5
          instance.ball:contract()
        end
        instance.timer = instance.timer - dt
      elseif instance.step == 5 then
        if instance.ball.attached then
          instance.body:setPosition(-222, -222)
          instance.timer = love.math.random() * 2 + 1
          instance.step = 6
        end
      elseif instance.step == 6 then
        if instance.timer < 0 then
          instance.zo = -300
          instance.step = 7
          instance.hand_index = 0
          instance.body:setPosition(instance.target.x, instance.target.y)
          -- instance.body:setPosition(0, 0)
        end
        instance.timer = instance.timer - dt
      elseif instance.step == 7 then
        instance.zo = instance.zo + dt * instance.jspeed
        if instance.zo >= 0 then
          instance.zo = 0
          instance.step = 8
        end
      elseif instance.step == 8 then
        -- BOOM
        gsh.newShake(mainCamera, "displacement", 1.5, nil, 1.5)
        instance.step = 9
        instance.timer = 0.5
        snd.play(glsounds.bigBoom)
        if pl1 and pl1.exists and pl1.zo >= 0 then
          pl1.triggers.damaged = pl1.triggers.damaged or 0
          pl1.triggers.noInvFrames = true
          pl1.triggers.damCounter = 2
          pl1.zo = -0.1
        end
      elseif instance.step == 9 then
        if instance.timer <= 0 then
          instance.step = 10
        end
        instance.timer = instance.timer - dt
      end
    end,
    start_state = function(instance, dt)
      instance.ball:contract()
      instance.timer = 3.25
      instance.step = 0
      instance.walk_anim_speed = 0
      instance.ball:emote("ready")

      instance.jspeed = 300
    end,
    check_state = function(instance, dt)
      if instance.step == 10 then
        instance.state:change_state(instance, dt, "still")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  powerThrow = {
    run_state = function(instance, dt)
      instance.builduptimer = instance.builduptimer - dt
      if instance.builduptimer < 0 then instance.builduptimer = 0 end

      if not instance.ball.spikedup and instance.ball.attached then
        instance.ball:toggleSpikes(true)
      end

      if instance.builduptimer ~= 0 then
        if instance.builduptimer < 1.66 then
          instance:shake(dt, 2)
          instance.ball:emote("cruel")
        end
      else
        if not instance.throwing then
          if instance.ball.attached then
            instance.throwing = true
            instance.ball:emote("mania")

            local _, dir = u.cartesianToPolar(instance.target.x - instance.ball.x, instance.target.y - instance.ball.y)
            instance.ball:bounceAround(500, dir)
            instance.hand_index = 0
          end
        elseif instance.ball.state.state == "grabchance" then
          instance.powerThrowTimer = instance.powerThrowTimer - dt
        end
      end
    end,
    start_state = function(instance, dt)
      instance.walk_anim_speed = 0
      instance.hand_index = 1
      instance:determineImageIndex()

      instance.builduptimer = 3
      instance.powerThrowTimer = 3

      instance.statexstart = instance.x
      instance.stateystart = instance.y

      instance.ball:contract()
      instance.ball:emote("ready")
    end,
    check_state = function(instance, dt)
      if instance.ball.state.state == "grabbed" then
        instance.state:change_state(instance, dt, "pull")
      elseif instance.powerThrowTimer < 0 then
        instance.state:change_state(instance, dt, "still")
      end
    end,
    end_state = function(instance, dt)
      instance.throwing = nil
      instance.justPowerThrowed = true
    end
  },

  bounceAround = {
    run_state = function(instance, dt)
      instance.builduptimer = instance.builduptimer - dt
      if instance.builduptimer < 0 then instance.builduptimer = 0 end

      if instance.builduptimer ~= 0 then
        if instance.builduptimer < 1 then
          instance:shake(dt)
        end
      else
        if not instance.bouncing then
          instance.bouncing = true
          instance.ball:emote("crazy")

          local pattern = love.math.random()
          local ballspeed = love.math.random(170, 190)
          if pattern > 0.75 then -- self move to player
            local _, dir = u.cartesianToPolar(instance.target.x - instance.x, instance.target.y - instance.y)
            instance.direction = dir
            instance.ball:bounceAround(ballspeed)
          elseif pattern > 0.5 then -- ball move to player
            instance.direction = love.math.random() * 2 * math.pi - math.pi
            local _, dir = u.cartesianToPolar(instance.target.x - instance.ball.x, instance.target.y - instance.ball.y)
            instance.ball:bounceAround(ballspeed, dir)
          elseif pattern > 0.25 then -- self and ball sort of towards player
            local _, dirself = u.cartesianToPolar(instance.target.x - instance.x, instance.target.y - instance.y)
            local _, dirball = u.cartesianToPolar(instance.target.x - instance.ball.x, instance.target.y - instance.ball.y)
            local dirsign = love.math.random() > 0.5 and 1 or -1
            dirself = dirself + dirsign * math.pi * 0.062
            dirball = dirball - dirsign * math.pi * 0.062
            instance.direction = dirself
            instance.ball:bounceAround(ballspeed, dirball)
          else -- completely random
            instance.direction = love.math.random() * 2 * math.pi - math.pi
            instance.ball:bounceAround(ballspeed)
          end
          instance.launchspeed = love.math.random(130, 150)
          instance:launch()
          instance.hand_index = 0
          instance.walk_anim_speed = 7
          instance.fixture:setRestitution(1)
        else
          instance.bounceTimer = instance.bounceTimer - dt

          if instance.ball.spikedup then
            instance.ball:emote("madlaugh")
          end
        end
      end
    end,
    start_state = function(instance, dt)
      instance.walk_anim_speed = 0
      instance.hand_index = 1
      instance:determineImageIndex()

      instance.builduptimer = 2
      instance.bounceTimer = love.math.random() * 9 + 3

      instance.statexstart = instance.x
      instance.stateystart = instance.y

      instance.ball:contract()
      instance.ball:emote("ready")
    end,
    check_state = function(instance, dt)
      if instance.ball.state.state == "grabbed" then
        instance.state:change_state(instance, dt, "pull")
      elseif instance.bounceTimer < 0 then
        instance.state:change_state(instance, dt, "still")
      end
    end,
    end_state = function(instance, dt)
      instance.bouncing = nil
      instance.fixture:setRestitution(0)
    end
  },

  swing = {
    run_state = function(instance, dt)
      if instance:isShieldBroken() then
        instance:moveTowards(
          instance.target, {
            {50, 75},
            {0, 50}
          }
        )
      else
        instance:moveTowards(
          instance.target, {
            {75, 50},
            {50, 25},
            {25, 17.5}
          }
        )
      end

      if instance.ball.attached then
        instance.ball:swing()
        if instance:isShieldBroken() then
          if love.math.random() < 0.75 then
            instance.ball:emote("cruel")
          else
            instance.ball:emote("madlaugh")
          end
        else
          instance.ball:emote("madlaugh")
        end
      end
      instance.t = instance.t - dt
    end,
    start_state = function(instance, dt)
      instance.walk_anim_speed = 4
      instance.hand_index = 1
      instance:determineImageIndex()
      instance.t = instance:isShieldBroken() and love.math.random(20) or 0

      instance.ball:contract()
      instance.ball:emote("ready")
    end,
    check_state = function(instance, dt)
      if instance.t <= 0 and instance.ball.swingDone then
        instance.state:change_state(instance, dt, "still")
      end
    end,
    end_state = function(instance, dt)
      instance.walk_anim_speed = 0
    end
  },

  cutscene = {
    run_state = function(instance, dt)
      local prevstep = instance.step

      if instance.step == 0 then
        if pl1 and pl1.exists then
          if pl1.y < 200 then
            local xsc = pl1.x_scale
            pl1.animation_state:change_state(pl1, dt, "cutscene")
            pl1.body:setLinearVelocity(0, 0)
            pl1.x_scale = xsc
            instance.step = instance.step + 1
          end
        end
      elseif instance.step == 1 then
        if pl1 and pl1.exists then
          if pl1.zo == 0 then
            pl1.sprite = im.sprites["Witch/still_up"]
            pl1.x_scale = 1
            instance.step = instance.step + 1
            instance.timer = 1
          end
        end
      elseif instance.step == 2 then
        if instance.timer < 0 then
          instance.step = instance.step + 1
        end
        instance.timer = instance.timer - dt
      elseif instance.step == 3 then
        instance.speak = true
        instance.step = instance.step + 1
        instance.timer = 1
      elseif instance.step == 5 then
        if instance.timer < 0 then
          instance.zo = -200
          instance.step = instance.step + 1
          instance.ball:emote("confusion")
          o.change_layer(instance.ball, instance.ball.layer + 1)
        end
        instance.timer = instance.timer - dt
      elseif instance.step == 6 then
        instance.body:setPosition(game.room.width / 2, game.room.height / 2)
        instance.step = instance.step + 1
        snd.play(glsounds.blockFall)
      elseif instance.step == 7 then
        instance.zo = instance.zo + dt * 100
        if instance.zo >= 0 then
          o.change_layer(instance.ball, instance.ball.layer - 1)
          instance.cutsceneland = true
          instance.zo = 0
          gsh.newShake(mainCamera, "displacement")
          snd.play(glsounds.bigBoom)
          instance.timer = 2
          instance.step = instance.step + 1
        end
      elseif instance.step == 8 then
        instance.timer = instance.timer - dt
        if instance.timer <= 0 then
          instance.step = instance.step + 1
          instance.waitTimer = 0
        end
      end

      instance.changedStep = prevstep ~= instance.step
    end,
    start_state = function(instance, dt)
      instance.body:setPosition(game.room.width / 2, -222)
      instance.step = 0
      instance.timer = 0
      instance.walk_index = 1
      instance.walk_anim_speed = 0
    end,
    check_state = function(instance, dt)
      if instance.step == 10 then
        if pl1 and pl1.exists then
          pl1.animation_state:change_state(pl1, dt, "upstill")
        end
        instance.state:change_state(instance, dt, "swing")
      end
    end,
    end_state = function(instance, dt)
      instance.step = nil
      instance.timer = nil
      instance.changedStep = nil

      instance.ball.dlgState = "done"
      instance.ball.updateHook = nil

      game.room.music_info = "SoMBelieveinVictory"
      snd.bgmV2.getMusicAndload()
    end
  }
}

local Boss4 = {}

function Boss4.initialize(instance)
  instance.sprite_info = im.spriteSettings.boss4
  instance.image_index = 0
  instance.walk_index = 0
  instance.walk_frames = 2
  instance.walk_anim_speed = 0
  instance.hand_index = 0
  instance.hand_frames = 2
  instance.zo = 0
  instance.universalForceMod = 0
  instance.unpushable = true
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.canLeaveRoom = true
  instance.hp = 60
  instance.deathInvulnerable = 2
  instance.initialHP = instance.hp
  instance.sounds = snd.load_sounds({
    hitSound = {"Effects/Oracle_Boss_Hit"},
    fatalHit = {"Effects/Oracle_Boss_Die"},
  })
  instance.layer = (pl1 and pl1.layer) and pl1.layer - 1 or 20
  instance.groundLayer = instance.layer
  instance.airLayer = instance.layer + 1
  instance.physical_properties.shape = ps.shapes.bosses.boss4.body
  instance.spritefixture_properties.shape = ps.shapes.bosses.boss4.sprite
  instance.spriteOffset = 6
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.grip = {
    x = 0,
    y = 0
  }
  instance.attackDmg = 2
  instance.shieldDmg = 0
  instance.content = nil
  instance.content_index = 0
end

local dialogue = {
  "Did you hear something?",
  "Huh? Let's go see.",
  "...A creature.",
  "Squishy.",
  "It seeks to stop us!",
  "It wants to destroy the world!",
  "It opposes the empire!",
  "Foolish creature. The empire cannot be stopped.",
  "The empire will consume all.",
  "And then all will be the empire.",
  "All will be perfect!",
  "HAIL THE EMPIRE!",
}

Boss4.functions = {

  -- dialogue stuff
  setSpeaker = function (self, speaker)
    self.speaker = speaker or self
    if self.ball == speaker then
      self.bubbleOffsetX = -(self.x - self.ball.x)
      self.bubbleOffsetY = nil
    else
      self.bubbleOffsetX = 5
      self.bubbleOffsetY = nil
    end
  end,

  waitHook = function (self, dt)
    if self.waitTimer then
      self.waitTimer = self.waitTimer - dt
      if self.waitTimer < 0 then
        self.waitTimer = nil
        self.speak = true
        self.updateHook = nil

        if self.content_index == 11 then
          self.ball.speak = true
        end
      end
    end
  end,

  handleHookReturn = function (self)
    if self.speaking then
      self.speaking = false
      self.waitTimer = 0.3
      cd.cleanSsb(self)

      if self.content_index == 2 then
        self.waitTimer = nil
        self.step = self.step + 1
      elseif self.content_index == 12 then
        self.waitTimer = nil
        self.step = self.step + 1
      end

      self.dlgState = "waiting"
    elseif self.speak then
      self.speak = false
      self.speaking = true

      self.content_index = self.content_index + 1

      if self.content_index == 2 or self.content_index == 4
      or self.content_index == 6 or self.content_index == 8
      or self.content_index == 10 or self.content_index == 12 then
        self:setSpeaker(self.ball)
      else
        self:setSpeaker(self)
      end

      if self.content_index == 4 then
        self.ball:emote("neutral")
      elseif self.content_index == 8 then
        self.ball:emote("ready")
      elseif self.content_index == 10 then
        self.ball:emote("crazy")
      elseif self.content_index == 11 then
        self.hand_index = 1
      elseif self.content_index == 12 then
        self.ball:emote("mania")
      end

      self.content = dialogue[self.content_index]
      self.ssbStayOnScreen = true
      self.ssbRGBA = {COLORCONST, 0, 0, COLORCONST}

      if self.cutsceneland and self.speaker ~= self.ball then
        self.ssbPosition = "up"
      else
        self.ssbPosition = "down"
      end
      cd.cleanSsb(self)

      self.dlgState = "talking"
    end
  end,

  determineUpdateHook = function (self)
    if self.dlgState == "waiting" then
      self.updateHook = self.waitHook
    elseif self.dlgState == "talking" then
      -- self.blockInput = true
      self.updateHook = cd.singleSimpleInteractiveBubble
    end
  end,
  -- end dialogue stuff

  determineComponents = function (self)

    if self:isShieldBroken() then
      self.undamageable = false
      self.shielded = false
      self.shieldWall = false
    else
      self.undamageable = true
      self.shielded = true
      self.shieldWall = true
    end

    if self.zo < 0 then
      self.undamageable = true
    end

    if self.zo < 0 and (not self.zoprev or self.zoprev >= 0) then
      o.change_layer(self, self.airLayer)
      self.attackDodger = true
      self.pushback = false
      self.ballbreaker = false
      self.harmless = true
      self.goThroughPlayer = true
    elseif self.zo >= 0 and (not self.zoprev or self.zoprev < 0) then
      o.change_layer(self, self.groundLayer)
      self.attackDodger = false
      self.pushback = true
      self.ballbreaker = true
      self.harmless = false
      self.goThroughPlayer = false
    end

    -- self.goThroughPlayer = true
    -- self.harmless = true

    self.zoprev = self.zo
  end,

  isShieldBroken = function (self)
    return self.shieldDmg > 2
  end,

  getHandPosition = function (self, index)
    local x, y = self.x, self.y
    index = index or self.image_index
    if index == 0 then
      x = x - 7
      y = y + 7
    elseif index == 1 then
      x = x - 6
      y = y + 6
    elseif index == 2 then
      x = x - 10
      y = y - 10.5
    elseif index == 3 then
      x = x - 10
      y = y - 9.5
    end
    return x, y
  end,

  determineImageIndex = function (self)
    self.image_index = math.floor(self.walk_index + math.floor(self.hand_index) * 2)
  end,

  moveTowards = function (self, target, distToSpeed)
    if target and target.exists then
      local r, th = u.cartesianToPolar(target.x - self.x, target.y - self.y)
      local speed = 0

      if type(distToSpeed) == "number" then
        distToSpeed = {0, distToSpeed}
      end

      -- Determine speed
      for _, dspair in ipairs(distToSpeed) do
        if r > dspair[1] then
          speed = dspair[2]
          break
        end
      end

      self.body:setLinearVelocity(u.polarToCartesian(speed, th))
    end
  end,

  launch = function (self)
    self.body:setLinearVelocity(u.polarToCartesian(self.launchspeed, self.direction))
  end,

  shake = function (self, dt, magn)
    if self.shaketimer then
      self.shaketimer = self.shaketimer - dt
      if self.shaketimer <= 0 then self.shaketimer = nil end
    else
      self.shaketimer = 0.05
      local offx, offy = u.polarToCartesian(love.math.random() * (magn or 1), love.math.random() * 2 * math.pi - math.pi)
      self.body:setPosition(self.statexstart + offx, self.stateystart + offy)
    end
  end,

  load = function (self)
    dlgCtrl.functions.load(self)
    self.shadowHeightMod = self.sprite.height * 0.5 - 8
    self:createBall()
  end,

  createBall = function (self)
    if self.ball then return end
    self.ball = wreckingBall:new{
      x = self.x, y = self.y,
      xstart = self.x, ystart = self.y,
      layer = self.layer + 1,
      creator = self
    }
    o.addToWorld(self.ball)
  end,

  die = function (self)
    local explOb = expl:new{
      x = self.x or self.xstart, y = self.y or self.ystart,
      layer = self.layer,
      explosionNumber = self.explosionNumber or 9,
      explosion_sprite = self.explosionSprite or im.spriteSettings.testsplosion,
      image_speed = self.explosionSpeed or 0.5,
      onlySoundOnce = true,
      sounds = snd.load_sounds({explode = {"Effects/Oracle_Boss_Explode"}})
    }
    o.addToWorld(explOb)
    o.removeFromWorld(self)
    game.room.music_info = snd.silence
    snd.bgmV2.getMusicAndload()
    for _, door in ipairs(o.identified.DunDoor) do
      door:open()
    end
  end,

  enemyUpdate = function (self, dt)
    dlgCtrl.functions.update(self, dt)

    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.invulnerable then
      if not self.invPrev then
        self.storedv = {}
        self.storedv.x, self.storedv.y = self.body:getLinearVelocity()
      end
      self.body:setLinearVelocity(0, 0)
    else
      if self.storedv then
        self.body:setLinearVelocity(self.storedv.x, self.storedv.y)
        self.storedv = nil
      end

      -- do stuff depending on state
      local state = self.state
      state.states[state.state].check_state(self, dt)
      state.states[state.state].run_state(self, dt)

      -- determine image index
      self.walk_index = self.walk_index + dt * self.walk_anim_speed
      while self.walk_index >= self.walk_frames do
        self.walk_index = self.walk_index - self.walk_frames
      end
      self:determineImageIndex()
    end
    self.invPrev = self.invulnerable

    self:determineComponents()

    -- Special boss shader handling
    if self.hp <= 0 then
      self.myShader = deathShader
    elseif self.invulnerable then
      self.myShader = nil
      if math.floor(7 * self.invulnerable % 2) == 1 then
        self.myShader = hitShader
      end
    else
      self.myShader = nil
    end

    sh.handleShadow(self)

  end,

  enemyBeginContact = function (self, other, myF, otherF, coll)
    if other == self.ball and self.state.state == "pull" then
      if self.pulltime and self.pulltime > 1 and other.speed > 333 then
        if other.state.state == "grabbed" then
          self.step = 999
        else
          local _, dir = u.cartesianToPolar(other.x - self.x, other.y - self.y)
          other:bounceAround(35, dir)
          self.step = 777
          self.walk_anim_speed = 0
          if self:isShieldBroken() then
            self.lastHit = "custom"
            self.customDamage = 5
            ebh.damagedByHit(self, other, myF, otherF)
          else
            self.shieldDmg = self.shieldDmg + 1
            snd.play(glsounds.dragonWalk)
            self.invulnerable = (self.invframesMod or 1) * 0.25
          end
        end
      else
        self.step = 999
      end

    end
  end,

  endContact = function (self, a, b, coll, aob, bob)
    if not a:isSensor() and not b:isSensor() and coll:isEnabled() and self.bouncing then
      -- restitution doesn't result in a perfect elastic bounce, so fix here
      -- Also gets called when touching other enemy or player but doesn't matter
      self._, self.direction = u.cartesianToPolar(self.body:getLinearVelocity())
      self:launch()
    end
  end,

  draw = function (self)

    -- Draw enemy the default way
    et.functions.draw(self)

    -- Draw shield
    if not self:isShieldBroken() then
      local zo = self.zo or 0
      local xtotal, ytotal = self.x, self.y + zo + 2.5
      local shield_index = 0
      local shield_xscale = 1

      -- calculate offset and mirroring
      if math.floor(self.image_index) % 2 == 0 then
        xtotal = xtotal + 4
        if self.shieldDmg == 1 then
          shield_index = 1
        elseif self.shieldDmg > 1 then
          shield_index = 3
        end
      else
        xtotal = xtotal + 6.8
        if self.shieldDmg == 1 then
          shield_index = 2
        elseif self.shieldDmg > 1 then
          shield_index = 4
        else
          shield_xscale = -1
        end
      end

      local sprite = im.sprites["Bosses/boss4/shield"]
      local frame = sprite[math.floor(shield_index)]

      local worldShader = love.graphics.getShader()
      love.graphics.setShader(self.myShader)
      love.graphics.draw(
      sprite.img, frame, xtotal, ytotal, self.angle,
      shield_xscale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
      sprite.cx, sprite.cy)
      love.graphics.setShader(worldShader)
    end

    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
  end,
}

function Boss4:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(dlgCtrl, instance) -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss4, instance, init) -- add own functions and fields
  return instance
end

return Boss4
