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
      if pl1.y < 162 then
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
      if (instance.prevStateTimer < 2 and instance.stateTimer > 2) or
      (instance.prevStateTimer < 5 and instance.stateTimer > 5)
      then
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
      instance.stateDuration = 7
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
          end

          local strain = 20 * instance.stateTimer % 2
          strain = math.floor(strain)
          if strain == 0 then instance.y = instance.y + 1
          else instance.y = instance.y - 1 end
        elseif instance.step == 2 then
          if instance.stateTimer > 0.5 then
            instance.step = 3
            instance.stateTimer = 0
          end
        elseif instance.step == 3 then
          instance.leftEye.eyelidState = 1
          instance.rightEye.eyelidState = 1
          if instance.stateTimer > 1.25 then
            instance.step = 4
            instance.stateTimer = 0
          end
        elseif instance.step == 4 then
          instance.leftEye.eyelidState = 0
          instance.rightEye.eyelidState = 0
          if instance.stateTimer > 1.25 then
            instance.step = 5
            instance.stateTimer = 0
            instance.laughPrev = 0
          end
        elseif instance.step == 5 then
          local laugh = 15 * instance.stateTimer % 4
          laugh = math.floor(laugh)

          instance.image_index = (laugh ~= 3) and laugh or 1

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
    end,
    end_state = function(instance, dt)
    end
  }
}

local Boss2 = {}

function Boss2.initialize(instance)
  instance.goThroughEnemies = true
  instance.grounded = true
  instance.levitating = true
  instance.layer = 11
  instance.sprite_info = im.spriteSettings.boss2
  instance.hp = 50
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  -- instance.shielded = true
  -- instance.shieldWall = true
  instance.physical_properties.shape = ps.shapes.bosses.boss2.head
  instance.spritefixture_properties = nil
  instance.image_index = 0
  instance.sounds = snd.load_sounds({
    hit = {"Effects/Oracle_Boss_Hit"},
    fatalHit = {"Effects/Oracle_Boss_Die"},
    crumble = {"Effects/Oracle_FloorCrumble"},
    handTouchGround = {"Effects/Oracle_Boss_BigBoom"}
  })

  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
end

Boss2.functions = {
  load = function (self)
    self.body:setPosition(game.room.width * 0.5, game.room.height * 0.5 + 5)
    local x, y = self.body:getPosition()
    local handDistance = 109
    local handHeight = -18

    -- Make hands and eyes
    local Hand = require "GameObjects.bosses.boss2.hand"
    self.leftHand = Hand:new{
      xstart = x + handDistance,
      ystart = y + handHeight,
      x_scale = -1,
      head = self
    }
    o.addToWorld(self.leftHand)
    self.rightHand = Hand:new{
      xstart = x - handDistance,
      ystart = y + handHeight,
      head = self
    }
    o.addToWorld(self.rightHand)
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

    -- Everything set up. Now disable this and children untill
    -- player triggers starting cutscene and battle
    self:toggleEnabled(false)
  end,

  enemyUpdate = function (self, dt)
    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state.states[state.state].check_state(self, dt)
    -- Run animation state
    state.states[state.state].run_state(self, dt)

    -- Special boss shader handling
    if self.dying then
      self.myShader = deathShader
    elseif self.invulnerable then
      self.myShader = nil
      if math.floor(7 * self.invulnerable % 2) == 1 then
        self.myShader = hitShader
      end
    else
      self.myShader = nil
    end

    self.gotHit = false
  end,

  late_update = function (self, dt)
    if self.leftHand.exists and self.rightHand.exists then
      local x = (self.rightHand.x + self.leftHand.x) * 0.5
      local _, y = self.body:getPosition()
      self.body:setPosition(x, y)
    end
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
  end,

  draw = function (self)

    -- Draw enemy the default way
    et.functions.draw(self)

    -- Draw extra stuff like eyes and hands.

    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  end,

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

  refreshComponents = function (self)
    self.bombGoesThrough = true
    self.goThroughPlayer = not self.enabled
    self.pushback = self.enabled
    self.harmless = not self.enabled
    self.ballbreaker = self.blind and self.enabled
    self.attackDodger = not self.enabled
    self.leftHand:refreshComponents()
    self.rightHand:refreshComponents()
    self.leftEye:refreshComponents()
    self.rightEye:refreshComponents()
  end,
}

function Boss2:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss2, instance, init) -- add own functions and fields
  return instance
end

return Boss2
