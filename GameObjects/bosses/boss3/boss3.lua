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

local proj = require "GameObjects.enemies.projectile"

local pi = math.pi

local animationTable = {
  wingsOpen = {0,1,2,3,4,5,12,14,16},
  wingsClosed = {6,7,8,9,10,11,13,15,17},
  leftLegUp = {0,2,4,6,8,10},
  rightLegUp = {1,3,5,7,9,11},
  inTheAir = {12,13,14,15,16,17},
  mouthClosed = {0,1,6,7,12,13},
  mouthHalfOpen = {2,3,8,9,14,15},
  mouthOpen = {4,5,10,11,16,17},
  -- charge 18, still 19, bush 20

  init = function (self)
    if self.initialized then return end
    self.initialized = true
    local subtables = {}
    for subtable, value in pairs(self) do
      if type(value) == "table" then
        table.insert(subtables, subtable)
      end
    end
    for i = 0, 17 do
      self[i] = {}
    end
    for _, subtable in ipairs(subtables) do
      for _, index in ipairs(self[subtable]) do
        self[index][subtable] = true
      end
    end
  end,

  getStateIndex = function (self, state)
    -- narrow possible indexes down to one
    local possibleIndexes = {}
    for _, mouthIndex in ipairs(self[state.mouth]) do
      table.insert(possibleIndexes, mouthIndex)
    end
    for _, possibleIndex in ipairs(possibleIndexes) do
      if self[possibleIndex][state.legs] and self[possibleIndex][state.wings] then
        return possibleIndex
      end
    end
    return 20
  end
}
animationTable:init()

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "bush")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  bush = {
    run_state = function(instance, dt)
      instance.stateTimer = instance.stateTimer - dt
      if instance.stateTimer < 0 then instance.stateTimer = 0 end
      local preStateProg = instance.stateProg

      if instance.stateProg == 0 then
        if pl1 and pl1.x and u.magnitude2d(pl1.x - instance.x, pl1.y - instance.y) < 67 then
          instance.stateProg = 1
          instance.stateTimer = 1
        end
      elseif instance.stateProg == 1 then
        if instance.stateTimer == 0 then
          instance.body:setLinearVelocity(0, 0)
          instance.stateProg = 2
          instance.stateTimer = 0.5
        else
          instance.body:setLinearVelocity(100*math.sin(instance.stateTimer * 100), 0)
        end
      elseif instance.stateProg == 2 then
        if instance.stateTimer == 0 then
          instance.stateProg = 3
          instance.image_index_override = nil
          for _ = 1, 25 do
            local explInst = {
              x = love.math.random(-24, 10) + (instance.x or instance.xStart),
              y = love.math.random(-25, 29) + (instance.y or instance.yStart),
              layer = instance.layer,
              explosionSpeed = 0.2
            }
            expl.commonExplosion(explInst, im.spriteSettings.bushDestruction, {"Effects/Oracle_Bush_Cut"})
          end
        end
      elseif instance.stateProg == 3 then
        -- init
        if instance.stateProgChange then
          instance.wingTimer = 0
          instance.wingTimerSpeedFactor = 1
          instance.wingFlaps = 0
          instance.mouthTimer = 2
        end

        instance.wingTimer = instance.wingTimer + dt * instance.wingTimerSpeedFactor

        -- determine animation state
        if instance.wingTimer > 0.5 then
          instance.wingTimer = 0
          if instance.animationState.wings == "wingsClosed" then
            instance.animationState.wings = "wingsOpen"
          else instance.animationState.wings = "wingsClosed" end
        end

        -- Apply effects of animation state
        if instance.animationState.wings == "wingsClosed" and instance.animationState.wings ~= instance.animStatePrev.wings then
          snd.play(glsounds.dragonWingFlap)
          instance.wingFlaps = instance.wingFlaps + 1
        end

        if instance.wingFlaps < 3 and instance.animationState.wings == "wingsClosed" then
          instance.zo = instance.zo - dt * 40
        end

        if instance.wingFlaps > 2 then
          instance.wingTimerSpeedFactor = 2
          instance.mouthTimer = instance.mouthTimer - dt
        end
        if instance.mouthTimer < 0.45 then
          instance.animationState.mouth = "mouthOpen"
        elseif instance.mouthTimer < 0.60 then
          instance.animationState.mouth = "mouthHalfOpen"
        elseif instance.mouthTimer < 0.75 then
          instance.animationState.mouth = "mouthClosed"
        end

        if instance.wingFlaps > 7 then
          instance.stateProg = 4
        end

        if instance.animationState.mouth == "mouthOpen" and instance.animationState.mouth ~= instance.animStatePrev.mouth then
          snd.play(glsounds.dragonRoar)
        end

      elseif instance.stateProg == 4 then
        if instance.stateProgChange then
          instance.stateTimer = 1.5
          instance.wingTimer = 0
        end
        instance.zo = instance.zo - dt * 200

        instance.wingTimer = instance.wingTimer + dt * 4

        -- determine animation state
        if instance.wingTimer > 1 then
          instance.wingTimer = 0
          if instance.animationState.wings == "wingsClosed" then
            instance.animationState.wings = "wingsOpen"
          else instance.animationState.wings = "wingsClosed" end
        end

        -- Apply effects of animation state
        if instance.animationState.wings == "wingsClosed" and instance.animationState.wings ~= instance.animStatePrev.wings then
          snd.play(glsounds.dragonWingFlap)
          instance.wingFlaps = instance.wingFlaps + 1
        end

        if instance.stateTimer == 0 then
          instance.stateProg = 5
        end
      end

      instance.stateProgChange = preStateProg ~= instance.stateProg
    end,
    start_state = function(instance, dt)
      instance.image_index_override = 20
      instance.animationState = {
        wings = "wingsOpen",
        mouth = "mouthHalfOpen",
        legs = "inTheAir"
      }
      instance.stateTimer = 0
      instance.stateProg = 0
      instance.cutscene = true
      -- dragonWingFlap
    end,
    check_state = function(instance, dt)
      if instance.stateProg == 5 then
        instance.state:change_state(instance, dt, "offscreen")
      end
    end,
    end_state = function(instance, dt)
      instance.cutscene = false
      game.room.music_info = "SoMBelieveinVictory"
      snd.bgmV2.getMusicAndload()
      instance.offscreenTime = 0
    end
  },

  offscreen = {
    run_state = function(instance, dt)
      instance.offscreenTime = instance.offscreenTime - dt
      if instance.offscreenTime < 0 then instance.offscreenTime = 0 end
    end,
    start_state = function(instance, dt)
      instance.body:setPosition(-444, -444)
      instance.zo = -444

      -- Randomly determine next pattern and time until next pattern
      instance.pattern = u.chooseFromWeightTable{
        -- {weight = 1, value = "manyjump"},
        {weight = 1, value = "charge"}
      }
      if not instance.offscreenTime then
        instance.offscreenTime = love.math.random() * 2 + 0.5
      end
    end,
    check_state = function(instance, dt)
      if instance.offscreenTime == 0 then
        instance.state:change_state(instance, dt, instance.pattern)
      end
    end,
    end_state = function(instance, dt)
      instance.offscreenTime = nil
    end
  },

  charge = {
    run_state = function(instance, dt)
      local prevSubstate = instance.substate

      local prevStateTimer = instance.stateTimer
      instance.stateTimer = instance.stateTimer - dt
      if instance.stateTimer < 0 then instance.stateTimer = 0 end

      if instance.substate == 0 then
        if prevStateTimer >= 1 and instance.stateTimer < 1 or
        prevStateTimer >= 0.9 and instance.stateTimer < 0.9 or
        prevStateTimer >= 0.3 and instance.stateTimer < 0.3 or
        prevStateTimer >= 0.2 and instance.stateTimer < 0.2
        then
          snd.play(glsounds.dragonWingFlap)
        end
        if instance.stateTimer == 0 then instance.substate = 1 end
      elseif instance.substate == 1 then
        instance.zo = instance.zo + dt * 400
        if instance.zo >= 0 then
          instance.zo = 0
          snd.play(glsounds.bigBoom)
          gsh.newShake(mainCamera, "displacement", 2)
          instance.substate = 2
          if pl1 and pl1.exists and pl1.zo == 0 then
            pl1.zvel = 120
          end
        end
      elseif instance.substate == 2 then
        if instance.substateChanged then
          instance.image_index_override = 18
        end
      end

      instance.substateChanged = prevSubstate ~= instance.substate
    end,
    start_state = function(instance, dt)
      instance.animationState.wings = "wingsOpen"
      instance.animationState.mouth = "mouthClosed"
      instance.animationState.legs = "inTheAir"

      instance.substate = 0
      instance.stateTimer = 1

      local chx = instance.target.x
      local chy = instance.target.y

      local distFromPl = 100
      local middle = game.room.width * 0.5
      if math.abs(chx + distFromPl - middle) > math.abs(chx - distFromPl - middle) and chx - distFromPl > 0 then
        instance.x = chx - distFromPl
      else
        instance.x = chx + distFromPl
      end
      instance.y = chy
      instance.body:setPosition(instance.x, instance.y)
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
    end
  },

  manyjump = {
    run_state = function(instance, dt)
      instance.t = instance.t + dt
      if instance.t > instance.tmax then instance.t = instance.tmax end

      local prevSubstate = instance.substate

      if instance.substate == 0 then
        instance.subtimer = 0
        instance.substate = 1
        instance.animationState.wings = "wingsOpen"
        instance.animationState.mouth = "mouthOpen"
        instance.animationState.legs = "inTheAir"
      elseif instance.substate == 1 then
        local prevsubtimer = instance.subtimer
        instance.subtimer = instance.subtimer + dt
        if instance.subtimer > 1 then
          instance.subtimer = 1
          instance.body:setPosition(instance.xjump, instance.yjump - instance.shadowHeightMod)
          instance.zo = instance.zo + 200 * dt
          if instance.zo < -200 then
            instance:lookAtTarget()
          end
          if instance.zo >=0 then
            instance.zo = 0
            instance.substate = 4
          end
        else
          if prevsubtimer < 0.9 and instance.subtimer >= 0.9 or
          prevsubtimer < 0.6 and instance.subtimer >= 0.6 or
          prevsubtimer < 0.3 and instance.subtimer >= 0.3 then
            snd.play(glsounds.dragonWingFlap)
          end
        end
      elseif instance.substate == 2 then
        -- set up substate 3 so I will jump on player at exactly tmax
        instance.substate = 3
        instance.animationState.wings = "wingsClosed"
        instance.animationState.mouth = "mouthOpen"
        instance.animationState.legs = "inTheAir"
        instance:lookAtTarget()
        instance.t = 0
        instance.zstart = instance.zo
        -- (3) => zvelinit = - 0.5 * g * tmax - zo / tmax
        instance.zvelinit = - 0.5 * instance.g * instance.tmax - instance.zstart / instance.tmax
        instance.xjump = instance.x
        instance.yjump = instance.y
        instance.vxjump = (instance.target.x - instance.xjump) / instance.tmax
        instance.vyjump = (instance.target.y - instance.shadowHeightMod - instance.yjump) / instance.tmax
      elseif instance.substate == 3 then
        local prevZo = instance.zo
        instance.zo = instance.t * (0.5 * instance.g * instance.t + instance.zvelinit) + instance.zstart

        if prevZo < instance.zo then
          instance.animationState.wings = "wingsOpen"
        end

        instance.body:setPosition(instance.xjump + instance.vxjump * instance.t, instance.yjump + instance.vyjump * instance.t)

        if instance.t == instance.tmax then instance.substate = 4 end
      elseif instance.substate == 4 then -- landed
        if instance.substateChanged then
          instance.animationState.wings = "wingsClosed"
          instance.animationState.mouth = "mouthHalfOpen"
          instance.animationState.legs = math.random() < 0.5 and "leftLegUp" or "rightLegUp"
          if pl1 and pl1.exists and pl1.zo == 0 then
            pl1.zvel = 66
          end
          snd.play(glsounds.bigBoom)
          gsh.newShake(mainCamera, "displacement")
          instance.substateTimer = 1
          instance.timesJumped = instance.timesJumped + 1
        end

        if instance.substateTimer == 0 then
          if instance.timesJumped < instance.jumps then
            instance.substate = 2
          else
            instance.substate = 5
          end
          snd.play(glsounds.dragonRoar)
        elseif instance.substateTimer < 0.15 then
          instance.animationState.mouth = "mouthHalfOpen"
        elseif instance.substateTimer < 0.3 then
          instance.animationState.mouth = "mouthClosed"
          instance:lookAtTarget()
        end

        instance.substateTimer = instance.substateTimer - dt
        if instance.substateTimer < 0 then instance.substateTimer = 0 end
      elseif instance.substate == 5 then
        if instance.substateChanged then
          instance.animationState.wings = "wingsOpen"
          instance.animationState.mouth = "mouthOpen"
          instance.animationState.legs = "inTheAir"
        end

        instance.zo = instance.zo - dt * 200
      end

      instance.substateChanged = instance.substate ~= prevSubstate
    end,
    start_state = function(instance, dt)
      instance.t = 0
      instance.substate = 0
      instance.zmax = -500
      -- z = 0.5 * g * t ^ 2 + zvelinit * t + zo (1)
      -- if v is constant
      -- s = v * t : s = displacement : v = (target - start) / tmax =>
      -- x = xo + vx * t
      -- y = yo + vy * t

      -- use above equations to find gravity for desired t
      instance.tmax = 1.5
      -- let zo be 0 =>
      -- (1) highpoint => zmax = 0.5 * g * thalf ^ 2 + zvelinit * thalf + 0 (2)
      -- (1) lowpoint => 0 = 0.5 * g * tmax ^ 2 + zvelinit * tmax + 0 (3)
      -- (3) => 0 = g * tmax / 2 + zvelinit => zvelinit = g * tmax / 2 (4)
      -- (2) => zmax / thalf = g * (zmax / 2) * 0.5 + zvelinit
      -- => zmax / thalf = zvelinit * 3 / 2 =>
      -- => zvelinit = (2 * zmax) / (3 * thalf) =>
      -- => zvelinit = zmax / (3 * tmax)
      -- (4) => g = zvelinit * 2 / tmax
      -- => g = (zmax / (3 * tmax)) * (2 / tmax)
      -- => g = ( 2 * zmax) / (3 * tmax ^ 2)
      -- the above is the magnitude. Sign it to make it point down
      instance.g = -(2 * instance.zmax) / (3 * instance.tmax ^ 2)
      instance.zo = -400
      instance.xjump = instance.target.x
      instance.yjump = instance.target.y
      instance.jumps = love.math.random(2, 5)
      instance.timesJumped = 0
    end,
    check_state = function(instance, dt)
      if instance.zo < -400 and instance.substate == 5 then
        instance.state:change_state(instance, dt, "offscreen")
      end
    end,
    end_state = function(instance, dt)
    end
  },
}

local Boss3 = {}

function Boss3.initialize(instance)
  instance.flying = true -- can go through walls
  instance.sprite_info = im.spriteSettings.boss3
  instance.image_index = 20
  instance.zo = 0
  instance.bombGoesThrough = true
  instance.undamageable = true
  instance.controlledFlight = true
  instance.grounded = false
  instance.unpushable = true
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.hp = 20
  instance.bombsplosionDamageMod = 1 / 4
  instance.sounds = snd.load_sounds({
    hitSound = {"Effects/Oracle_Boss_Hit"},
    fatalHit = {"Effects/Oracle_Boss_Die"},
  })
  instance.layer = pl1 and pl1.layer or 20
  instance.physical_properties.shape = ps.shapes.bosses.boss3.body
  instance.spritefixture_properties.shape = ps.shapes.bosses.boss3.sprite
  instance.spriteOffset = 25
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.animationState = {
    wings = "wingsOpen",
    mouth = "mouthClosed",
    legs = "inTheAir"
  }
  instance.animStatePrev = {}
  instance.mouth = {
    x = 0,
    y = 0
  }
  instance.lookingRight = false
  -- instance.shadowHeightMod = -2
end

Boss3.functions = {
  load = function (self)
    self.shadowHeightMod = self.sprite.height * 0.5 - 8
  end,

  fire = function (self, accuracyRadius, target)
    local fireball = proj:new{
      layer = self.layer + 1,
      xstart = self.mouth.x, ystart = self.mouth.y,
      notBreakableByMissile = true,
      dpDeflectable = false,
      dragonFire = true,
      sprite_info = im.spriteSettings.dragonFire,
      target = target or self.target
    }
    o.addToWorld(fireball)
    snd.play(glsounds.dragonRoar)
  end,

  lookAtTarget = function (self)
    if self.target and self.target.x and self.x < self.target.x then
      self.lookingRight = true
    else
      self.lookingRight = false
    end
  end,

  touchedByBombsplosion = function (self, other, myF, otherF)
    if self.cutscene then return end
    if self.zo < -25 then return end

    self.lastHit = "bombsplosion"
    self.shieldDown = true
    ebh.damagedByHit(self, other, myF, otherF)
    self.shieldDown = false
  end,

  enemyUpdate = function (self, dt)
    self.animStatePrev.wings = self.animationState.wings
    self.animStatePrev.mouth = self.animationState.mouth
    self.animStatePrev.legs = self.animationState.legs

    -- Get tricked by decoy
    self.target = session.decoy or pl1

    if self.invulnerable then
    else
      -- do stuff depending on state
      local state = self.state
      state.states[state.state].check_state(self, dt)
      state.states[state.state].run_state(self, dt)

      -- determine image index
      if not self.image_index_override then
        self.image_index = animationTable:getStateIndex(self.animationState)
      else
        self.image_index = self.image_index_override
      end

      self.x_scale = self.lookingRight and -1 or 1
      -- determine mouth position from image index and side
      self.mouth.x = self.x - 20 * self.x_scale
      if self.animationState.legs == "inTheAir" then
        self.mouth.y = self.y + self.zo - 12
      else
        self.mouth.y = self.y + self.zo + 4
      end
    end

    -- determine components
    if self.cutscene then
      self.goThroughPlayer = true
      self.harmless = true
      self.attackDodger = true
      self.pushback = false
      self.ballbreaker = false
    elseif self.zo < 0 then
      self.goThroughPlayer = true
      self.harmless = true
      self.attackDodger = true
      self.pushback = false
      self.shielded = false
      self.shieldWall = false
      self.ballbreaker = false
    else
      self.goThroughPlayer = false
      self.harmless = false
      self.attackDodger = false
      self.pushback = true
      self.shielded = true
      self.shieldWall = true
      self.ballbreaker = true
    end

    sh.handleShadow(self)
  end,

  -- draw = function (self)
  --
  --   -- Draw enemy the default way
  --   et.functions.draw(self)
  --
  --   -- love.graphics.circle("fill", self.mouth.x, self.mouth.y, 2)
  --
  --   love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
  --   love.graphics.polygon("line", self.spritebody:getWorldPoints(self.spritefixture:getShape():getPoints()))
  -- end,
}

function Boss3:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Boss3, instance, init) -- add own functions and fields
  return instance
end

return Boss3
