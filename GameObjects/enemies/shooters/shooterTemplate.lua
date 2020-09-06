-- TODOS check reflex stuff with the random func and think if it's needed

local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sm = require "state_machine"
local o = require "GameObjects.objects"
local u = require "utilities"

local proj = require "GameObjects.enemies.projectile"

local function bulletInit(self, init)
  local mergedInit = {
    xstart = self.x, ystart = self.y,
    attackDmg = self.bulletDmg, layer = self.layer - 1,
    facing = self.facing
  }
  for key, value in pairs(init) do
    mergedInit[key] = value
  end
  return mergedInit
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
        instance.state:change_state(instance, dt, "walking")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  walking = {
    run_state = function(instance, dt)
      instance:updateStateTimer(dt)

      -- Look for player
      instance:lookAndShoot(dt)

      -- Random shot
      instance:randomShotUpdate(dt)

      if instance.speed > 0.1 then
        instance.image_speed = instance.walkingImage_speed
      else
        instance.image_speed = 0
      end

      td.walk(instance, dt)

    end,
    start_state = function(instance, dt)
      -- Determine facing
      instance.facing = ebh.randomize4dir(instance, false, true)
      if instance.facing ~= "right" then
        instance.sprite = im.sprites[instance.spritePathNoFacing .. instance.facing]
        instance.x_scale = 1
      else
        instance.sprite = im.sprites[instance.spritePathNoFacing .. "left"]
        instance.x_scale = -1
      end
      instance.image_speed = instance.walkingImage_speed
      instance:setStateTimer(instance.walkDurations)
    end,
    check_state = function(instance, dt)
      if instance.attacked then
        instance.state:change_state(instance, dt, "damaged")
      elseif instance.stateTimer <= 0 then
        if instance.walkAndStop then
          instance.state:change_state(instance, dt, "standing")
        else
          instance.state:change_state(instance, dt, "walking")
        end
      end
      -- Can change to standing state
      -- or to another walking state
      -- or to damaged state if it exists
    end,
    end_state = function(instance, dt)
      instance.image_speed = 0
    end
  },

  standing = {
    run_state = function(instance, dt)
      instance:updateStateTimer(dt)

      -- Look for player
      instance:lookAndShoot(dt)

      -- Random shot
      instance:randomShotUpdate(dt)

      -- movement behaviour
      td.stand_still(instance)
    end,
    start_state = function(instance, dt)
      instance:setStateTimer(instance.stillDurations)
      if instance.shootStill and not instance.stateTimerStartedAtZero and not instance.shotStanding then
        instance.willShootStanding = love.math.random() < instance.shootStill
      end
      instance.shotStanding = nil

      instance.image_speed = 0
      instance.image_index = 0
    end,
    check_state = function(instance, dt)

      if instance.attacked then
        instance.state:change_state(instance, dt, "damaged")
      elseif instance.stateTimer <= 0 and not instance.shooting then
        if instance.willShootStanding then
          instance.shotStanding = true
          instance.shooting = true
          instance.state:change_state(instance, dt, "standing")
        else
          instance.state:change_state(instance, dt, "walking")
        end
      end
      -- Can change to shooting state
      -- or to waking state
    end,
    end_state = function(instance, dt)
      instance.willShootStanding = nil
    end
  },

  damaged = {
    run_state = function(instance, dt)
      td.stand_still(instance)
    end,
    start_state = function(instance, dt)
      instance.shooting = false
    end,
    check_state = function(instance, dt)
      if instance.invulnerableEnd then
        if instance.walkAndStop then
          instance.state:change_state(instance, dt, u.choose("standing", "walking"))
        else
          instance.state:change_state(instance, dt, "walking")
        end
      end
    end,
    end_state = function(instance, dt)
    end
  },
}


local ShooterTemplate = {}

function ShooterTemplate.initialize(instance)
  instance.layer = 20
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.sightWidth = 8

  -- Shooter differences:
  --  Shoots still or while walking or whenever
  --  Shoots when it sees player or randomly
  --  Shoots one or multiple bullets (define how many bullets and how fast)
  --  Shooting frequency
  --  Bullet speed
  --  Walking speed
  --  Walking And stopping duration
  --  Walks without stopping
  --  Forcemod == 0 or normal
  --  Some have damaged state, some don't
  --  Bullet kinds

  -- Possible Props:
  -- instance.sprite_info = ...
  -- instance.spritePathNoFacing = [path to sprite without the facing]
  -- instance.hp = ...
  -- instance.physical_properties.shape = ...
  -- instance.attackDmg = ...
  -- instance.bulletDmg = ...
  -- instance.shootStill = [chance to shoot while still]
  -- instance.targetPlayer = [do I shoot when player is in my line of sight]
  -- instance.cooldown = [cooldown between shots]
  -- instance.multishoot = number that shows how many shots will be fired.
  -- instance.multishootCooldown = time between each shot in multishot.
  -- instance.avgReactionTime = [how fast after seeing player I'll shoot]
  -- instance.shootRandomly = [shoots completelly randomly]
  -- instance.inBetweenShotDurations = {
  --   {weight = ..., value = ...},
  --   ...
  -- }
  -- instance.walkAndStop = [do I always move, or do I stop between walks?]
  -- instance.walkingImage_speed = ...
  -- instance.walkDurations = {
  --   {weight = ..., value = ...},
  --   ...
  -- }
  -- instance.stillDurations = {
  --   {weight = ..., value = ...},
  --   ...
  -- }
  -- instance.bulletProps = {
  --   [bulletType] = true,
  --   sprite_info = ...
  -- }
  -- instance.shootSound = snd.load_sound{...}
end

ShooterTemplate.functions = {
  enemyLoad = function (self)
    self.cooldown = self.cooldown or 0
    self.nextShotTimer = self.cooldown + 1
    self.secsLookingAtPlayer = 0
    self.avgReactionTime = self.avgReactionTime or 0.5
    self.multishot = self.multishot or 1
    self.mutishotsFired = 0
    self.nextRandomShotTimer = 0 --Won't shoot immediatelly because of nextShotTimer
  end,

  enemyUpdate = function (self, dt)

    -- Get tricked by decoy
    self.target = session.decoy or pl1

    -- cooldown
    self.nextShotTimer = self.nextShotTimer - dt
    if self.nextShotTimer < 0 then self.nextShotTimer = 0 end

    -- Shoot
    if self.shooting then
      self:shoot()
    else
      self.mutishotsFired = 0
    end

    -- do stuff depending on state
    local state = self.state
    -- Check state
    state.states[state.state].check_state(self, dt)
    -- Run state
    state.states[state.state].run_state(self, dt)
  end,

  setStateTimer = function (self, wt)
    self.stateTimer = u.chooseFromWeightTable(wt)
    self.stateTimerStartedAtZero = self.stateTimer <= 0
  end,

  randomShotUpdate = function (self, dt)
    if self.shootRandomly then
      if self.nextRandomShotTimer <= 0 then
        self.shooting = true
        self.nextRandomShotTimer = u.chooseFromWeightTable(self.inBetweenShotDurations)
      else
        if not self.shooting then
          self.nextRandomShotTimer = self.nextRandomShotTimer - dt
        end
      end
    end
  end,

  updateStateTimer = function (self, dt)
    if not self.shooting then
      self.stateTimer = self.stateTimer - dt
    end
  end,

  lookAndShoot = function (self, dt)
    if self.targetPlayer and self.lookFor then
      local sawPlayer = self:lookFor(self.target)
      if sawPlayer then
        if self.secsLookingAtPlayer == 0 then
          -- reaction time is avg +- 20%
          self.reactionTime = self.avgReactionTime + self.avgReactionTime * 0.2 * love.math.random() * u.choose(1, -1)
        end
        self.secsLookingAtPlayer = self.secsLookingAtPlayer + dt
      else
        self.secsLookingAtPlayer = self.secsLookingAtPlayer - dt
        if self.secsLookingAtPlayer < 0 then
          self.secsLookingAtPlayer = 0
          self.reactionTime = nil
        end
      end
      if self.secsLookingAtPlayer > 0 then
        if self.reactionTime < self.secsLookingAtPlayer then
          self.secsLookingAtPlayer = self.reactionTime
          if sawPlayer and self.nextShotTimer == 0 then
            self.shooting = true
          end
        end
      end
    end
  end,

  fireBullet = function (self, isMultishot)
    local bullet = proj:new(bulletInit(self, self.bulletProps))

    o.addToWorld(bullet)

    self.nextShotTimer = self[isMultishot and "multishootCooldown" or "cooldown"]

    if self.shootSound and not u.isOutsideGamera(self, mainCamera) then
      snd.play(self.shootSound)
    end
  end,

  shoot = function (self)
    if self.nextShotTimer == 0 then

      self.mutishotsFired = self.mutishotsFired + 1
      local isMultishot = self.mutishotsFired < self.multishot
      self:fireBullet(isMultishot)
      if not isMultishot then
        self.shooting = false
      end

    end
  end
}

function ShooterTemplate:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(ShooterTemplate, instance, init) -- add own functions and fields
  return instance
end

return ShooterTemplate
