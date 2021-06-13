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
local sm = require "state_machine"
local gsh = require "gamera_shake"

local dlgCtrl = require "GameObjects.DialogueBubble.DialogueControl"
local cd = require "GameObjects.DialogueBubble.controlDefaults"

local dc = require "GameObjects.Helpers.determine_colliders"

local shdrs = require "Shaders.shaders"
local deathShader = shdrs.bossDeathShader

local chainLink = require "GameObjects.bosses.boss4.chainLink"

local states = {
  -- WARNING STARTING STATE IN INITIALIZE!!!
  start = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if true then
        instance.state:change_state(instance, dt, "attach")
      end
    end,
    end_state = function(instance, dt)
    end
  },

  none = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
    end
  },

  contract = {
    run_state = function(instance, dt)
      local chx, chy = instance.creator:getHandPosition()
      local r, th = u.cartesianToPolar(chx - instance.x, chy - instance.y)
      local speed = 200

      instance.body:setLinearVelocity(u.polarToCartesian(speed, th))

      local rfactor = r / instance.initcontractr
      rfactor = (rfactor == rfactor) and rfactor or 0 -- check if nan
      instance.zo = rfactor * instance.initcontractzo + instance.creator.zo

      if r <= 1.2 * speed * dt then
        instance.contractToAttach = true
      end
    end,
    start_state = function(instance, dt)
      local chx, chy = instance.creator:getHandPosition()
      instance.initcontractr = u.cartesianToPolar(chx - instance.x, chy - instance.y)
      instance.initcontractzo = instance.zo
    end,
    check_state = function(instance, dt)
      if instance.contractToAttach then
        instance.state:change_state(instance, dt, "attach")
      end
    end,
    end_state = function(instance, dt)
      instance.contractToAttach = false
      instance.zo = instance.creator.zo
    end
  },

  attach = {
    run_state = function(instance, dt)
      local chx, chy = instance.creator:getHandPosition()

      instance.body:setLinearVelocity(0, 0)
      instance.body:setPosition(chx, chy)
      instance.zo = instance.creator.zo
    end,
    start_state = function(instance, dt)
      instance.attached = true
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
      instance.attached = false
    end
  },

  swing = {
    run_state = function(instance, dt)
      local speed = 250
      local maxdist = 100
      local anchorx, anchory = instance.creator:getHandPosition(instance.startHandIndex)

      -- instance.r = math.abs(math.sin(instance.t * 0.5) * maxdist)
      instance.r = math.sin(instance.t * 0.5) * maxdist
      if instance.r < 0 then
        instance.r = 0
        instance.swingDone = true
      end
      instance.th = instance.r > 2 and instance.th + instance.rotDir * dt * speed / instance.r or instance.th

      local x, y = u.polarToCartesian(instance.r, instance.th)

      instance.body:setPosition(anchorx + x, anchory + y)

      instance.t = instance.t + dt
    end,
    start_state = function(instance, dt)
      instance.startHandIndex = instance.creator.image_index
      instance.th = ((love.math.random() < 0.5) and 1 or -1) * love.math.random() * math.pi
      instance.rotDir = (love.math.random() < 0.5) and 1 or -1
      instance.t = 0
    end,
    check_state = function(instance, dt)
      if instance.swingDone then
        instance.state:change_state(instance, dt, "swing")
      end
    end,
    end_state = function(instance, dt)
      instance.startHandIndex = nil
      instance.swingDone = nil
      instance.r = nil
      instance.th = nil
      instance.rotDir = nil
      instance.t = nil
      instance.repeatSwing = nil
    end
  },

  bounceAround = {
    run_state = function(instance, dt)
      if pl1 and pl1.exists and pl1.zo >= 0 then
        -- get future position of some moments later
        local x, y = instance.body:getPosition()
        local vx, vy = instance.body:getLinearVelocity()
        local secs = 0.25
        local fx, fy = u.polarToCartesian(u.cartesianToPolar(x + vx * secs, y + vy * secs))

        local xn = pl1.fixture:getShape():rayCast(x, y, fx, fy, 1, pl1.x, pl1.y, 0)

        if xn then
          instance:toggleSpikes(true)
        end
      end
    end,
    start_state = function(instance, dt)
      instance.fixture:setRestitution(1)
      instance.direction = instance.direction or love.math.random() * 2 * math.pi - math.pi
      instance.launchspeed = instance.launchspeed or 90 or love.math.random(70, 90)
      instance:launch()
    end,
    check_state = function(instance, dt)
      if instance.spikedup then
        instance.state:change_state(instance, dt, "spikedcharge")
      end
    end,
    end_state = function(instance, dt)
      instance.fixture:setRestitution(0)
      instance.direction = nil
      instance.launchspeed = nil
    end
  },

  spikedcharge = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
    end,
    end_state = function(instance, dt)
    end
  },

  grabchance = {
    run_state = function(instance, dt)
      instance.body:setLinearVelocity(0, 0)
      instance.timer = instance.timer - dt
      if instance.timer <= 0 then
        instance.timer = 0
        instance:toggleSpikes(false)
      end
    end,
    start_state = function(instance, dt)
      instance.timer = 1
    end,
    check_state = function(instance, dt)
      if pl1 and pl1.exists and pl1.grippedOb == instance then
        instance.state:change_state(instance, dt, "grabbed")
      end
    end,
    end_state = function(instance, dt)
      instance.timer = nil
    end
  },

  grabbed = {
    run_state = function(instance, dt)
    end,
    start_state = function(instance, dt)
    end,
    check_state = function(instance, dt)
      if not (pl1 and pl1.exists and pl1.grippedOb == instance) then
        instance.state:change_state(instance, dt, "none")
      end
    end,
    end_state = function(instance, dt)
      instance.harmlesstime = 0.5
    end
  },
}

local WreckingBall = {}

function WreckingBall.initialize(instance)
  instance.goThroughEnemies = true
  instance.grounded = true
  instance.canBeBullrushed = false
  instance.canBeRolledThrough = false
  instance.canLeaveRoom = true
  instance.shielded = true
  instance.shieldWall = true
  instance.sprite_info = im.spriteSettings.boss4
  instance.physical_properties.shape = ps.shapes.circleThreeFourths
  instance.sounds = snd.load_sounds{
    chainSizeChange = {"Effects/OOA_SwitchHook_Loop"}
  }
  instance.chain = {}
  instance.state = sm.new_state_machine(states)
  instance.state.state = "start"
  instance.spike_index = 0
  instance.spike_anim_speed = 0
end

WreckingBall.functions = {

  -- dialogue stuff
  handleHookReturn = function (self)
    if self.speak then
      self.speak = false
      self.spoke = true
      self.content = "HAIL THE EMPIRE!"
      self.bubbleOffsetX = 5 + (self.creator.x - self.x)
      self.bubbleOffsetY = 9
      self.ssbRGBA = self.creator.ssbRGBA

      self.dlgState = "talking"
    elseif self.spoke then
      self.spoke = false

      self.dlgState = "done"
    end
  end,

  determineUpdateHook = function (self)
    if self.dlgState == "done" then
      cd.cleanSsb(self)
      self.updateHook = u.emptyFunc
    elseif self.dlgState == "talking" then
      -- self.blockInput = true
      self.updateHook = cd.singleSimpleInteractiveBubble
    end
  end,
  -- end dialogue stuff

  toggleSpikes = function (self, bool)
    self.spikedup = bool
    if bool then
      self.spike_anim_speed = 5
    else
      self.spike_anim_speed = -5
    end
  end,

  determineComponents = function (self)
    if self.state.state == "grabchance" or
    self.state.state == "grabbed" then
      self.unpushable = false
      self.harmless = true
    else
      self.unpushable = true
      self.harmless = false
    end
    if self.zo < 0 then
      self.attackDodger = true
      self.goThroughPlayer = true
      self.pushback = false
      self.ballbreaker = false
      self.harmless = true
    else
      self.attackDodger = false
      self.goThroughPlayer = false
      self.pushback = true
      self.ballbreaker = true
    end
    if self.creator.state.state == "swing" then
      self.flying = true
      self.levitating = false

      self.attackDmg = 3
      self.explosive = true
      self.impact = 25
      self.blowUpForce = 130
    elseif self.state.state == "bounceAround" or self.state.state == "spikedcharge" then
      self.flying = false
      self.levitating = true

      self.attackDmg = 3
      self.explosive = true
      self.impact = 5
      self.blowUpForce = 130
    else
      self.flying = false
      self.levitating = true

      self.attackDmg = 2
      self.explosive = false
      self.impact = nil
      self.blowUpForce = nil
    end
    if self.spikedup then
      self.attackDmg = self.attackDmg + 1
    end
    if self.harmlesstime then
      self.harmless = true
    end
  end,

  stopState = function (self)
    if self.state.state == "none" then return end
    self.state:change_state(self, 1, "none")
  end,

  contract = function (self)
    if self.state.state == "contract" or self.state.state == "attach" then return end
    self.state:change_state(self, 1, "contract")
  end,

  swing = function (self)
    if self.state.state == "swing" then return end
    self.state:change_state(self, 1, "swing")
  end,

  bounceAround = function (self, launchspeed, direction)
    self.launchspeed = launchspeed
    self.direction = direction
    self.state:change_state(self, 1, "bounceAround")
  end,

  updateChain = function (self)
    if self.attached then
      for j = 1, #self.chain do
        o.removeFromWorld(self.chain[j]);
        self.chain[j] = nil;
      end
      return
    end

    local crhx, crhy = self.creator:getHandPosition()
    crhy = crhy + self.creator.zo

    local r, th = u.cartesianToPolar(self.x - crhx, self.y + self.zo - crhy)
    local i = 0
    for dist = 8, r - 8, 8 do
      i = i + 1
      if not self.chain[i] then
        self.chain[i] = chainLink:new{
          layer = self.layer, creator = self,
          xstart = self.x, ystart = self.y,
          x = self.x, y = self.y
        }
        o.addToWorld(self.chain[i])
      end
      self.chain[i].targetx, self.chain[i].targety =
        u.polarToCartesian(dist, th)
      self.chain[i].targetx, self.chain[i].targety =
        self.chain[i].targetx + crhx, self.chain[i].targety + crhy

      -- Determine if chain link is airborne
      local finalzo = (self.creator.zo or 0) + (self.zo - self.creator.zo) * dist / (r - 8)
      if finalzo < 0 then
        self.chain[i].high = true
      else
        self.chain[i].high = false
      end
    end
    for j = i + 1, #self.chain do
      o.removeFromWorld(self.chain[j]);
      self.chain[j] = nil;
    end

    if self.prevChainSize and i ~= self.prevChainSize then
      snd.play(self.sounds.chainSizeChange)
    end

    self.prevChainSize = i
  end,

  launch = function (self)
    self.body:setLinearVelocity(u.polarToCartesian(self.launchspeed, self.direction))
  end,

  emote = function (self, emotion)
    if self.emotion == emotion then return end
    self.emotion = emotion
    self.emotion_anim_speed = nil
    self.emotion_frames = nil
    self.emotion_index = nil
    if emotion == "confusion" then
      self.image_index = 0
    elseif emotion == "neutral" then
      self.image_index = 1
    elseif emotion == "ready" then
      self.image_index = 2
    elseif emotion == "crazy" then
      self.image_index = 3
    elseif emotion == "cruel" then
      self.image_index = 4
    elseif emotion == "mania" then
      self.image_index = 5
    elseif emotion == "madlaugh" then
      self.emotion_frames = {4, 5}
      self.emotion_anim_speed = 3
      self.emotion_index = 0
    elseif emotion == "fear" then
      self.emotion_frames = {6, 7}
      self.emotion_anim_speed = 3
      self.emotion_index = 0
    end
  end,

  load = function (self)
    dlgCtrl.functions.load(self)
    self.sprite = im.sprites["Bosses/boss4/wreckingBall"]
  end,

  enemyUpdate = function (self, dt)
    dlgCtrl.functions.update(self, dt)
    if not self.creator or not self.creator.exists then return o.removeFromWorld(self) end
    if self.creator.hp <= 0 then
      self.harmless = true
      self.dying = true
      self.myShader = deathShader
      self.body:setLinearVelocity(0, 0)
      return
    end

    -- do stuff depending on state
    local state = self.state
    state.states[state.state].check_state(self, dt)
    state.states[state.state].run_state(self, dt)

    -- Determine spike index
    self.spike_index = self.spike_index + dt * self.spike_anim_speed
    if self.spike_index > 2 then self.spike_index = 2 end
    if self.spike_index < 0 then self.spike_index = 0 end

    self:determineComponents()

    if self.harmlesstime then
      self.harmlesstime = self.harmlesstime - dt
      if self.harmlesstime <= 0 then self.harmlesstime = nil end
    end

    -- animate
    if self.emotion_frames then
      self.emotion_index = self.emotion_index + dt * self.emotion_anim_speed
      if self.emotion_index >= 1 then
        self.emotion_index = 0
      end
      self.image_index = self.emotion_frames[math.floor(self.emotion_index * #self.emotion_frames) + 1]
    end

    self:updateChain()
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

  hitPlayer = function (self, other)
    if other.zo < 0 or self.zo < 0 then return end
    if self.state.state == "grabchance" or self.state.state == "grabbed" then return end
    self:toggleSpikes(true)
    self:emote("madlaugh")
  end,

  hitSolidStatic = function (self, other, myF, otherF)
    if self.state.state == "spikedcharge" then
      self.body:setLinearVelocity(0, 0)
      self.state:change_state(self, 1, "grabchance")
      snd.play(glsounds.smallBoom)
      gsh.newShake(mainCamera, "displacement")
      self:emote("mania")
    elseif self.state.state == "bounceAround" then
      snd.play(glsounds.boing)
      gsh.newShake(mainCamera, "displacement", 0.2)
    end
  end,

  endContact = function (self, a, b, coll, aob, bob)
    if not a:isSensor() and not b:isSensor() and coll:isEnabled() and self.state.state == "bounceAround" then
      -- restitution doesn't result in a perfect elastic bounce, so fix here
      -- Also gets called when touching other enemy or player but doesn't matter
      self._, self.direction = u.cartesianToPolar(self.body:getLinearVelocity())
      self:launch()
    end
  end,

  draw = function (self)

    -- Draw enemy the default way
    et.functions.draw(self)

    -- Draw spikes
    if self.spike_index and math.floor(self.spike_index) > 0 then

      local zo = self.zo or 0
      local xtotal, ytotal = self.x, self.y + zo

      local sprite = im.sprites["Bosses/boss4/spikes"]
      local frame = sprite[math.floor(self.spike_index) - 1]

      local worldShader = love.graphics.getShader()
      love.graphics.setShader(self.myShader)
      love.graphics.draw(
      sprite.img, frame, xtotal, ytotal, self.angle,
      self.x_scale * sprite.res_x_scale, self.y_scale * sprite.res_y_scale,
      sprite.cx, sprite.cy)
      love.graphics.setShader(worldShader)
    end

    -- love.graphics.polygon("line", self.body:getWorldPoints(self.fixture:getShape():getPoints()))
    -- love.graphics.circle("line", self.x, self.y, self.fixture:getShape():getRadius())
  end,
}

function WreckingBall:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(dlgCtrl, instance) -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(WreckingBall, instance, init) -- add own functions and fields
  return instance
end

return WreckingBall
