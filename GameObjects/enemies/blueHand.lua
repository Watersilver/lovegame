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

local dc = require "GameObjects.Helpers.determine_colliders"

local function belowGround(instance, bool)
  instance.harmless = bool
  -- ATTACK DODGER MEANS WEAPON WONT ACT AS IF IT HIT something
  -- CHECK IT HERE, ON JUMPY AND ZORA TO MAKE SURE I DOT NEED ANYTHING MORE
  instance.attackDodger = bool
  instance.undamageable = bool
  instance.underground = bool
end

local BlueHand = {}

function BlueHand.initialize(instance)
  instance.sprite_info = im.spriteSettings.blueHand
  instance.hp = 7 --love.math.random(3)
  instance.physical_properties.shape = ps.shapes.point
  -- instance.physical_properties.categories = {FLOORCOLLIDECAT}
  instance.duration = 3 + love.math.random() * 10
  instance.universalForceMod = 0
  instance.untouchable = true
  instance.maxSpeed = 22
  instance.turnSpeed = 77
  instance.flying = true
  instance.zo = 0
  instance.harmless = true
  instance.grabSound = snd.load_sound{"Effects/Oracle_Boss_Die"}

  -- Init dir direction
  instance.initDir = (love.math.random() * 2 - 1) * math.pi

  -- determine initial facing
  if instance.initDir > - math.pi * 0.5 and instance.initDir < math.pi * 0.5 then
    instance.x_scale = -1
  else
    instance.x_scale = 1
  end

  belowGround(instance, true)
end

BlueHand.functions = {
  enemyLoad = function (self)
    self.timer = 0
    self.grabTimer = 0
    self.sprite = im.sprites["Enemies/BlueHand/digging"]
    self.mass = self.body:getMass()
  end,

  destroy = function (self)
    self.creator.pause = false
    if not self.sank then self.creator.blueHands = self.creator.blueHands - 1 end
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
      elseif self.grabTimer > 2 then
        self.y_scale = 0
      elseif self.grabTimer > 1 then
        self.image_index = 0
      elseif self.grabTimer == 0 then
        self.sprite = im.sprites["Enemies/BlueHand/digging"]
        self.image_speed = 0
        self.image_index = 1
        self.zo = 0
        snd.play(self.grabSound)
      end

      gsh.newShake(mainCamera, "displacement", self.grabTimer, self.grabTimer)

      self.grabTimer = self.grabTimer + dt
    else
      self.target = session.decoy or pl1

      -- Remember velocity vector
      self.vx, self.vy = self.body:getLinearVelocity()

      if self.risen and not self.sinking then
        if self.startedMoving then

          -- Stabilize speed
          local _, dir = u.cartesianToPolar(self.vx, self.vy)
          self.body:setLinearVelocity(u.polarToCartesian(self.maxSpeed, dir))
          local nvx, nvy = u.polarToCartesian(1, dir)

          -- If I have a target, give chase
          if self.target then

            -- Get velocity vector and vector pointing to target
            local vx, vy = self.vx, self.vy
            local dx, dy = self.target.x - self.x, self.target.y - self.y

            -- Determine facing
            if self.vx > 2 then
              self.x_scale = -1
            elseif self.vx < -2 then
              self.x_scale = 1
            end

            -- Determine if d is to the right of v
            -- the sign of dot(a, rot90CCW(b)) tells you
            -- whether b is on the right or left of a, where
            -- rot90CCW(b) == {x: -b.y, y: b.x}.
            local dot = vx*(-dy) + vy*dx
            if dot > 0 then
              -- d on the right of v

              -- Rotate normal velocity vector 90 to the right
              local _, dir = u.cartesianToPolar(nvy, -nvx)

              self.body:applyForce(u.polarToCartesian(self.turnSpeed * self.mass, dir))
            elseif dot < 0 then
              -- d on the left of v

              -- Rotate normal velocity vector 90 to the left
              local _, dir = u.cartesianToPolar(-nvy, nvx)

              self.body:applyForce(u.polarToCartesian(self.turnSpeed * self.mass, dir))

            -- else They are parallel
            end
          end
        else -- Start movement

          self.startedMoving = true

          -- Calculate speed
          self.body:setLinearVelocity(u.polarToCartesian(self.maxSpeed, self.initDir))
        end
      end

      -- Determine life state
      if self.timer > self.duration then
        self.sank = true
        o.removeFromWorld(self)
      elseif self.timer > self.duration - 0.15 then
        self.image_index = 0
        self.body:setLinearVelocity(0, 0)
      elseif self.timer > self.duration - 0.3 then
        if not self.sinking then
          self.body:setLinearVelocity(0, 0)
          belowGround(self, true)
          self.sinking = true
          self.sprite = im.sprites["Enemies/BlueHand/digging"]
          self.image_speed = 0
          self.image_index = 1
          self.zo = 0
        end
      elseif self.timer > self.duration - 1 then
        -- Descend
        self.zo = self.zo + 6 * dt
        if self.zo > 0 then self.zo = 0 end
      elseif self.risen then
        -- Rise above ground
        self.zo = self.zo - 3 * dt
        if self.zo < -4 then self.zo = -4 end
      elseif self.timer > 0.3 then-- Lower self
        if not self.risen then
          belowGround(self, false)
          self.risen = true
          self.sprite = im.sprites["Enemies/BlueHand/hand"]
          self.image_speed = 0.05
          self.image_index = 0
        end
      elseif self.timer > 0.15 then
        self.image_index = 1
      else
        self.image_index = 0
        self.image_speed = 0
      end

      self.timer = self.timer + dt
    end

    sh.handleShadow(self)
  end,

  enemyBeginContact = function (self, other)

    -- Occupy tile
    if other.floor then
      other.occupied = other.occupied and other.occupied + 1 or 1
    end
  end,

  endContact = function(self, a, b, coll, aob, bob)
    local other, myF, otherF = dc.determine_colliders(self, aob, bob, a, b)

    -- Unoccupy tile
    if other.occupied then
      other.occupied = other.occupied - 1
      if other.occupied < 1 then other.occupied = nil end
    end
  end,

  hitPlayer = function (self, other, myF, otherF)
    if self.grabbedPlayer then return end
    self.grabbedPlayer = other.zo == 0 and other.animation_state.state ~= "dontdraw" and other.body:getType() == "dynamic" and not other.deathState
    if self.grabbedPlayer then
      other.animation_state:change_state(other, dt, "dontdraw")
      self.grabbedPlayer = other
      self.undamageable = true
    end
  end,
}

function BlueHand:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(BlueHand, instance, init) -- add own functions and fields
  return instance
end

return BlueHand
