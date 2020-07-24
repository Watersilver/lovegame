local ps = require "physics_settings"
local im = require "image"
local p = require "GameObjects.prototype"
local et = require "GameObjects.enemyTest"
local ebh = require "enemy_behaviours"
local sh = require "GameObjects.shadow"
local expl = require "GameObjects.explode"
local proj = require "GameObjects.enemies.projectile"
local u = require "utilities"
local o = require "GameObjects.objects"

local dc = require "GameObjects.Helpers.determine_colliders"

local function belowGround(instance, bool)
  instance.harmless = bool
  -- ATTACK DODGER MEANS WEAPON WONT ACT AS IF IT HIT something
  -- CHECK IT HERE, ON JUMPY AND ZORA TO MAKE SURE I DOT NEED ANYTHING MORE
  instance.attackDodger = bool
  instance.undamageable = bool
  instance.underground = bool
end

local Leever = {}

function Leever.initialize(instance)
  instance.maxspeed = 80
  instance.sprite_info = im.spriteSettings.leever
  instance.hp = 3 --love.math.random(3)
  instance.resetBehaviour = 0.5
  instance.physical_properties.shape = ps.shapes.circleAlmost1
  -- instance.physical_properties.categories = {FLOORCOLLIDECAT}
  instance.duration = 3
  instance.universalForceMod = 0
  instance.untouchable = true
  instance.giveChase = false -- Chase player
  instance.maxSpeed = 55
  instance.turnSpeed = 111

  belowGround(instance, true)
end

Leever.functions = {
  enemyLoad = function (self)
    self.timer = 0
    self.sprite = im.sprites["Enemies/Leever/digging"]
    self.mass = self.body:getMass()
  end,

  destroy = function (self)
    self.creator.pause = false
    self.creator:resetTimer(self.duration - self.timer)
  end,

  enemyUpdate = function (self, dt)
    self.target = session.decoy or pl1

    -- Remember velocity vector
    self.vx, self.vy = self.body:getLinearVelocity()

    if self.risen and not self.sinking then
      if self.startedMoving then

        -- Stabilize speed
        local _, dir = u.cartesianToPolar(self.vx, self.vy)
        self.body:setLinearVelocity(u.polarToCartesian(self.maxSpeed, dir))
        local nvx, nvy = u.polarToCartesian(1, dir)

        -- If I must giveChase and have a target, give chase
        if self.giveChase and self.target then

          -- Get velocity vector and vector pointing to target
          local vx, vy = self.vx, self.vy
          local dx, dy = self.target.x - self.x, self.target.y - self.y

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

        -- Rnadom direction
        local dir = (love.math.random() * 2 - 1) * math.pi

        -- Calculate speed
        self.body:setLinearVelocity(u.polarToCartesian(self.maxSpeed, dir))
      end
    end

    -- Determine life state
    if self.timer > self.duration then
      self.sank = true
      o.removeFromWorld(self)
    elseif self.timer > self.duration - 0.15 then
      self.image_index = 0
    elseif self.timer > self.duration - 0.3 then
      if not self.sinking then
        belowGround(self, true)
        self.sinking = true
        self.sprite = im.sprites["Enemies/Leever/digging"]
        self.image_speed = 0
        self.image_index = 1
      end
    elseif self.timer > 0.3 then
      if not self.risen then
        belowGround(self, false)
        self.risen = true
        self.sprite = im.sprites["Enemies/Leever/leever"]
        self.image_speed = 0.2
        self.image_index = 0
      end
    elseif self.timer > 0.15 then
      self.image_index = 1
    else
      self.image_index = 0
      self.image_speed = 0
    end

    self.timer = self.timer + dt
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

  preSolve = function(self, a, b, coll, aob, bob)
    if self.underground then
      coll:setEnabled(false)
      self.body:setLinearVelocity(0, 0)
    end
  end,
}

function Leever:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Leever, instance, init) -- add own functions and fields
  return instance
end

return Leever
