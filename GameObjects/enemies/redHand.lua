local ps = require "physics_settings"
local im = require "image"
local snd = require "sound"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local sh = require "GameObjects.shadow"
local expl = require "GameObjects.explode"
local proj = require "GameObjects.enemies.projectile"
local u = require "utilities"
local o = require "GameObjects.objects"
local game = require "game"
local gsh = require "gamera_shake"
local zAxis = require "movement"; zAxis = zAxis.top_down.zAxis

local dc = require "GameObjects.Helpers.determine_colliders"

local RedHand = {}

function RedHand.initialize(instance)
  instance.sprite_info = im.spriteSettings.redHand
  instance.hp = 11 --love.math.random(3)
  instance.physical_properties.shape = ps.shapes.circle1
  -- instance.physical_properties.categories = {FLOORCOLLIDECAT}
  instance.duration = 3 + love.math.random() * 1
  instance.universalForceMod = 0
  instance.untouchable = true
  instance.giveChase = false -- Chase player
  instance.flying = true
  instance.topHeight = 200
  instance.zo = -instance.topHeight
  instance.zvel = 0
  instance.gravity = 111
  instance.grabRadius = 16
  instance.fallSound = glsounds.blockFall
  instance.grabSound = snd.load_sound{"Effects/Oracle_Boss_Die"}

  -- determine initial facing
  instance.x_scale = u.choose(1, -1)
end

RedHand.functions = {
  enemyLoad = function (self)
    self.timer = 0
    self.grabTimer = 0
    self.initLayer = self.layer

    self:fall(true)
  end,

  fall = function (self)
    self.attackDodger = true
    self.undamageable = true
    self.harmless = true
    self.image_speed = 0
    self.image_index = 0
    snd.play(self.fallSound)
  end,

  land = function (self, dt)
    self.attackDodger = false
    self.undamageable = false
    self.harmless = false
    self.landed = true
    self.image_speed = 0
    self.image_index = 1

    -- If my target isn't the player I can't grab anything
    if not self.target then return end
    if not self.target.player then return end

    -- If I'm not close enough to player to grab them I can't grab
    if u.distance2d(self.x, self.y, self.target.x, self.target.y) > self.grabRadius then return end

    self.grabbedPlayer = self.target.animation_state.state ~= "dontdraw" and self.target.body:getType() == "dynamic" and not self.target.deathState
    if self.grabbedPlayer then
      -- Force land player
      self.target.jo = 0
      self.target.fo = 0
      self.target.zoPrev = 0
      self.target.zo = 0
      self.target.zvel = 0

      self.target.animation_state:change_state(self.target, dt, "dontdraw")
      self.grabbedPlayer = self.target
      self.undamageable = true
    end
  end,

  rise = function (self)
    self.attackDodger = true
    self.undamageable = true
    self.harmless = true
    self.gravity = -self.gravity
    self.image_speed = 0
    self.image_index = 1
    self.rising = true
    self.zvel = 1
  end,

  destroy = function (self)
    self.creator.pause = false
    if not self.rose then self.creator.redHands = self.creator.redHands - 1 end
    self.creator:resetTimer(self.duration - self.timer)
  end,

  enemyUpdate = function (self, dt)
    if self.grabbedPlayer then
      self.body:setLinearVelocity(0, 0)

      if self.grabTimer > 5 then
        self.y_scale = 0
        self.grabbedPlayer.triggers.damaged = 4
        self.grabbedPlayer.triggers.damCounter = 2
        self.grabbedPlayer.jo = - 200
        self.grabbedPlayer.animation_state:change_state(self.grabbedPlayer, dt, "downdamaged")
        game.transition{
          type = "whiteScreen",
          progress = 0,
          roomTarget = self.destination,
          playa = self.grabbedPlayer,
          desx = self.desx,
          desy = self.desy
        }
      elseif self.grabTimer == 0 then
        self.image_speed = 0
        self.image_index = 1
        self.zo = 0
        snd.play(self.grabSound)
      end

      gsh.newShake(mainCamera, "displacement", self.grabTimer, self.grabTimer)

      self.grabTimer = self.grabTimer + dt
    else

      self.target = session.decoy or pl1

      local zPrev = self.zo

      zAxis(self, dt);

      if self.zo == 0 and zPrev ~= 0 then
        self:land(dt)
      end

      -- Timer will work only when red hand is down
      if self.landed then
        if not self.rising then
          -- Check when to rise again
          if self.timer > self.duration then
            self:rise();
          end
          self.timer = self.timer + dt
        else
          if self.zo < -self.topHeight then
            self.rose = true
            o.removeFromWorld(self);
          end
        end
      else

        -- If chase player is true, set position to
        -- target position as long as I'm falling
        if self.giveChase and self.target then
          local dx, dy = self.target.x - self.x, self.target.y - self.y
          local normdx, normdy = u.normalize2d(dx, dy)
          local chaseSpeed = 200
          local xAddend = normdx * chaseSpeed * dt
          local newX = math.abs(dx) > math.abs(xAddend) and self.x + xAddend or self.target.x
          local yAddend = normdy * chaseSpeed * dt
          local newY = math.abs(dy) > math.abs(yAddend) and self.y + yAddend or self.target.y
          self.body:setPosition(newX, newY)
        end
      end

    end

    -- Set layer
    if self.zo == 0 then
      if self.layer ~= 19 then
        o.change_layer(self, 19)
      end
    else
      if self.layer ~= self.initLayer then
        o.change_layer(self, self.initLayer)
      end
    end

    sh.handleShadow(self)
  end,
}

function RedHand:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(RedHand, instance, init) -- add own functions and fields
  return instance
end

return RedHand
