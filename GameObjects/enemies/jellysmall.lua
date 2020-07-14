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

local Zora = {}

function Zora.initialize(instance)
  instance.maxspeed = 10 + love.math.random(-6, 3)
  instance.sprite_info = im.spriteSettings.jellysmall
  instance.hp = 0.2 --love.math.random(3)
  instance.physical_properties.shape = ps.shapes.circleHalf
  -- instance.physical_properties.categories = {FLOORCOLLIDECAT}
  instance.turnSpeed = u.chooseFromChanceTable{
    {value = 111, chance = 0.3},
    {value = 70, chance = 0.3},
    {value = 40, chance = 0.3},
    {value = 222, chance = 0.1},
  }
  instance.flying = true -- can go through walls
  instance.controlledFlight = true
  instance.lowFlight = true
  instance.scaleSpeed = 0.3
  instance.zo = -1
end

Zora.functions = {
  enemyLoad = function (self)
    self.mass = self.body:getMass()
    self.scaleTimer = 0
  end,

  enemyUpdate = function (self, dt)
    -- Determine image x scale
    if self.scaleTimer > self.scaleSpeed then
      self.scaleTimer = 0
      self.x_scale = -self.x_scale
    end
    self.scaleTimer = self.scaleTimer + dt

    self.target = session.decoy or pl1

    -- Remember velocity vector
    self.vx, self.vy = self.body:getLinearVelocity()

    if self.startedMoving then

      -- Stabilize speed
      local _, dir = u.cartesianToPolar(self.vx, self.vy)
      if not self.invulnerable and not self.attacked then
        self.body:setLinearVelocity(u.polarToCartesian(self.maxspeed, dir))
      end
      local nvx, nvy = u.polarToCartesian(1, dir)

      -- If I must giveChase and have a target, give chase
      if self.target then

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
      self.body:setLinearVelocity(u.polarToCartesian(self.maxspeed, dir))
    end

    sh.handleShadow(self)
  end,
}

function Zora:new(init)
  local instance = p:new() -- add parent functions and fields
  p.new(et, instance) -- add parent functions and fields
  p.new(Zora, instance, init) -- add own functions and fields
  return instance
end

return Zora
