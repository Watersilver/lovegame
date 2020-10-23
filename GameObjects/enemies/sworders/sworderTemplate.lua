local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local td = require "movement"; td = td.top_down
local sh = require "GameObjects.shadow"
local sm = require "state_machine"
local u = require "utilities"
local o = require "GameObjects.objects"

local eSword = require "GameObjects.enemies.sworders.enemySword"

local function getTargetPos(self, target)
  local dk = self.distanceKept

  if not target.invulnerable and target.speed and target.speed > 10 then
    return u.getPosAndSideInFrontOfMovingObj(dk, self.x, self.y, target.x, target.y, target.vx, target.vy)
  else
    return u.getClosePosAndSide(dk, self.x, self.y, target.x, target.y)
  end
end

local function getTargetingFacing(self, target)
  local diffx = target.x - self.x
  local diffy = target.y - self.y
  if math.abs(diffx) > math.abs(diffy) then
    if diffx > 0 then
      return "right"
    else
      return "left"
    end
  else
    if diffy > 0 then
      return "down"
    else
      return "up"
    end
  end
end

local function setSpriteFromFacing(self)
  if self.facing ~= "right" then
    self.sprite = im.sprites[self.spritePathNoFacing .. self.facing]
    self.x_scale = 1
  else
    self.sprite = im.sprites[self.spritePathNoFacing .. "left"]
    self.x_scale = -1
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
      instance.state:change_state(instance, dt, "walking")
    end,
    end_state = function(instance, dt)
    end
  },

  walking = {
    run_state = function(instance, dt)
      instance.stateTimer = instance.stateTimer - dt

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
      setSpriteFromFacing(instance)
      instance.image_speed = instance.walkingImage_speed
      instance.normalisedSpeed = instance.walkSpeedMod
      instance.stateTimer = u.chooseFromWeightTable(instance.walkDurations)
    end,
    check_state = function(instance, dt)
      if instance.triggers.swordRecoil then
        instance.state:change_state(instance, dt, "recoil")
      elseif instance.knowsPlayerPos > 0 then
        instance.state:change_state(instance, dt, instance:getDetectPlayerReaction())
      elseif instance.stateTimer <= 0 then
        if instance.walkAndStop then
          instance.state:change_state(instance, dt, "standing")
        else
          instance.state:change_state(instance, dt, "walking")
        end
      end
    end,
    end_state = function(instance, dt)
      instance.image_speed = 0
    end
  },

  standing = {
    run_state = function(instance, dt)
      instance.stateTimer = instance.stateTimer - dt

      -- movement behaviour
      td.stand_still(instance)
    end,
    start_state = function(instance, dt)
      instance.stateTimer = u.chooseFromWeightTable(instance.stillDurations)

      instance.image_speed = 0
      instance.image_index = 0
    end,
    check_state = function(instance, dt)

      if instance.triggers.swordRecoil then
        instance.state:change_state(instance, dt, "recoil")
      elseif instance.knowsPlayerPos > 0 then
        instance.state:change_state(instance, dt, instance:getDetectPlayerReaction())
      elseif instance.stateTimer <= 0 then
        instance.state:change_state(instance, dt, "walking")
      end
      -- Can change to shooting state
      -- or to waking state
    end,
    end_state = function(instance, dt)
    end
  },

  runAway = {
    run_state = function(instance, dt)
      instance.image_speed = instance.speed * 0.002
      instance.runAwayTimer = instance.runAwayTimer - dt
      if not instance.target then return end
      if not instance.target.x then return end
      if instance.fearless then return end

      local _, dir = u.cartesianToPolar(instance.x - instance.target.x, instance.y - instance.target.y)
      instance.direction = dir

      instance.facing = getTargetingFacing(instance.target, instance)

      setSpriteFromFacing(instance)

      td.analogueWalk(instance, dt)

      if instance.zo == 0 and instance.zvel == 0 then
        instance.timeOnGround = instance.timeOnGround + dt
        if instance.timeOnGround > 0 then
          instance.zvel = 50
          instance.timeOnGround = 0
        end
      end
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0
      instance.image_index = 0
      instance.normalisedSpeed = 1
      instance.timeOnGround = 0
      instance.runAwayTimer = 2.5
    end,
    check_state = function(instance, dt)
      if instance.runAwayTimer <= 0 or instance.fearless then
        instance.state:change_state(instance, dt, "standing")
      elseif instance.triggers.swordRecoil then
        instance.state:change_state(instance, dt, "recoil")
      end
    end,
    end_state = function(instance, dt)
      instance.timeOnGround = nil
      instance.runAwayTimer = nil
    end
  },

  positionSelf = {
    run_state = function(instance, dt)
      instance.image_speed = instance.speed * 0.002
      if not instance.target then return end
      if not instance.target.x then return end

      local tarx, tary, targetingSide = getTargetPos(instance, instance.target, instance.targetingSide)

      local _, dir = u.cartesianToPolar(tarx, tary)
      instance.direction = dir

      instance.facing = getTargetingFacing(instance, instance.target)

      setSpriteFromFacing(instance)

      if u.magnitude2d(tarx, tary) > 2 then
        td.analogueWalk(instance, dt)
      else
        td.stand_still(instance, dt)
      end

      if u.distance2d(instance.target.x, instance.target.y, instance.x, instance.y) < instance.distanceKept + 3 then
        instance.chargometer = instance.chargometer + 2 * dt
      else
        instance.chargometer = instance.chargometer - dt
        if instance.chargometer < 0 then instance.chargometer = 0 end
      end

      if instance.jump and instance.zo == 0 and instance.zvel == 0 then
        instance.timeOnGround = instance.timeOnGround + dt
        if instance.timeOnGround > instance.maxTimeOnGround then
          instance.zvel = instance.jump
          instance.timeOnGround = 0
        end
      end
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0
      instance.image_index = 0
      instance.normalisedSpeed = instance.positionSelfSpeedMod
      instance.chargometer = 0
      instance.chargeLim = u.chooseFromWeightTable{
        {weight = 10, value = 2},
        {weight = 10, value = 1},
        {weight = 2, value = 4},
      }
      instance.timeOnGround = 0
    end,
    check_state = function(instance, dt)
      if instance.knowsPlayerPos == 0 or not instance.mySword then
        instance.state:change_state(instance, dt, "standing")
      elseif instance.chargometer > instance.chargeLim then
        instance.state:change_state(instance, dt, "charge")
      elseif instance.triggers.swordRecoil then
        instance.state:change_state(instance, dt, "recoil")
      end
    end,
    end_state = function(instance, dt)
      instance.timeOnGround = nil
    end
  },

  charge = {
    run_state = function(instance, dt)
      instance.chargeTimer = instance.chargeTimer + dt
      -- instance.image_speed = instance.speed * 0.002
      if instance.speed > 50 then
        instance.image_index = 1
      end
      if not instance.target then return end
      if not instance.target.x then return end

      local _, dir = u.cartesianToPolar(instance.target.x - instance.x, instance.target.y - instance.y)
      instance.direction = dir

      instance.facing = getTargetingFacing(instance, instance.target)

      setSpriteFromFacing(instance)

      td.analogueWalk(instance, dt)
    end,
    start_state = function(instance, dt)
      instance.normalisedSpeed = instance.chargeSpeedMod
      instance.chargeTimer = 0
      instance.image_index = 0
    end,
    check_state = function(instance, dt)
      if not instance.mySword then
        instance.state:change_state(instance, dt, "standing")
      elseif instance.chargeTimer > 0.3 then
        instance.state:change_state(instance, dt, instance:getDetectPlayerReaction())
      elseif instance.triggers.swordRecoil then
        instance.state:change_state(instance, dt, "recoil")
      end
    end,
    end_state = function(instance, dt)
      instance.chargeTimer = nil
    end
  },

  recoil = {
    run_state = function(instance, dt)
      instance.recoilTimer = instance.recoilTimer - dt
      td.stand_still(instance, dt)
    end,
    start_state = function(instance, dt)
      instance.image_speed = 0
      instance.image_index = 1
      instance.recoilTimer = instance.triggers.bigRecoil and 1.25 or 0.75
      instance.knowsPlayerPos = instance.playerPosMemory
      local vx, vy = 0, 0
      local recoilForce = instance.triggers.bigRecoil and 70 or 50
      if instance.facing == "up" then vy = recoilForce
      elseif instance.facing == "down" then vy = -recoilForce
      elseif instance.facing == "left" then vx = recoilForce
      elseif instance.facing == "right" then vx = -recoilForce
      end
      instance.body:setLinearVelocity(vx, vy)
    end,
    check_state = function(instance, dt)
      if instance.triggers.swordRecoil then
        instance.state:change_state(instance, dt, "recoil")
      elseif instance.recoilTimer < 0 then
        instance.state:change_state(instance, dt, instance:getDetectPlayerReaction())
      end
    end,
    end_state = function(instance, dt)
      instance.recoilTimer = nil
    end
  },

}

local SworderTemplate = {}

function SworderTemplate.initialize(instance)
  instance.sprite_info = im.spriteSettings.hoodedSkeleton
  instance.spritePathNoFacing = "Enemies/HoodedSkeleton/walk_"
  instance.maxTimeOnGround = 0
  instance.zo = 0
  instance.zvel = 0
  instance.gravity = 350
  instance.jump = 50
  instance.ballbreakerEvenIfHigh = true
  instance.grounded = true
  instance.unpushable = true
  instance.hp = 10
  instance.maxspeed = 100
  instance.positionSelfSpeedMod = 0.9
  instance.chargeSpeedMod = 1
  instance.walkSpeedMod = 0.3
  instance.layer = 20
  instance.physical_properties.shape = ps.shapes.circleAlmost1
  instance.physical_properties.masks = {PLAYERJUMPATTACKCAT}
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.knowsPlayerPos = 0
  instance.targetingSide = nil -- up, left, down, right
  instance.distanceKept = 32
  instance.walkingImage_speed = 0.1
  instance.walkAndStop = true
  instance.sightWidth = 8
  instance.walkDurations = {
    {weight = 10, value = 1},
    {weight = 20, value = 2},
    {weight = 20, value = 3},
    {weight = 2, value = 6},
  }
  instance.stillDurations = {
    {weight = 10, value = 1},
    {weight = 20, value = 2},
    {weight = 20, value = 3},
    {weight = 2, value = 6},
  }
  instance.playerPosMemory = 2
  instance.gripStrength = 0.85 -- 1 means 100% can hold sword, 0 means 0%
  instance.fearless = true
end

SworderTemplate.functions = {
  enemyLoad = function (self)
    self.facing = "down"
    setSpriteFromFacing(self)
    self.triggers = {}
    self.mySword = eSword:new{
      creator = self,
      x = self.x,
      xstart = self.x,
      y = self.y,
      ystart = self.y,
      layer = self.layer,
      facing = self.facing
    }
    o.addToWorld(self.mySword)

    sh.handleShadow(self)
  end,

  enemyUpdate = function (self, dt)
    -- Get tricked by decoy
    self.target = session.decoy or pl1

    -- Determine target
    if self.facing then
      if self:lookFor(self.target) then
        self.knowsPlayerPos = self.knowsPlayerPos + dt
      else
        self.knowsPlayerPos = self.knowsPlayerPos - dt
      end
    else
      self.knowsPlayerPos = self.knowsPlayerPos - dt
    end
    if self.knowsPlayerPos > self.playerPosMemory or self.invulnerableEnd then self.knowsPlayerPos = self.playerPosMemory end
    if pl1 and pl1.stateTriggers.poof then self.knowsPlayerPos = 0 end
    if not self.mySword and self.fearless then self.knowsPlayerPos = 0 end
    if self.knowsPlayerPos < 0 then self.knowsPlayerPos = 0 end

    -- do stuff depending on state
    local state = self.state
    -- Check animation state
    state.states[state.state].check_state(self, dt)
    -- Run animation state
    state.states[state.state].run_state(self, dt)

    for trig in pairs(self.triggers) do
      self.triggers[trig] = nil
    end

    td.zAxis(self, dt)

    sh.handleShadow(self)
  end,

  getDetectPlayerReaction = function (self)
    return self.mySword and "positionSelf" or "runAway"
  end
}

function SworderTemplate:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(SworderTemplate, instance, init) -- add own functions and fields
  return instance
end

return SworderTemplate
